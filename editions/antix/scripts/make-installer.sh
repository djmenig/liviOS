#!/usr/bin/env bash
#
# make-installer.sh - regenerate the self-contained LiviOS antiX installer.
#
# Builds a fresh payload from the source of truth and embeds it into the
# committed editions/antix/install.sh, so that script is always
# self-contained (works without the repo present on the target machine).
#
# Payload sources:
#   docs/file-manifest/files/                -> the LiviOS core files (kept intact)
#   docs/file-manifest/fileLocations_antiX-demo.csv -> destination map (Source,Installed path)
#   editions/antix/packages.list             -> apt packages
#
# Usage:  editions/antix/scripts/make-installer.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANTIX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(cd "$ANTIX_DIR/../.." && pwd)"

FILES_DIR="$ROOT/docs/file-manifest/files"
CSV="$ROOT/docs/file-manifest/fileLocations_antiX-demo.csv"
PACKAGES="$ANTIX_DIR/packages.list"
INSTALLER="$ANTIX_DIR/install.sh"
MARK="##LIVIOS_PAYLOAD_BASE64_START##"

[ -d "$FILES_DIR" ]  || { echo "missing files dir: $FILES_DIR" >&2; exit 1; }
[ -f "$CSV" ]        || { echo "missing CSV: $CSV" >&2; exit 1; }
[ -f "$PACKAGES" ]   || { echo "missing packages.list: $PACKAGES" >&2; exit 1; }
[ -f "$INSTALLER" ]  || { echo "missing installer template: $INSTALLER" >&2; exit 1; }
grep -q -F "$MARK" "$INSTALLER" || { echo "marker not found in $INSTALLER" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 1. Validate the CSV against the payload files
# ---------------------------------------------------------------------------
echo "Validating payload against $CSV ..."
first=1
while IFS=, read -r src dst; do
    if [ "$first" -eq 1 ]; then first=0; continue; fi
    [ -z "$src" ] && continue
    src="${src//\"/}"; dst="${dst//\"/}"
    [ -n "$dst" ] || { echo "ERROR: no destination for: $src" >&2; exit 1; }
    [ -f "$FILES_DIR/$src" ] || { echo "ERROR: $src missing from $FILES_DIR" >&2; exit 1; }
done < "$CSV"
echo "  OK (all mapped files present)."

# ---------------------------------------------------------------------------
# 2. Build the payload tarball (base64, single line)
# ---------------------------------------------------------------------------
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/payload/files"
cp -a "$FILES_DIR/." "$TMP/payload/files/"
cp "$CSV" "$TMP/payload/fileLocations.csv"
cp "$PACKAGES" "$TMP/payload/packages.list"
PAYLOAD_B64="$(tar -C "$TMP" -czf - payload | base64 -w0)"
echo "  Payload: $(wc -c <<< "$PAYLOAD_B64") bytes of base64."
PAYLOAD_B64="$PAYLOAD_B64"   # keep line; SCM checkers choke on empty var

# ---------------------------------------------------------------------------
# 3. Rebuild install.sh = head (up to and including marker) + payload line
# ---------------------------------------------------------------------------
LINE="$(grep -n -F "$MARK" "$INSTALLER" | head -1 | cut -d: -f1)"
{ sed -n "1,${LINE}p" "$INSTALLER"; echo "$PAYLOAD_B64"; } > "$TMP/install.new"
chmod 755 "$TMP/install.new"
mv "$TMP/install.new" "$INSTALLER"
echo "Regenerated: $INSTALLER"
bash -n "$INSTALLER" && echo "  syntax OK"
echo "Done. Copy $INSTALLER to the installed antiX-core system and run as root."
