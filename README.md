# Evolution Racing Dolphin

> **Looking to play?** This repository is source code only. Download the ready-to-play Evolution Racing Dolphin
> (Linux and Windows) from the **Getting started** page of the Evolution Racing hub - you do not need to build anything.

Patches to the [Dolphin emulator](https://github.com/dolphin-emu/dolphin) used by the Evolution Racing
F-Zero GX remaster. They extend Dolphin's Graphics Mods system so effects can be drawn on and around the
racing machines (lights, underglow, fire, smoke, speed air, night mode and more), and add a 3D scenery
loader that draws full-quality glTF models around a course outside the game's own memory.

This repository holds only the Dolphin source changes, published under Dolphin's license (GPL-2.0-or-later,
see `LICENSE`). It contains no game data, textures, effect packs or 3D assets, and no copy of the game.
You need your own copy of F-Zero GX.

## Versions

Every distributed build has a tag `er-<build>` and a GitHub Release pointing at the exact source and build
script of that build. This tree is build **lit17s43ermbtg**.

- Base: Dolphin commit `409881c34357d0f105fd473167d15ab0bd9c1628` (with its submodules at that commit)
- Changes: `evolution-racing-dolphin.patch` (stock -> lit17s43ermbtg)
- Build: `build-linux.sh` (the exact CMake options of the distributed Linux build)

## Apply and build

```sh
./build-linux.sh            # clones Dolphin 409881c34357d0f105fd473167d15ab0bd9c1628, applies the patch, builds in org.kde.Sdk//6.11
```

or by hand:

```sh
git clone https://github.com/dolphin-emu/dolphin.git
cd dolphin
git checkout 409881c34357d0f105fd473167d15ab0bd9c1628
git submodule update --init --recursive
git apply /path/to/evolution-racing-dolphin.patch
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build --target dolphin-emu
```

## What it adds

- Custom pixel and vertex shader hooks for Graphics Mods
- Extra camera-facing and world-space quads emitted per machine (`emit_quads`), anchored to each racer
- Per-racer effects for CPU machines, gated by distance
- A depth / scene copy so effects can light the real track
- A per-pixel surface layer painted onto machine hulls
- Gates driven by game state (race vs menus, course, time of day)
- Night / dusk grading, with lights shown only at dusk and night
- 3D scenery: glTF models placed per course from a JSON file, lit to the course, fogged like the game
