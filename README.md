# LiviOS
*A lightweight, retro‑inspired Linux distribution designed for clarity, learning, and fun.*

LiviOS recreates the charm of classic terminal‑first computing while remaining fully
modern and maintainable. It boots directly into a themed Openbox session with a
C64‑styled URxvt terminal. The project began as a way to give my daughter a clean,
expressive first computer experience and has grown into a systems‑engineering effort
focused on reproducibility, clarity, and thoughtful design.

---

## ✨ Key Features
- Retro C64‑inspired terminal experience  
- Instant boot into Openbox  
- Unique custom UX throughout (GRUB theme, splash screen, terminal theme, Openbox layout)  
- Ultra‑lightweight, 32‑bit compatible — *antiX Edition*  
- Distraction‑free environment for learning and exploration  
- Multiple editions (antiX now, openSUSE planned)

---

## 📦 Delivery Models
LiviOS is delivered differently per edition, based on the target hardware:

- **antiX Edition (32‑bit): post‑install.** Because the target hardware is
  constrained (older, low‑resource systems), LiviOS is **not** shipped as a live ISO.
  Instead, you install a minimal **antiX‑core** system and then run the LiviOS
  installer script, which copies all LiviOS files into place and configures the
  boot experience. See [antiX Edition](editions/antix/README.md).
- **openSUSE Edition (64‑bit): live ISO.** Planned as a KIWI‑based 64‑bit live
  image build. See [openSUSE Edition](editions/opensuse/README.md).

---

## 💻 Quick Start (antiX Edition)
1. Install a minimal **antiX‑core** system (32‑bit).
2. Copy `editions/antix/install.sh` to the installed system.
3. Run as root:
   ```sh
   ./install.sh
   ```
4. Reboot — you land on the C64‑themed Openbox desktop.

The installer handles both **runit** and **sysvinit** init systems automatically.

---

## 📚 Documentation Overview
- [Project Overview](docs/overview.md)  
- [Architecture](docs/architecture.md)  
- [Roadmap](docs/roadmap.md)  
- [antiX Edition](editions/antix/README.md)  
- [openSUSE Edition](editions/opensuse/README.md)  
- [File Manifest](docs/file-manifest/README.md)

---

## 🗂️ File Manifest
The antiX Edition includes a complete file manifest documenting all custom LiviOS
files and their exact installed locations. See:
`docs/file-manifest/README.md`

---

## 📦 Release Status
- antiX Edition: Active development (post‑install installer)  
- openSUSE Edition: Planned (KIWI live ISO)  
- File manifest: Complete for antiX  
- Installer pipeline: Under review (not yet validated on real hardware)

---

## 🚀 Roadmap
See: `docs/roadmap.md`

---

## 📜 License
Licensed under the **GNU General Public License v3.0 (GPLv3)**.
