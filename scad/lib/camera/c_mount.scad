// mapscam — the C / CS lens interface, both realisations from one source.
//
//   lens_mount_style = "thread" : printed internal 1"-32 thread (BOSL2)
//   lens_mount_style = "ring"   : plain pocket for a captured metal C-mount ring,
//                                 retained by radial M2 grub screws
//
// Convention: z0 is the flange face (lens seating shoulder). The interface
// extends toward -Z (toward the lens). FFD is measured from z0.

include <params.scad>
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
use <../hardware.scad>

// Optical through-hole along Z.
module lens_bore(len = 60) {
    translate([0, 0, -len/2]) cylinder(h = len, d = sensor_window_d);
}

// Raised lens tower solid — union this before cutting the interface.
module lens_tower(z0 = 0) {
    if (mount_type != "blank")
        translate([0, 0, z0 - lens_tower_h])
            cylinder(h = lens_tower_h + 0.01, d = lens_outer_d);
}

// Negative for the lens interface. Subtract from the tower + plate.
module lens_interface_cut(z0 = 0) {
    if (mount_type != "blank") {
        if (lens_mount_style == "thread") {
            translate([0, 0, z0 - thread_engage/2])
                threaded_rod(d = CMOUNT_MAJOR_D + 2*thread_clearance,
                             l = thread_engage + 0.02,
                             pitch = CMOUNT_PITCH,
                             internal = true,
                             $fn = 96);
        } else {
            translate([0, 0, z0 - ring_depth])
                cylinder(h = ring_depth + 0.02, d = ring_bore_d);
            if (ring_grubs > 0)
                for (i = [0 : ring_grubs - 1])
                    rotate([0, 0, i * 360 / ring_grubs])
                        translate([0, 0, z0 - ring_depth/2])
                            rotate([0, 90, 0])
                                cylinder(h = lens_outer_d + 2, d = M2_TAP, center = true);
        }
    }
}

// Standalone C-to-CS 5 mm spacer ring (part = "spacer").
module cs_spacer() {
    difference() {
        cylinder(h = C_CS_SPACER, d = lens_outer_d);
        translate([0, 0, -0.01]) cylinder(h = C_CS_SPACER + 0.02, d = sensor_window_d);
        // female thread on top, male stub on bottom is left to the metal-ring build;
        // for the printed build this is just a plain spacer between plate and lens.
    }
}
