// mapscam — laser vibrometer: the printed laser board.
//
// This is the ONE part that makes a vibrometer instead of a camera. It bolts to
// the stock `sensor_carrier` standoffs exactly like a CMOS sensor PCB (same
// `board_hole_pitch_x/y`, same M2 pattern, back face at `pcb_back_z`), so every
// other module — front / body / carrier / rear / base / shims — is the stock
// camera part, unchanged.
//
// It carries, on the optical axis, a forward-firing barrel that reaches through
// the front-plate bore and a few mm past the flange:
//   * a TO-can laser-diode pocket (press fit + M2 grub screw) at the rear,
//   * an aspheric collimating-lens seat,
//   * a clear beam bore to the exit aperture,
//   * a thin glass pick-off at `pickoff_angle` on the exposed barrel tip,
//   * a BPW34 detector pocket in the barrel wall at the pick-off,
//   * a cable channel back toward the carrier / rear gland.

include <params.scad>
use <../util.scad>
use <../hardware.scad>

module laser_board() {
    hub_d = laser_can_d + 6;
    wy    = (bpw34_wall == "-Y") ? -1 : 1;

    difference() {
        union() {
            // board plate — same outline as a sensor PCB
            translate([0, 0, lb_front_z])
                rprism(board_x, board_y, laser_board_thk, r = 1.5);
            // local hub around the laser axis (seats the TO can)
            translate([0, 0, lb_hub_front_z])
                cylinder(h = laser_hub_thk, d = hub_d);
            // forward barrel, through the front-plate bore and past the flange
            translate([0, 0, laser_exit_z])
                cylinder(h = laser_barrel_len + 0.01, d = laser_barrel_od);
        }

        // --- laser + collimator, bored from the rear (+Z) ---
        // TO-can pocket
        translate([0, 0, can_front_z])
            cylinder(h = laser_can_len + 0.02, d = laser_can_d);
        // wire relief straight out the back
        translate([0, 0, can_back_z - 0.01])
            cylinder(h = 4, d = laser_can_d - 3.5);
        // collimating-lens seat, just ahead of the can
        translate([0, 0, collim_front_z])
            cylinder(h = collimator_seat + 0.02, d = collimator_d);
        // clear beam bore: collimator front -> exit tip
        translate([0, 0, laser_exit_z - 0.01])
            cylinder(h = collim_front_z - laser_exit_z + 0.02, d = beam_bore_d);
        // exit aperture relief at the tip
        translate([0, 0, laser_exit_z - 0.01])
            cylinder(h = 1.6, d = beam_bore_d + 2);

        // M2 grub screw clamping the can (radial, +X)
        translate([0, 0, can_front_z + laser_can_len/2])
            rotate([0, 90, 0]) cylinder(h = board_x, d = M2_TAP, center = true);

        // 45-deg glass pick-off slot across the beam, on the exposed tip
        translate([0, 0, pickoff_z])
            rotate([pickoff_angle, 0, 0])
                cube([pickoff_size, pickoff_size, pickoff_thk + 0.4], center = true);

        // BPW34 detector pocket in the barrel wall at the pick-off
        translate([0, wy * (laser_barrel_od/2 - bpw34_body_h + 0.01), pickoff_z])
            rotate([wy * 90, 0, 0]) cylinder(h = bpw34_body_h + 4, d = bpw34_body_d);

        // 4 mounting holes — M2 clearance, board bolts to the carrier standoffs
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * board_hole_pitch_x/2, sy * board_hole_pitch_y/2, lb_front_z - 0.01])
                cylinder(h = laser_board_thk + 0.02, d = M2_CLEAR);

        // wire pass-through in the plate (laser + BPW34 leads route along the
        // barrel, through here, to the carrier / rear-gland side)
        translate([0, wy * (hub_d/2 + cable_ch_d/2 + 0.5), lb_front_z - 0.01])
            cylinder(h = laser_board_thk + 0.02, d = cable_ch_d);
    }
}

laser_board();
