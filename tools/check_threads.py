#!/usr/bin/env python3
"""Printable-thread lint (`make check-threads`). See docs/printable-threads.md.

Every thread in scad/ must either go through print_thread() (scad/lib/threads.scad,
which enforces the FDM rules with asserts) or be an INTERCHANGE thread that has to
mate a bought part — tagged `// interchange: <standard>` within the 3 lines above the
raw BOSL2 call. Anything else is a printed thread that skipped the rules.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW = re.compile(r"\b(threaded_rod|threaded_nut|trapezoidal_threaded_rod|"
                 r"trapezoidal_threaded_nut|acme_threaded_rod|buttress_threaded_rod)\s*\(")
EXEMPT = {ROOT / "scad/lib/threads.scad"}

bad = []
for f in sorted((ROOT / "scad").rglob("*.scad")):
    if f in EXEMPT:
        continue
    lines = f.read_text().splitlines()
    for i, line in enumerate(lines):
        code = line.split("//", 1)[0]
        if RAW.search(code) and not any("interchange:" in l for l in lines[max(0, i - 3):i + 1]):
            bad.append(f"{f.relative_to(ROOT)}:{i + 1}: {line.strip()}")

if bad:
    print("Untagged raw BOSL2 thread(s). Use print_thread() from scad/lib/threads.scad, or")
    print("if it must mate a bought part, add `// interchange: <standard>` above it:")
    print("\n".join("   " + b for b in bad))
    sys.exit(1)
print("   threads OK — printed pairs use print_thread(), the rest are tagged interchange")
