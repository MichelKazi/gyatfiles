#!/usr/bin/env bash
# Restore SteamOS-stripped -devel files (headers + pkgconfig) for building Scroll.
#
# SteamOS ships runtime libs but strips /usr/include/*.h and /usr/lib/pkgconfig/*.pc.
# pacman still thinks the pkgs are installed, so --needed skips them. This
# force-reinstalls (no --needed) the full transitive closure so the files return.
# See sway-scroll-static/README.md (Trap 2).
#
# WARNING: does NOT touch glibc by default — reinstalling glibc while the rwfus
# overlay is mounted makes rwfus refuse to mount on next boot (Trap 3), wiping all
# layered packages. If you need glibc headers (SFD_CLOEXEC / sys/signalfd.h errors),
# unmount rwfus first (rwfus --umount), reinstall glibc, then remount — or pass
# --with-glibc only when you understand the risk.
set -euo pipefail

WITH_GLIBC=0
[[ "${1:-}" == "--with-glibc" ]] && WITH_GLIBC=1

# Full closure discovered building scroll 1.12.17 on SteamOS (leaf -> up):
PKGS=(
  # leaves (deepest pkgconfig deps first)
  bzip2 brotli graphite libsysprof-capture zstd libdatrie libjpeg-turbo libtiff
  shared-mime-info xz icu libxau libxdmcp
  # x libs
  libx11 libxext libxrender libxft libxcb libxfixes
  # mid-level
  libffi expat libxml2 zlib libpng freetype2 fontconfig harfbuzz glib2 dbus
  fribidi libthai pixman util-linux util-linux-libs
  # scroll direct deps
  cairo gdk-pixbuf2 json-c libdrm libevdev libinput libxkbcommon pango pcre2
  wayland xcb-util-wm lua libliftoff libglvnd lcms2 systemd-libs
  xcb-util-errors xcb-util-renderutil seatd glslang vulkan-icd-loader
  libdisplay-info libcap hwdata
  # build deps
  meson ninja scdoc wayland-protocols vulkan-headers xorgproto xorg-xwayland
  fakeroot debugedit
)
[[ $WITH_GLIBC -eq 1 ]] && PKGS+=(glibc linux-api-headers)

echo "Force-reinstalling ${#PKGS[@]} packages to restore stripped devel files..."
echo "(sudo required; rootfs must be writable: sudo steamos-readonly disable)"
sudo pacman -S --noconfirm "${PKGS[@]}"

echo "Verifying key pkgconfig entries resolve..."
fail=0
for pc in wayland-server cairo pango gdk-pixbuf-2.0 pixman-1 xkbcommon libdrm \
          libinput vulkan xwayland hwdata; do
  if pkg-config --exists "$pc" 2>/dev/null; then echo "  OK   $pc"; else echo "  MISS $pc"; fail=1; fi
done
[[ $fail -eq 0 ]] && echo "All devel deps restored." || { echo "Some deps still missing — run pkg-config --print-errors <name> to trace."; exit 1; }
