# sway-scroll-static — building Scroll on SteamOS (agent notes)

Scroll (Wayland compositor) will NOT build against SteamOS system libs out of the
box. Two SteamOS-specific traps, both solved here. Read before touching the build.

## Trap 1: Wayland version gap (SOLVED by this PKGBUILD)

Scroll 1.12.17 bundles wlroots, which requires `wayland-server >= 1.24.0`.
SteamOS ships **1.23.1** and has nothing newer in its repos. You CANNOT `pacman -Syu`
wayland to 1.24 — it is not available, and upgrading system wayland would risk the
whole graphics stack (gamescope/Game Mode).

**Fix (already in PKGBUILD):** vendor wayland 1.24.0 + wayland-protocols 1.48 as
tarballs and build them **statically into scroll**, never touching system wayland:
- `source=(... wayland-1.24.0.tar.xz wayland-protocols-1.48.tar.xz)`
- `prepare()` copies them into `subprojects/wlroots/subprojects/{wayland,wayland-protocols}`
- `build()` uses `--force-fallback-for=wayland,wayland-protocols` +
  `-Dwayland:default_library=static`
- `check()` FAILS the build if any binary dynamically links libwayland (guarantees static)
- `package()` FAILS if vendored wayland artifacts leak into the system tree

Do NOT "simplify" by using the plain AUR `sway-scroll` PKGBUILD — it assumes system
wlroots-0.21 / wayland 1.24, which do not exist on SteamOS, and will fail.

## Trap 2: SteamOS strips -devel files (headers + pkgconfig)

SteamOS ships runtime libs but STRIPS their `/usr/include/*.h` and
`/usr/lib/pkgconfig/*.pc`. pacman DB still lists the package as installed, so
`pacman -S <pkg>` with `--needed` SKIPS it and the files stay missing. Build fails
with `Package X was not found in the pkg-config search path` or missing headers
(e.g. `SFD_CLOEXEC` from a wiped `sys/signalfd.h` = stripped glibc headers).

**Fix:** force-reinstall (NOT `--needed`) every build/runtime dep so the actual files
get re-extracted. This cascades through transitive pkgconfig deps (freetype needs
bzip2/brotli/graphite2, glib needs sysprof-capture, gdk-pixbuf needs libjpeg/libtiff/
zstd, cairo needs xau/xdmcp, etc.). Use `restore-build-deps.sh` in this dir — it
force-reinstalls the full closure in one pass.

**WARNING — glibc + rwfus:** do NOT reinstall glibc while the rwfus overlay is
mounted. glibc-in-overlay makes rwfus refuse to mount on next boot (safety measure:
glibc in the overlay bricks SteamOS updates), which drops you to the raw rootfs and
wipes ALL layered packages. See Trap 3. If you must restore glibc headers, do it
with rwfus UNMOUNTED, or extract just the headers rather than reinstalling the pkg.

## Trap 3: Persistence (rwfus) — why installs vanish on reboot

Scroll lives in `/usr/bin` (a compositor cannot run from distrobox — it owns host
DRM/input). `/usr` on SteamOS is read-only and reset on updates. `rwfus` overlays
`/usr` so pacman installs persist — but if `rwfusd.service` fails to mount (e.g.
glibc-in-overlay safety abort, see Trap 2), installs go to the raw rootfs and are
lost on reboot. Check: `findmnt /usr` should show an overlay; `systemctl status
rwfusd` should be active. If scroll is on `/dev/nvme0n1p5` (raw /), it is NOT
persisted.

## Build procedure (start to finish)

    cd ~/gyatfiles/scripts/arch/sway-scroll-static
    ../restore-build-deps.sh          # force-reinstall stripped devel deps
    makepkg -f --noconfirm            # downloads wayland 1.24, builds static
    sudo pacman -U sway-scroll-static-*.pkg.tar.zst

Verify: `readelf -d /usr/bin/scroll | grep libwayland` returns nothing (static).

## Distrobox is safe (context)

CLI tools live in the arch-base distrobox (podman storage in $HOME) and survive all
of this — the rootfs wipe only touches /usr. Only the compositor must be host-native,
which is exactly what makes it fragile. This is the trade the whole setup accepts.
