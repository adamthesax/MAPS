// mapscam — the shared inter-module mechanical interface.
//
// Every module (front / body / rear) carries the same rectangular register and
// the same 4-screw corner pattern on its mating face, so any front pairs with
// any body pairs with any rear. Assembly is keyed by a chamfered index notch on +X.

include <params.scad>
use <../util.scad>
use <../hardware.scad>

ear_d = 7;   // corner screw-boss diameter

// The four mate-screw centres, in the XY plane (near the corners).
function mate_screw_xy() = [
    for (sx = [-1, 1], sy = [-1, 1])
        [sx * (outer_x/2 - 3.5), sy * (outer_y/2 - 3.5)]
];

// Corner screw bosses, z = 0 .. h.
module corner_ears(h) {
    for (p = mate_screw_xy())
        translate([p[0], p[1], 0]) cylinder(h = h, d = ear_d);
}

// Male register boss, solid, z = 0 .. reg_boss_h, with the index key on +X.
module reg_boss() {
    union() {
        rprism(reg_x - 2*reg_fit, reg_y - 2*reg_fit, reg_boss_h, r = max(0.5, corner_r - 1));
        translate([reg_x/2 - reg_fit - 1, 0, 0])
            rprism(3, 6, reg_boss_h, r = 0.6);
    }
}

// Female register pocket: a cut, mouth at z = 0, opening +Z.
module reg_pocket() {
    union() {
        translate([0, 0, -0.01])
            rprism(reg_x, reg_y, reg_pocket_h + 0.02, r = max(0.5, corner_r - 1));
        translate([reg_x/2 - 1, 0, -0.01])
            rprism(3 + 2*reg_fit, 6 + 2*reg_fit, reg_pocket_h + 0.02, r = 0.6);
    }
}

// Screw holes across a mating face.
//   mode = "clear"  -> through clearance holes, length h, from z = 0 toward +Z
//   mode = "insert-up"   -> heat-set pockets opening toward +Z (mouth at z = 0)
//   mode = "insert-down" -> heat-set pockets opening toward -Z (mouth at z = 0)
module mate_screws(mode = "clear", h = 20) {
    for (p = mate_screw_xy())
        translate([p[0], p[1], 0])
            if      (mode == "insert-up")   heatset("M3", open = "up");
            else if (mode == "insert-down") heatset("M3", open = "down");
            else                            screw_clear("M3", h);
}
