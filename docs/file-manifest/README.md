# File Manifest

The LiviOS file manifest documents every custom file included in the distribution and its exact location inside the root filesystem. This provides a clear, reproducible map of all modifications made to the base system.

## Purpose
- Ensure full transparency of all customizations  
- Support reproducible builds  
- Provide a reference for debugging and future editions  
- Maintain a clean separation between upstream files and LiviOS-specific additions

## Structure
- `fileLocations_antiX-demo.csv` — CSV mapping each custom file to its destination path inside the antiX Edition rootfs.
- `files/` — Contains all custom LiviOS files (Openbox configs, GRUB theme assets, runit services, splash screens, fonts, etc.).

## Notes
- The manifest currently covers the antiX Edition.  
- The openSUSE Edition will receive its own manifest once development begins.
