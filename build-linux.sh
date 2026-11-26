#!/bin/sh
# Build the Evolution Racing Dolphin "lit17s43erm" (Linux x86-64) from source, the same way the distributed binary was built:
# stock Dolphin 409881c34357d0f105fd473167d15ab0bd9c1628 + evolution-racing-dolphin.patch, compiled inside the Flathub KDE SDK org.kde.Sdk//6.11
# (the distributed build runs in the matching runtime org.kde.Platform//6.11).
#
#   ./build-linux.sh [WORKDIR]      (default ./dolphin) -> WORKDIR/build/Binaries/dolphin-emu
#
# Needs: git, flatpak, and the SDK:  flatpak install --user flathub org.kde.Sdk//6.11
set -e
BASE=409881c34357d0f105fd473167d15ab0bd9c1628
HERE=$(cd "$(dirname "$0")" && pwd -P)
W=${1:-dolphin}
if [ ! -d "$W/.git" ]; then git clone https://github.com/dolphin-emu/dolphin.git "$W"; fi
cd "$W"
git checkout --detach "$BASE"
git submodule update --init --recursive
git apply "$HERE/evolution-racing-dolphin.patch"
W=$(pwd -P)
flatpak run --filesystem="$W" --command=sh org.kde.Sdk//6.11 -c "cd '$W' && mkdir -p build && cd build && \
 cmake .. -G Ninja \
  -DCMAKE_C_FLAGS='-ffile-prefix-map=$W=.' -DCMAKE_CXX_FLAGS='-ffile-prefix-map=$W=.' \
  -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_EVDEV=OFF \
  -DENABLE_TESTS=OFF \
  -DENABLE_AUTOUPDATE=OFF \
  -DUSE_DISCORD_PRESENCE=OFF \
  -DENABLE_ANALYTICS=OFF \
  -DENABLE_ALSA=OFF \
  -DENCODE_FRAMEDUMPS=OFF \
  -DUSE_RETRO_ACHIEVEMENTS=OFF \
  -DDISTRIBUTOR=PC5090-lit \
  -DUSE_SANITIZERS=OFF && \
 ninja dolphin-emu"
echo "built: $W/build/Binaries/dolphin-emu"
