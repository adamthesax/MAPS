// mapscam — fastener negatives. Subtract these from solids.
// Every hole is modelled as a cut starting slightly below z=0 and pointing +Z.

include <constants.scad>

// through clearance hole, length h, starting at z=0 going +Z
module screw_clear(size = "M3", h = 20) {
    d = (size == "M2")   ? M2_CLEAR :
        (size == "M2.5") ? M2_5_CLEAR : M3_CLEAR;
    translate([0, 0, -0.01]) cylinder(h = h + 0.02, d = d);
}

// self-tap pilot hole
module screw_tap(size = "M3", h = 10) {
    d = (size == "M2")   ? M2_TAP :
        (size == "M2.5") ? M2_5_TAP : M3_TAP;
    translate([0, 0, -0.01]) cylinder(h = h + 0.02, d = d);
}

// heat-set insert pocket, mouth at z=0, pressed in from -Z (so pocket opens downward)
module heatset(size = "M3", open = "down") {
    d = (size == "M2") ? M2_HEATSET_D : M3_HEATSET_D;
    hh = (size == "M2") ? M2_HEATSET_H : M3_HEATSET_H;
    if (open == "down")
        translate([0, 0, -0.01]) cylinder(h = hh + 0.01, d = d);
    else
        translate([0, 0, -hh]) cylinder(h = hh + 0.01, d = d);
}

// 1/4"-20 photo insert pocket, mouth at z=0 opening -Z
module insert_1420() {
    translate([0, 0, -0.01]) cylinder(h = INSERT_1420_H + 0.01, d = INSERT_1420_D);
}

// countersunk cap head recess (mouth at z=0, opening +Z)
module cap_counterbore(size = "M3", depth = 3) {
    translate([0, 0, -0.01]) cylinder(h = depth + 0.01, d = M3_HEAD_D);
}
