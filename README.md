# Evolution Racing Dolphin

Patches to the [Dolphin emulator](https://github.com/dolphin-emu/dolphin) used by the Evolution Racing
F-Zero GX remaster. They extend Dolphin's Graphics Mods system so effects can be drawn on and around the
racing machines (lights, underglow, fire, smoke, speed air, night mode and more).

This repository holds only the Dolphin source changes, published under Dolphin's license (GPL-2.0-or-later,
see `LICENSE`). It contains no game data, textures or effect packs, and no copy of the game. You need your own copy of F-Zero GX.

## Base version

Dolphin commit `409881c34357d0f105fd473167d15ab0bd9c1628`.

## Apply and build

```sh
git clone https://github.com/dolphin-emu/dolphin.git
cd dolphin
git checkout 409881c34357d0f105fd473167d15ab0bd9c1628
git submodule update --init --recursive
git apply /path/to/evolution-racing-dolphin.patch
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j
```

Then build Dolphin as usual for your platform (see Dolphin's own build instructions).

## What it adds

- Custom pixel and vertex shader hooks for Graphics Mods
- Extra camera-facing and world-space quads emitted per machine (`emit_quads`), anchored to each racer
- Per-racer effects for CPU machines, gated by distance
- A depth / scene copy so effects can light the real track
- A per-pixel surface layer painted onto machine hulls
- Gates driven by game state (race vs menus, course, time of day)
- Night / dusk grading, with lights shown only at dusk and night
