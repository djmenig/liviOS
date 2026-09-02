# LiviOS openSUSE — build quickstart

Condensed copy-paste reference. For full walkthrough, troubleshooting and the
Docker route, see [`BUILDING.md`](BUILDING.md).

> No root in this sandbox — run these on a host where you have `sudo`.

## Install KIWI NG (native, openSUSE Leap 15.6 host)

```sh
sudo zypper addrepo \
  http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.6 \
  kiwi-appliance-builder
sudo zypper --gpg-auto-import-keys refresh
sudo zypper --gpg-auto-import-keys install python3-kiwi xorriso syslinux qemu-tools qemu-kvm
kiwi-ng --version
```

**Tumbleweed host?** Use `openSUSE_Tumbleweed` as the `<DIST>` directory in the
`addrepo` URL. The build command still targets Leap 15.6.

## Docker route (no host install)

```sh
docker run -it --rm --privileged --platform linux/amd64 -v "$PWD:/build" opensuse/leap:15.6
# inside container:
zypper addrepo \
  http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.6 \
  kiwi
zypper --gpg-auto-import-keys refresh
zypper in -y python3-kiwi xorriso syslinux dosfstools e2fsprogs squashfs
```

## Pre-build checklist

```sh
xmllint --noout editions/opensuse/appliance.kiwi          # XML valid
bash -n editions/opensuse/config.sh && bash -n editions/opensuse/scripts/build.sh  # syntax OK
grep 'bootloader-theme.*linudore64' editions/opensuse/appliance.kiwi               # GRUB theme
grep 'rd.kiwi.allow_plymouth' editions/opensuse/appliance.kiwi                     # splash in initrd
grep plymouth-plugin-script editions/opensuse/appliance.kiwi                        # script plugin
grep -E 'sudo|pyxdg' editions/opensuse/appliance.kiwi                              # sudo + xdg
ls editions/opensuse/root/usr/share/grub2/themes/linudore64/theme.txt           # theme at standard path
grep '# include' editions/opensuse/root/home/demo/.Xresources || echo "no antiX includes (good)"
grep xrdb editions/opensuse/root/home/demo/.xinitrc                                # xrdb merge present
find editions/opensuse/root -type f | wc -l                                        # 28 overlay files
```

All checks should pass (no `# include` hits, 28 files).

## Build

```sh
# from the repository root:
sudo kiwi-ng system build \
  --description editions/opensuse \
  --set-repo https://download.opensuse.org/distribution/leap/15.6/repo/oss \
  --target-dir builds/opensuse
```

Or via the wrapper:

```sh
editions/opensuse/scripts/build.sh builds/opensuse
```

Output: `builds/opensuse/livios-opensuse.x86_64-1.0.0.iso`

## Test

```sh
qemu-system-x86_64 -enable-kvm \
  -cdrom builds/opensuse/livios-opensuse.x86_64-1.0.0.iso \
  -m 4096
```

Expect: GRUB (Linudore 64) → plymouth `livios` splash → tty1 `demo` autologin →
Openbox/URxvt desktop.

## Verify (optional, without booting)

```sh
sudo mount -o loop builds/opensuse/livios-opensuse.x86_64-1.0.0.iso /mnt/iso
ls /mnt/iso/boot/grub2/themes/linudore64/
grep -E 'themefile|GRUB_THEME' /mnt/iso/boot/grub2/grub.cfg
unsquashfs -ll "$(find /mnt/iso -name '*.squashfs' | head -1)" | grep -E '\.Xresources|\.xinitrc|themes/livios|plymouthd.conf'
lsinitrd /mnt/iso/boot/x86_64/loader/initrd | grep -i plymouth
sudo umount /mnt/iso
```

Theme + live `grub.cfg` should reference the `linudore64` GRUB theme, the
squashfs should list the LiviOS dotfiles/plymouth overlay, and the initrd should
contain the `livios` plymouth theme.

## Rebuild reminder

KIWI NG does not clear the target dir — wipe it first:

```sh
rm -rf builds/opensuse
```
