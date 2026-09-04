# Repo skills

Project-specific [Claude Code](https://claude.com/claude-code) skills for `mapscam`, the
camera-enclosure repo of **M.A.P.S. (Modular Awesome Photonic System)**. Claude loads one
automatically when a request matches its `description`; you can also invoke one by name.

| Skill | For |
|---|---|
| `add-camera-variant` | a new sensor board size / hole pitch / mount type → a new `components/camera/*.toml` |
| `add-lens-body` | a printed C/CS lens barrel for a bought element → a new `components/lens/*.toml` |
| `render-and-qc` | render parts to STL + PNG and sanity-check the geometry and stack numbers |
| `tune-backfocus` | work the flange-focal-distance stack from a datasheet number or a focus error |
| `print-prep` | generate a per-component print job sheet (orientation, slicer, hardware) |
| `new-module` | add a whole new printed enclosure section, honouring the module interface |

Each skill is `<name>/SKILL.md` with YAML frontmatter (`name`, `description`) and a short
procedure. Keep them terse and pointed at real files/targets; update them when the build
system or the module contract changes.

Components are config-driven — one TOML per component under `components/`, expanded by
`tools/gen.py` (`make gen`). See [docs/components.md](../../docs/components.md).
