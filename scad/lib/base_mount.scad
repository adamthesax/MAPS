// mapscam — wall / ceiling bracket. A flat plate with four fixing holes and a
// central 1/4"-20 stud pocket; the camera's rear-cap tripod thread screws onto it.
// Hook points (comments) mark where a tilt knuckle / arca rail would attach later.

include <params.scad>
use <util.scad>
use <hardware.scad>

bracket_w = 60;
bracket_d = 40;
bracket_t = 5;

module base_mount() {
    difference() {
        rprism(bracket_w, bracket_d, bracket_t, r = 4);

        // four wall-fixing holes (M4 wood/machine screw), countersunk from the top
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (bracket_w/2 - 8), sy * (bracket_d/2 - 8), 0]) {
                translate([0, 0, -0.01]) cylinder(h = bracket_t + 0.02, d = 4.5);
                translate([0, 0, bracket_t - 2.5]) cylinder(h = 2.6, d1 = 4.5, d2 = 9);
            }

        // central 1/4"-20 insert, pressed from the underside (-Z)
        translate([0, 0, INSERT_1420_H]) mirror([0, 0, 1]) insert_1420();
        // clearance so a screw can pass fully through if used as a pass-through
        translate([0, 0, -0.01]) cylinder(h = bracket_t + 0.02, d = 6.8);
    }
    // --- hook point: a tilt/pan knuckle would bolt to the top face here ---
}

base_mount();
