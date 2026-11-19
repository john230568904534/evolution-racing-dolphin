#!/bin/sh
# Build the Evolution Racing Dolphin "lit17s35mw" for Windows x64 from source, the same way the distributed zip was built:
# stock Dolphin 409881c34357d0f105fd473167d15ab0bd9c1628 + evolution-racing-dolphin.patch (the effects, same as the Linux build) +
# windows/evolution-racing-dolphin-windows.patch (the MinGW-w64 port: MSVC-only code paths, the D3D backends left out -
# Vulkan and OpenGL remain), cross-compiled with MinGW-w64 in a Fedora 44 container (windows/Containerfile).
#
#   ./build-windows.sh [WORKDIR]     (default ./dolphin-win) -> WORKDIR/dist/dolphin = Dolphin.exe + DLLs + Sys
#
# Needs: git and podman (or docker: DOCKER=docker ./build-windows.sh).
set -e
BASE=409881c34357d0f105fd473167d15ab0bd9c1628
HERE=$(cd "$(dirname "$0")" && pwd -P)
W=${1:-dolphin-win}; C=${DOCKER:-podman}
mkdir -p "$W"; W=$(cd "$W" && pwd -P)
if [ ! -d "$W/src/.git" ]; then
  git init -q "$W/src" && git -C "$W/src" remote add origin https://github.com/dolphin-emu/dolphin.git
  git -C "$W/src" fetch -q --depth 1 origin "$BASE" && git -C "$W/src" checkout -q --detach FETCH_HEAD
  git -C "$W/src" submodule update --init --recursive --depth 1
  git -C "$W/src" apply "$HERE/evolution-racing-dolphin.patch"
  git -C "$W/src" apply "$HERE/windows/evolution-racing-dolphin-windows.patch"
fi
$C build -t er-dolphin-mingw -f "$HERE/windows/Containerfile" "$HERE/windows"
$C run --rm -v "$W:/w:Z" -v "$HERE/windows:/t:ro,Z" er-dolphin-mingw sh -c '
set -e; mkdir -p /w/build && cd /w/build
[ -f build.ninja ] || cmake ../src -G Ninja -DCMAKE_TOOLCHAIN_FILE=/t/mingw.cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_TESTS=OFF -DENABLE_AUTOUPDATE=OFF -DUSE_DISCORD_PRESENCE=OFF -DENABLE_ANALYTICS=OFF -DENCODE_FRAMEDUMPS=OFF -DUSE_RETRO_ACHIEVEMENTS=OFF -DUSE_MGBA=OFF -DUSE_UPNP=OFF -DDISTRIBUTOR=EvolutionRacing -DRC_CLIENT_SUPPORTS_RAINTEGRATION=OFF
ninja dolphin-emu
R=/usr/x86_64-w64-mingw32/sys-root/mingw; B=/w/build/Binaries; D=/w/dist/dolphin
rm -rf /w/dist; mkdir -p $D
cp $B/dolphin-emu.exe $D/Dolphin.exe; x86_64-w64-mingw32-strip $D/Dolphin.exe
cp -rL $B/Sys $B/Languages $B/Licenses $B/COPYING $D/
for p in platforms/qwindows.dll styles/qmodernwindowsstyle.dll imageformats/qsvg.dll imageformats/qico.dll iconengines/qsvgicon.dll; do
  [ -f $R/lib/qt6/plugins/$p ] && { mkdir -p $D/$(dirname $p); cp $R/lib/qt6/plugins/$p $D/$p; }
done
printf "[Paths]\nPlugins = .\n" > $D/qt.conf
need(){ x86_64-w64-mingw32-objdump -p "$1" | sed -n "s/.*DLL Name: //p"; }
todo="$(find $D -name "*.exe" -o -name "*.dll")"; seen=""
while [ -n "$todo" ]; do set -- $todo; f=$1; shift; todo="$*"
  for d in $(need $f); do case " $seen " in *" $d "*) continue;; esac; seen="$seen $d"
    if [ -f $R/bin/$d ]; then cp $R/bin/$d $D/; todo="$todo $D/$d"; fi; done; done
x86_64-w64-mingw32-strip $D/*.dll $D/*/*.dll 2>/dev/null || true'
echo "built: $W/dist/dolphin (Dolphin.exe + the MinGW-w64 / Qt DLLs it needs)"
