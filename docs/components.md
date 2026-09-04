# Components & the config system

Every buildable thing in `mapscam` — a camera enclosure, a printed lens barrel — is one
small **TOML file** under `components/`. `tools/gen.py` expands each into an OpenSCAD stub
and the build wiring. **The TOML is the single source of truth.**

```
components/
  _type/
    camera.toml            # type definition (hand-edited)
    lens.toml
  camera/
    generic_29mm_c.toml    # one component  (hand-edited)
    ...
  lens/
    achromat_12mm_c.toml
```

## Generated files — never hand-edit

| File | Committed? | What |
|---|---|---|
| `scad/variants/<name>.scad` | yes | `include params` → overrides → `include dispatch` stub; the `make` / Customizer target |
| `components.json` | yes | flat manifest of every type + component |
| `build/components.mk` | no (git-ignored) | `ALL_VARIANTS`, `PARTS_<name>`, `PREVIEW_CAM_<name>`, `CHECK_JOBS`, … included by the `Makefile` |
| `README.md` (between `<!-- … GENERATED:components … -->`) | yes | the component tables |

Run `make gen` after editing any TOML. `make` and `make check` run it automatically;
`make check` also runs `python3 tools/gen.py --check`, which fails if a committed generated
file is stale (so CI catches a forgotten `make gen`).

## Component type — `components/_type/<type>.toml`

```toml
lib         = "scad/lib/camera"                   # module dir for this type
entry       = "scad/camera.scad"                  # Customizer entry for the type
params_file = "scad/lib/camera/params.scad"       # generator validates [params] keys against this
parts       = ["front", "body", "carrier", "rear", "base", "shims"]
check_parts = ["front", "body", "carrier", "rear", "base", "shims", "assembly"]
preview_cam = "0,0,18,62,0,23,235"                # --camera=<…> for the preview PNG
```

A type's SCAD side is a `lib/<type>/` directory with `params.scad` (plain assignments +
Customizer annotations + a derived section + `assert()`s) and `dispatch.scad` (a
`part == "…"` selector plus an `assembly` preview), fronted by `scad/<type>.scad`.

## Component — `components/<type>/<name>.toml`

```toml
type  = "camera"
title = "29 mm board, C-mount, printed thread"

[params]                     # keys map 1:1 to params.scad variables (and to -D overrides)
mount_type         = "C"
board_x            = 29
board_hole_pitch_x = 22
```

- `name` is the filename stem; it must be unique across all types.
- List only parameters that **differ** from the type's `params.scad` defaults.
- Values become SCAD literals: string → `"…"`, bool → `true`/`false`, number verbatim,
  array → `[a, b, c]`.
- An unknown key, or a file in the wrong `type/` directory, fails `make gen`.

## Add a component

1. `components/<type>/<slug>.toml` — `type`, `title`, `[params]`.
2. `make gen` — writes `scad/variants/<slug>.scad` and the wiring.
3. `make check` — asserts + `--hardwarnings` for every part.
4. `make <slug>` — `stl/<slug>-*.stl` + `renders/<slug>.png`. Read the PNG and the echoed
   stack numbers.

Removing a TOML and re-running `make gen` deletes its orphaned stub.

## Add a component type

1. `scad/lib/<type>/params.scad`, `dispatch.scad`, and the module files. Shared helpers stay
   in `scad/lib/` (`constants.scad`, `util.scad`, `hardware.scad`) and are included as
   `../constants.scad` from inside `lib/<type>/`.
2. `scad/<type>.scad` — `include <lib/<type>/params.scad>; include <lib/<type>/dispatch.scad>;`
3. `components/_type/<type>.toml` — see above.
4. `components/<type>/*.toml`, then `make gen && make check`.
