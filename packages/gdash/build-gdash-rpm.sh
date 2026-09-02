#!/bin/bash
# build-gdash-rpm.sh — Build GDash RPM and create a local RPM-MD repo for KIWI.
#
# NOTE: GDash must be built against the **Leap 15.6** SDK (real SDL2). Leap 16 /
# Tumbleweed have moved to SDL3 and ship only an SDL2->SDL3 compatibility shim
# with no sdl2.pc dev files, so an RPM built there would be binary-incompatible
# with the Leap 15.6 image. Therefore the default (and recommended) route builds
# inside an opensuse/leap:15.6 podman container.
#
# Usage (from the repo root):
#   packages/gdash/build-gdash-rpm.sh              # podman (recommended)
#   packages/gdash/build-gdash-rpm.sh --native     # host rpmbuild (Leap 15.6 host)
#   packages/gdash/build-gdash-rpm.sh --podman     # explicit podman route
#
# Requires (podman route): podman (rootless). The container pulls opensuse/leap:15.6
# and installs all build deps itself; no host sudo needed.
# Requires (native route): rpmbuild, createrepo_c, and the build deps listed in
# gdash.spec, on a host with access to the Leap 15.6 SDK repos.
#
# Output:
#   packages/gdash/repo/   — RPM-MD repository (consumed by KIWI via local path)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="${SCRIPT_DIR}/repo"
RPMBUILD_DIR="${SCRIPT_DIR}/rpmbuild"
WORK_DIR="${SCRIPT_DIR}/container-build"
MODE="${1:-container}"

echo "=== GDash RPM build ==="
echo "Repo dir:   ${REPO_DIR}"

# --- 1. Recreate the repo dir (clears any stale RPMs) ---
rm -rf "${REPO_DIR}"
mkdir -p "${REPO_DIR}"

case "${MODE}" in
    container|--container|--podman)
        echo "=== Podman route (Leap 15.6 container) ==="
        if ! command -v podman >/dev/null 2>&1 ; then
            echo "ERROR: podman not found. Install podman, or build on a Leap 15.6 host with --native." >&2
            exit 1
        fi
        mkdir -p "${WORK_DIR}"
        podman run --rm --name gdash-build \
            -v "${SCRIPT_DIR}/gdash-build-in-container.sh:/build.sh:ro,Z" \
            -v "${SCRIPT_DIR}/gdash.spec:/work/gdash.spec:ro,Z" \
            -v "${REPO_DIR}:/out:Z" \
            -v "${WORK_DIR}:/build:Z" \
            opensuse/leap:15.6 \
            /bin/bash -c 'cp /build.sh /tmp/run.sh && chmod +x /tmp/run.sh && /tmp/run.sh'
        ;;
    native|--native)
        echo "=== Native route (assumes a Leap 15.6 host) ==="
        # --- Create rpmbuild tree ---
        rm -rf "${RPMBUILD_DIR}"
        mkdir -p "${RPMBUILD_DIR}"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

        # --- Download source tarball ---
        TARBALL="f980da7f4318.tar.gz"
        SOURCE_URL="https://bitbucket.org/czirkoszoltan/gdash/get/${TARBALL}"
        SOURCES_DIR="${RPMBUILD_DIR}/SOURCES"
        if [ ! -f "${SOURCES_DIR}/${TARBALL}" ]; then
            echo "Downloading GDash source..."
            curl -L -o "${SOURCES_DIR}/${TARBALL}" "${SOURCE_URL}"
        fi

        # --- Build RPM ---
        echo "Building RPM..."
        rpmbuild -ba "${SCRIPT_DIR}/gdash.spec" \
            --define "_topdir ${RPMBUILD_DIR}" \
            --define "_sourcedir ${SOURCES_DIR}"

        # --- Collect RPMs into repo dir ---
        cp "${RPMBUILD_DIR}"/RPMS/*/*.rpm "${REPO_DIR}/"
        ;;
    *)
        echo "ERROR: unknown mode '${MODE}' (use --container or --native)" >&2
        exit 1
        ;;
esac

# --- 2. Generate repodata (requires createrepo_c) ---
echo "=== Creating repodata ==="
if command -v createrepo_c >/dev/null 2>&1 ; then
    createrepo_c "${REPO_DIR}"
elif command -v createrepo >/dev/null 2>&1 ; then
    createrepo "${REPO_DIR}"
else
    echo "ERROR: createrepo_c or createrepo not found." >&2
    echo "Install with: sudo zypper install createrepo_c" >&2
    exit 1
fi

echo ""
echo "=== Done ==="
echo "RPMs:     ${REPO_DIR}/"
echo "Repo XML: ${REPO_DIR}/repodata/repomd.xml"
echo ""
echo "The appliance.kiwi already references this repo as a file:// source."
