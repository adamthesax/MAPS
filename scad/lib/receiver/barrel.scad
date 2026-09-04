// mapscam receiver — barrel: holds the Ø80 optic at the front, telescopes over the
// stem draw tube at the rear. The rear collar is a slit collet; the separate
// `clamp` ring squeezes it onto the stem to lock focus.
//
// Authored in its own frame: z = 0 is the optic's rear (flat) face, +Z runs back
// toward the body, the optic and its retainer sit at -Z. `dispatch.scad` slides the
// whole part to -focus_nominal for the assembly preview.

include <params.scad>
use <../util.scad>
use <../hardware.scad>

taper_len = 12;                            // blend from barrel OD down to the collet
cell_h    = element_edge_thk + retainer_thk + front_rim;

module barrel() {
    collar_z0 = barrel_len - collar_len;
    slot_z0   = collar_z0 + 4;             // collet slots: stay joined at the base

    difference() {
        union() {
            // lens cell + main tube
            translate([0, 0, -cell_h]) cylinder(h = cell_h + collar_z0 - taper_len, d = barrel_od_c);
            // taper down to the collet
            translate([0, 0, collar_z0 - taper_len])
                cylinder(h = taper_len, d1 = barrel_od_c, d2 = collar_od);
            // the collet
            translate([0, 0, collar_z0]) cylinder(h = collar_len, d = collar_od);
        }

        // ---- optical path -------------------------------------------------
        // element pocket — rear face seats on the z = 0 shoulder
        translate([0, 0, -element_edge_thk - 0.01])
            cylinder(h = element_edge_thk + 0.02, d = pocket_bore);
        // retainer counterbore ahead of the element
        translate([0, 0, -(element_edge_thk + retainer_thk) - 0.01])
            cylinder(h = retainer_thk + 0.02, d = pocket_bore);
        // front clear aperture through the rim
        translate([0, 0, -cell_h - 1])
            cylinder(h = cell_h - element_edge_thk + 1.01, d = clear_aperture_d);
        // main bore behind the element, up to where the outer wall starts tapering
        translate([0, 0, -0.01])
            cylinder(h = collar_z0 - taper_len + 0.02, d = barrel_bore);
        // taper the bore in to meet the collet bore (stays inside the outer taper)
        translate([0, 0, collar_z0 - taper_len - 0.01])
            cylinder(h = taper_len + 0.02, d1 = barrel_bore, d2 = collar_bore);
        // close-fit collet bore + lead-in chamfer
        translate([0, 0, collar_z0 - 0.01])
            cylinder(h = collar_len + 0.02, d = collar_bore);
        translate([0, 0, barrel_len - 2.5])
            cylinder(h = 2.51, d1 = collar_bore, d2 = collar_bore + 4);

        // ---- lens retainer: 3 radial M3 set screws into the ring OD -------
        for (i = [0:2])
            rotate([0, 0, 120*i + 60])
                translate([0, 0, -(element_edge_thk + retainer_thk/2)])
                    rotate([0, 90, 0])
                        cylinder(h = barrel_od_c, d = M3_TAP);

        // ---- collet relief: 3 axial slots, open at the rear face, joined at base
        for (a = [0, 120, 240])
            rotate([0, 0, a])
                translate([collar_bore/2 - 1, -clamp_relief/2, slot_z0])
                    cube([collar_od, clamp_relief, barrel_len - slot_z0 + 1]);
    }
}

barrel();
