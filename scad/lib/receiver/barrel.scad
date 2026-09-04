// mapscam receiver — barrel: holds the Ø80 optic at the front, telescopes over
// the stem draw tube at the rear, and carries the split clamp that locks focus.
//
// Authored in its own frame: z = 0 is the optic's rear (flat) face, +Z runs back
// toward the body, the optic and its retainer sit at -Z. `dispatch.scad` slides the
// whole part to -focus_nominal for the assembly preview.

include <params.scad>
use <../util.scad>
use <../hardware.scad>

collar_od  = collar_bore + 2*wall + 8;      // stepped-down rear that rides the stem
taper_len  = 12;                            // blend from barrel OD down to the collar
clamp_ear  = [9, 7, 16];                    // one pinch lug: [radial, tangential, axial]
cell_h     = element_edge_thk + retainer_thk + front_rim;

module barrel() {
    collar_z0 = barrel_len - collar_len;
    slot_z0   = collar_z0 - taper_len - 4;      // slots run from here to the rear face

    difference() {
        union() {
            // lens cell + main tube
            translate([0, 0, -cell_h]) cylinder(h = cell_h + collar_z0 - taper_len, d = barrel_od_c);
            // taper down to the slide collar
            translate([0, 0, collar_z0 - taper_len])
                cylinder(h = taper_len, d1 = barrel_od_c, d2 = collar_od);
            // the slide collar
            translate([0, 0, collar_z0]) cylinder(h = collar_len, d = collar_od);
            // one solid clamp block fused to the collar; the slot below splits it
            // into two pinch lugs (cut faces are internal -> stays 2-manifold).
            translate([0, -(clamp_gap/2 + clamp_ear[1]), barrel_len - clamp_ear[2]])
                cube([collar_od/2 + clamp_ear[0],
                      2*(clamp_gap/2 + clamp_ear[1]),
                      clamp_ear[2]]);
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
        // taper the bore in to meet the collar bore (stays inside the outer taper)
        translate([0, 0, collar_z0 - taper_len - 0.01])
            cylinder(h = taper_len + 0.02, d1 = barrel_bore, d2 = collar_bore);
        // close-fit slide collar + lead-in chamfer
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

        // ---- split clamp: ONE +X slot; the collar becomes a C and flexes shut,
        //      and the same cut divides the clamp block into two lugs
        translate([-1, -clamp_gap/2, slot_z0])
            cube([collar_od/2 + clamp_ear[0] + 2, clamp_gap, barrel_len - slot_z0 + 1]);
        // pinch screw: clearance through both lugs, hex nut trap on -Y
        scr_x = collar_od/2 - 2 + clamp_ear[0]/2;
        scr_z = barrel_len - clamp_ear[2]/2;
        translate([scr_x, clamp_gap/2 + clamp_ear[1] + 1, scr_z])
            rotate([90, 0, 0])
                cylinder(h = 2*clamp_ear[1] + clamp_gap + 3, d = M3_CLEAR, center = true);
        translate([scr_x, -(clamp_gap/2 + clamp_ear[1]) + 1.4, scr_z])
            rotate([90, 0, 0])
                cylinder(h = 3.2, d = 6.4, $fn = 6);
    }
}

barrel();
