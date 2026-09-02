#!/bin/bash
# build-gdash-rpm.sh — Build GDash RPM from git snapshot and create a local repo
#
# Usage:
#   packages/gdash/build-gdash-rpm.sh
#
# Requires: rpmbuild, rpm-build, autoconf, automake, and the build deps listed
# in gdash.spec.  Run on a host with sudo access.
#
# Output:
#   packages/gdash/repo/   — RPM-MD repository (consumed by KIWI via local path)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="${SCRIPT_DIR}/repo"
RPMBUILD_DIR="${SCRIPT_DIR}/rpmbuild"

echo "=== GDash RPM build ==="
echo "Script dir: ${SCRIPT_DIR}"
echo "Repo dir:   ${REPO_DIR}"

# --- 1. Create rpmbuild tree ---
rm -rf "${RPMBUILD_DIR}"
mkdir -p "${RPMBUILD_DIR}"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# --- 2. Download source tarball ---
TARBALL="f980da7f4318.tar.gz"
SOURCE_URL="https://bitbucket.org/czirkoszoltan/gdash/get/${TARBALL}"
SOURCES_DIR="${RPMBUILD_DIR}/SOURCES"

if [ ! -f "${SOURCES_DIR}/${TARBALL}" ]; then
    echo "Downloading GDash source..."
    curl -L -o "${SOURCES_DIR}/${TARBALL}" "${SOURCE_URL}"
else
    echo "Source tarball already cached."
fi

# --- 3. Build RPM ---
echo "Building RPM..."
rpmbuild -ba "${SCRIPT_DIR}/gdash.spec" \
    --define "_topdir ${RPMBUILD_DIR}" \
    --define "_sourcedir ${SOURCES_DIR}"

# --- 4. Create local RPM-MD repository ---
echo "Creating local repo..."
rm -rf "${REPO_DIR}"
mkdir -p "${REPO_DIR}"

# Copy built RPMs
cp "${RPMBUILD_DIR}"/RPMS/*/*.rpm "${REPO_DIR}/"

# Generate repodata (requires createrepo_c)
if command -v createrepo_c >/dev/null 2>&1 ; then
    createrepo_c "${REPO_DIR}"
elif command -v createrepo >/dev/null 2>&1 ; then
    createrepo "${REPO_DIR}"
else
    echo "ERROR: createrepo_c or createrepo not found."
    echo "Install with: sudo zypper install createrepo_c"
    exit 1
fi

echo ""
echo "=== Done ==="
echo "RPMs:     ${REPO_DIR}/"
echo "Repo XML: ${REPO_DIR}/repodata/repomd.xml"
echo ""
echo "To use in KIWI build, add this repository to appliance.kiwi:"
echo "  <repository type=\"rpm-md\">"
echo "    <source path=\"file://${REPO_DIR}\"/>"
echo "  </repository>"
echo ""
echo "Or copy the RPMs to your OBS home project."
