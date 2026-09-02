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

## Rebuild reminder

KIWI NG does not clear the target dir — wipe it first:

```sh
rm -rf builds/opensuse
```
