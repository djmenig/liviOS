#!/bin/bash
# gdash-build-in-container.sh — runs INSIDE an opensuse/leap:15.6 podman container.
# Installs the GDash build deps and builds the RPM into /out (a bind mount).
# Invoked by build-gdash-rpm.sh via podman. Not meant to be run directly.

set -euo pipefail

export LANG=C.UTF-8

echo "=== Refreshing package metadata ==="
zypper --non-interactive --gpg-auto-import-keys refresh 2>&1 | tail -2 || true

echo "=== Installing build dependencies ==="
zypper --non-interactive --gpg-auto-import-keys install --no-recommends \
    gcc-c++ pkg-config autoconf automake gettext-devel glib2-devel \
    gtk3-devel libSDL2-devel SDL2_image-devel SDL2_mixer-devel \
    Mesa-devel glu-devel libpng16-devel desktop-file-utils \
    rpm-build createrepo_c curl tar gzip 2>&1 | tail -3

echo "=== Verifying real SDL2 on Leap 15.6 ==="
pkg-config --modversion sdl2
pkg-config --modversion gtk+-3.0

echo "=== Downloading GDash source ==="
mkdir -p /build/gdash-src
cd /build/gdash-src
if [ ! -f f980da7f4318.tar.gz ]; then
    curl -sL -o f980da7f4318.tar.gz \
        https://bitbucket.org/czirkoszoltan/gdash/get/f980da7f4318.tar.gz
fi
tar xzf f980da7f4318.tar.gz
HASH=$(ls -d czirkoszoltan-gdash-* | xargs -n1 basename | sed 's/czirkoszoltan-gdash-//')
echo "source hash dir: czirkoszoltan-gdash-${HASH}"

echo "=== Setting up rpmbuild tree ==="
mkdir -p /build/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cp f980da7f4318.tar.gz /build/rpmbuild/SOURCES/
SPEC_IN="${1:-/work/gdash.spec}"
cp "${SPEC_IN}" /build/rpmbuild/SPECS/gdash.spec
# Match the spec's %autosetup -n to the actual extracted dir name
sed -i "s/czirkoszoltan-gdash-f980da7f4318/czirkoszoltan-gdash-${HASH}/" /build/rpmbuild/SPECS/gdash.spec

echo "=== Building RPM with rpmbuild ==="
cd /build/rpmbuild/SPECS
rpmbuild -ba gdash.spec \
    --define "_topdir /build/rpmbuild" \
    --define "_sourcedir /build/rpmbuild/SOURCES" 2>&1 | tail -30

echo "=== Creating local RPM-MD repo ==="
mkdir -p /out
cp /build/rpmbuild/RPMS/*/*.rpm /out/
createrepo_c /out

echo "=== DONE ==="
ls -la /out/
