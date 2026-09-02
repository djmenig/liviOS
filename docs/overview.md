# Overview

LiviOS is a lightweight, retro‑inspired Linux distribution designed to make computing simple, educational, and fun. It recreates the charm of classic terminal‑first systems while remaining fully modern and maintainable.

---

## Origin

The project is named after my daughter, Livi, and originally began by providing her first computer experience. The goal was to provide her an educational computer environment that was clean, minimal, and distraction‑free. By mimicking my first computer experience, the Commodore 64, and merging it with a modern Linux shell, LiviOS provides a fun and educational computer experience. Over time, it has evolved into a systems‑engineering project focused on clarity, reproducibility, and thoughtful design.

---

## Editions

LiviOS is developed in multiple editions:

- **antiX Edition** — ultra‑lightweight, 32‑bit compatible, ideal for older hardware.
  Delivered as a **post‑install installer** that runs on top of a minimal
  antiX‑core system (no live ISO).
- **openSUSE Edition** — engineering‑grade, 64‑bit, leveraging KIWI and modern
  tooling, delivered as an initial **live ISO**.

---

## Delivery Models

Each edition chooses a delivery model that fits its target hardware and tooling:

- **antiX (32‑bit) — Installer model.** Resource‑constrained hardware makes a
  full live ISO heavy and wasteful. Instead, the user installs a small
  antiX‑core base and runs `install.sh`, which:
  - installs the required packages,
  - copies the LiviOS core files to their destinations (per the file manifest),
  - configures the splash screen and tty1 autologin for **either** runit or
    sysvinit,
  - refreshes fonts and re‑runs `update-grub`.

- **openSUSE (64‑bit) — Image model.** A KIWI‑based live ISO build produced
  locally with `kiwi-ng` on a Leap 15.6 base (OBS packaging remains a future
  step). *(Initial edition shipped.)*

---

## Design Philosophy

Across all editions, LiviOS follows the same guiding principles:

- **Predictable behavior**  
- **Minimalism with intent**  
- **Clear, maintainable structure**  
- **Reproducibility as a core value**

These principles shape both the user experience and the engineering approach behind the project.
