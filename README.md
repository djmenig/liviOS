# LiviOS
*A lightweight, retro‑inspired Linux distribution designed for clarity, learning, and fun.*

LiviOS recreates the charm of classic terminal‑first computing while remaining fully modern and maintainable. It boots directly into a themed Openbox session with a C64‑styled URxvt terminal. LiviOS is still in its early stages, with many planned features and improvements ahead.

The project is named after my daughter, Livi, and began as a way to give her a clean, expressive first computer experience. It has since grown into a systems‑engineering project focused on reproducibility, clarity, and thoughtful design.

---

## ✨ Key Features
- Retro C64‑inspired terminal experience  
- Instant boot into Openbox  
- Custom experience throughout (GRUB theme + splash screen + UI)  
- Ultra‑lightweight (32‑bit compatible) - *antiX Edition only*
- Hyperfocused on UX providing a distraction‑free environment for education or fun
- Multiple editions (antiX now, openSUSE planned)

---

## 📚 Documentation
- [Project Overview](docs/overview.md)
- [Architecture](docs/architecture.md)
- [Roadmap](docs/roadmap.md)
- [antiX Edition](editions/antix/README.md)
- [openSUSE Edition](editions/openSUSE/README.md)
- [File Manifest](docs/file-manifest/README.md)

---

## 🏗️ Repository Structure
```
liviOS/
├── assets/                   # Branding, splash, GRUB theme, fonts
│   ├── fonts/
│   │   └── JuliaMono-Black.ttf
│   └── splash/
│       └── livios-splash-planets.png
│
├── docs/                     # Documentation, architecture, roadmap, file manifest
│   ├── file-manifest/
│   │   ├── files/
│   │   ├── fileLocations_antiX-demo.csv
│   │   └── README.md
│   ├── screenshots/
│   ├── architecture.md
│   ├── overview.md
│   └── roadmap.md
│
├── editions/
│   ├── antix/                # antiX Edition (current)
│   │   ├── README.md
│   │   ├── rootfs/
│   │   ├── scripts/
│   │   └── build-iso.conf
│   │
│   └── opensuse/             # openSUSE Edition (planned)
│       ├── README.md
│       ├── kiwi/
│       ├── rootfs-overlay/
│       └── scripts/
│
└── LICENSE

```

---

## 🧩 antiX Edition
The first release of LiviOS, designed for older hardware and 32‑bit systems. Includes:

- Custom GRUB theme  
- Custom splash screen  
- Openbox environment  
- C64‑themed URxvt  
- Autologin + startx on tty1  
- Runit service modifications  
- Demo user environment  
- Curated set of lightweight applications installed via the build scripts

---

## 🗂️ File Manifest
The antiX Edition includes a complete file manifest documenting:

- All custom LiviOS files  
- Their exact locations inside the root filesystem  
- Their purpose and behavior  

See: [File Manifest](docs/file-manifest/README.md)

---

## 📦 Release Status
- antiX Edition: Active development (pre‑release)
- openSUSE Edition: Planned
- File manifest: Complete for antiX demo
- Build pipeline: Under review (scripts not yet validated)

---

## 🚀 Roadmap
See: [Roadmap](docs/roadmap.md)

---

## 📜 License
Licensed under the **GNU General Public License v3.0 (GPLv3)**.
