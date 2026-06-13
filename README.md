# liviOS
A custom Linux distribution that provides a C64-like environment while maintaining modern Linux functionality. focused on the terminal.

# LiviOS
*A lightweight, retro‑inspired Linux distribution designed for education, creativity, and fun.*

LiviOS is a custom Linux distribution built to recreate the charm of classic computing — a terminal‑first environment inspired by the Commodore 64, powered by modern Linux foundations. It boots directly into a themed Openbox session with a C64‑styled URxvt terminal, a custom GRUB theme, and a fast, distraction‑free interface designed for learning and exploration.

LiviOS is developed in multiple **editions**, each tailored for different hardware and engineering goals:

- **antiX Edition** — ultra‑lightweight, 32‑bit compatible, ideal for older hardware  
- **openSUSE Edition** — engineering‑grade, 64‑bit, leveraging Kiwi, Btrfs, systemd, and openQA (coming soon)

---

## ✨ Key Features
- **Retro C64‑inspired terminal experience**  
  Custom URxvt theme, palette, and banner  
- **Instant boot into Openbox**  
  Autologin + startx on tty1  
- **Custom GRUB theme + splash screen**  
  Unified branding across boot and desktop  
- **Ultra‑lightweight**  
  Runs on 32‑bit hardware with minimal RAM  
- **Educational focus**  
  Clean environment for learning Linux fundamentals  
- **Multiple editions**  
  - antiX Edition (current release)  
  - openSUSE Edition (in development)

---

## 🏗️ Repository Structure
```
liviOS/
├── docs/                     # Documentation, file manifests, screenshots
│   ├── overview.md
│   ├── architecture.md
│   ├── roadmap.md
│   ├── screenshots/
│   └── fileManifest/
│       ├── Files/
│       └── fileLocations_antiX-demo.csv
│
├── assets/                   # Branding, splash, GRUB theme, fonts
│   ├── grub/
│   ├── splash/
│   ├── wallpapers/
│   ├── branding/
│   └── fonts/
│
├── editions/
│   ├── antix/                # antiX Edition (current focus)
│   │   ├── rootfs/           # Root filesystem overlay
│   │   ├── build/            # Snapshot excludes + post-processing
│   │   ├── scripts/          # Build + test scripts
│   │   └── README.md         # antiX-specific build instructions
│   │
│   └── opensuse/             # openSUSE Edition (coming soon)
│       ├── kiwi/
│       ├── rootfs-overlay/
│       ├── scripts/
│       └── README.md
│
├── ci/                       # QEMU boot tests + reference images
│   ├── reference-images/
│   ├── qemu/
│   └── scripts/
│
└── .github/
└── workflows/            # CI/CD pipelines
├── build-antix.yml
├── build-opensuse.yml
└── test-boot.yml
```

---

## 🧩 antiX Edition
The antiX Edition is the first release of LiviOS, designed for older hardware and 32‑bit systems. It includes:

- Custom GRUB theme  
- Custom splash screen  
- Openbox environment  
- C64‑themed URxvt  
- Autologin + startx on tty1  
- Runit service modifications  
- Full branding  
- Demo user environment  

Build instructions are located in:  
**`editions/antix/README.md`**

---

## 🧪 CI/CD Pipeline
LiviOS includes a GitHub Actions pipeline that:

- Builds the ISO  
- Boots it in QEMU (headless)  
- Captures a framebuffer screenshot  
- Compares it to a reference image  
- Uploads build artifacts  

This ensures every build is visually identical and fully functional.

Reference images are stored in:  
**`ci/reference-images/`**

---

## 🗂️ File Manifest
The antiX Edition includes a complete file manifest documenting:

- All custom LiviOS files  
- Their exact locations inside the root filesystem  
- Their purpose and behavior  

Located in:  
**`docs/fileManifest/`**

This is invaluable for reproducibility, debugging, and future editions.

---

## 🚀 Roadmap
- [x] antiX Edition  
- [x] Repo scaffolding  
- [x] File manifest  
- [ ] CI/CD pipeline  
- [ ] openSUSE Edition  
- [ ] OBS packaging  
- [ ] openQA tests  
- [ ] Website + documentation  
- [ ] Educational content  

---

## 📜 License
Licensed under the **GNU General Public License v3.0 (GPLv3)**.
