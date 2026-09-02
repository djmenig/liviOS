#!/usr/bin/env bash
#
# build.sh - build the LiviOS openSUSE live ISO with KIWI NG.
#
# Convenience wrapper around:
#     sudo kiwi-ng system build --description editions/opensuse --target-dir ...
#
# Usage:
#     editions/opensuse/scripts/build.sh [target-dir]
#
#   target-dir   Where to write the ISO (default: <repo>/builds/opensuse)
#
# The appliance.kiwi uses 'obsrepositories:/' as its primary repo, which only
# resolves when building on the Open Build Service. For local builds pass the
# Leap 15.6 OSS repository via --set-repo, for example:
#
#     sudo kiwi-ng system build \
#       --description editions/opensuse \
#       --set-repo https://download.opensuse.org/distribution/leap/15.6/repo/oss \
#       --target-dir builds/opensuse
#
# Requires kiwi-ng installed on the host (openSUSE Leap 15.6 or compatible).
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPEN_SUSE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(cd "$OPEN_SUSE_DIR/../.." && pwd)"

TARGET_DIR="${1:-$ROOT/builds/opensuse}"
# Override when building locally (obsrepositories:/ is OBS-only). Unset/empty
# to let the appliance.kiwi repositories apply as-is (e.g. on OBS).
OSS_REPO="${OSS_REPO:-https://download.opensuse.org/distribution/leap/15.6/repo/oss}"

[ -f "$OPEN_SUSE_DIR/appliance.kiwi" ] || { echo "missing appliance.kiwi" >&2; exit 1; }

command -v kiwi-ng >/dev/null 2>&1 || { echo "kiwi-ng not found on PATH" >&2; exit 1; }

mkdir -p "$TARGET_DIR"

echo "Building LiviOS openSUSE ISO -> $TARGET_DIR"

CMD=(sudo kiwi-ng system build --description "$OPEN_SUSE_DIR")
if [ -n "$OSS_REPO" ]; then
    CMD+=(--set-repo "$OSS_REPO")
fi
CMD+=(--target-dir "$TARGET_DIR")
"${CMD[@]}"

echo
echo "Done. ISO written to $TARGET_DIR"

