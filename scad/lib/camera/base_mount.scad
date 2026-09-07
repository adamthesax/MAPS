// mapscam — wall / ceiling bracket. A flat plate with four countersunk fixing
// holes and a central boss that carries a 1/4"-20 brass heat-set insert. Thread a
// stud (or the camera's tripod screw) into the insert; per docs/assembly.md the
// camera's rear-cap 1/4"-20 then threads onto the protruding stud.
// Hook points (comments) mark where a tilt knuckle / arca rail would attach later.

include <params.scad>
use <../util.scad>
use <../hardware.scad>

bracket_w = 60;
bracket_d = 40;
bracket_t = 6;                          // flat plate

hub_floor = 3;                          // solid plastic behind the seated insert
hub_d     = INSERT_1420_D + 8;          // boss O.D. — 4 mm wall around the Ø8 insert
hub_h     = INSERT_1420_H + hub_floor - bracket_t;   // boss height above the top face
hub_top   = bracket_t + hub_h;          // z of the boss top = INSERT_1420_H + hub_floor

module base_mount() {
    difference() {
        union() {
            rprism(bracket_w, bracket_d, bracket_t, r = 4);
            // Central boss on the exposed (+Z) face, tall enough to bury the
            // insert. Flared root so the 1/4"-20 load doesn't hinge on a sharp step.
            translate([0, 0, bracket_t]) {
                cylinder(h = 2, d1 = hub_d + 4, d2 = hub_d);
                cylinder(h = hub_h, d = hub_d);
            }
        }

        // four wall-fixing holes (M4 wood/machine screw), countersunk from the top
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (bracket_w/2 - 8), sy * (bracket_d/2 - 8), 0]) {
                translate([0, 0, -0.01]) cylinder(h = bracket_t + 0.02, d = 4.5);
                translate([0, 0, bracket_t - 2.5]) cylinder(h = 2.6, d1 = 4.5, d2 = 9);
            }

        // central 1/4"-20 heat-set insert: blind Ø8 pocket, mouth at the boss top,
        // pressed in from +Z, hub_floor of solid plastic behind it
        translate([0, 0, hub_top]) mirror([0, 0, 1]) insert_1420();
        // lead-in chamfer so the insert starts square
        translate([0, 0, hub_top - 1])
            cylinder(h = 1.01, d1 = INSERT_1420_D, d2 = INSERT_1420_D + 2);
        // vent: lets trapped air escape while the insert is pressed, and lets you
        // push a seized insert back out. Too small to pass a 1/4"-20 — drill it
        // through if you want a pass-through stud instead of the insert.
        translate([0, 0, -0.01]) cylinder(h = hub_top + 0.02, d = 4);
    }
    // --- hook point: a tilt/pan knuckle would bolt to the boss top face here ---
}

base_mount();
