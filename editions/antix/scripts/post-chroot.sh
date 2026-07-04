#!/bin/bash
#
# Script requires manual review and validation.
# Placeholder for antiX build pipeline.
#
#
#
#
#
# post-chroot.sh - Runs on the HOST after the chroot is finalized.
#
# Performs final cleanup and validation on the built rootfs
# before build-iso creates the SquashFS and assembles the ISO.
#
# Context:
#   - build-iso runs this on the host after the chroot exits
#   - The completed rootfs is at a temp location known to build-iso
#   - $LIVIOS_ROOT is available for reference
# ============================================================

set -euo pipefail

LIVIOS_ROOT="${LIVIOS_ROOT:?LIVIOS_ROOT not set}"

echo "[post-chroot] LiviOS post-processing complete."
echo "[post-chroot] build-iso will now create SquashFS and assemble ISO."

exit 0
