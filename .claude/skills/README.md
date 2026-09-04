# Repo skills

Project-specific [Claude Code](https://claude.com/claude-code) skills for `mapscam`, the
camera-enclosure repo of **M.A.P.S. (Modular Awesome Photonic System)**. Claude loads one
automatically when a request matches its `description`; you can also invoke one by name.

| Skill | For |
|---|---|
| `add-camera-variant` | a new sensor board size / hole pitch / mount type → a full new variant |
| `render-and-qc` | render parts to STL + PNG and sanity-check the geometry and stack numbers |
| `tune-backfocus` | work the flange-focal-distance stack from a datasheet number or a focus error |
| `print-prep` | generate a per-variant print job sheet (orientation, slicer, hardware) |
| `new-module` | add a whole new printed section to the stack, honouring the module interface |

Each skill is `<name>/SKILL.md` with YAML frontmatter (`name`, `description`) and a short
procedure. Keep them terse and pointed at real files/targets; update them when the build
system or the module contract changes.
