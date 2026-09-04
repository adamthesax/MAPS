// mapscam — sensor carrier: a tray the bare PCB screws to, referenced to the
// body ledge (and thus to the flange) with a shim stack for back-focus.

include <params.scad>
use <util.scad>
use <hardware.scad>

module sensor_carrier() {
    difference() {
        union() {
            // carrier floor
            translate([0, 0, carrier_face_z])
                rprism(carrier_x, carrier_y, carrier_thk, r = 1.5);
            // PCB standoffs (carrier floor -> PCB back face)
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx * board_hole_pitch_x/2, sy * board_hole_pitch_y/2, pcb_back_z])
                    cylinder(h = standoff_h + 0.01, d = 5);
        }
        // optical aperture
        translate([0, 0, carrier_face_z - 1])
            cylinder(h = carrier_thk + 2, d = sensor_window_d);
        // M2 heat-set pockets in the standoff tops (mouth toward the PCB, -Z)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * board_hole_pitch_x/2, sy * board_hole_pitch_y/2, pcb_back_z])
                heatset("M2", open = "down");
        // rear cable relief notch
        translate([0, -carrier_y/2, carrier_face_z + carrier_thk/2])
            rotate([90, 0, 0]) cylinder(h = 6, d = 7, center = true);
    }
}

sensor_carrier();
