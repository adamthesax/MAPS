// mapscam — laser vibrometer: every tunable parameter, in one place.
// Annotations in `// [ ... ]` comments make these sliders in the OpenSCAD Customizer.
// Anything DERIVED lives at the bottom under "computed".
//
// KEY IDEA: the vibrometer is the **stock camera enclosure** — the same
// `front_plate` (C-mount), `body`, `sensor_carrier`, `rear_plate`, `base_mount`
// and `shims` from scad/lib/camera/, unchanged — with one part swapped: a
// printed `laser_board` takes the place of the CMOS sensor PCB on the carrier.
// It carries a collimated 650 nm self-mixing laser + a BPW34 pick-off and fires
// forward through the front-plate bore at the target.
//
// This file `include`s the camera params unchanged, so `body_length`, the
// register/interface dims and the three `assert()`s all resolve exactly as for
// `generic_29mm_c` (26.626 mm body). It then adds only the laser_board knobs.
//
// NOTE (mapscam variant-override bug): a generated variant stub's `[params]`
// overrides do NOT reach modules pulled in with `use` (the reused camera parts).
// So the enclosure is always the camera-default `generic_29mm_c`; to change it,
// change the camera defaults, not this variant. `laser_board.scad` `include`s
// THIS file directly, so the knobs below DO take effect for the laser board.
//
// Z convention is the camera's: z = 0 at the C flange face, +Z toward the
// carrier / rear. The laser barrel projects toward -Z, out through the bore.

include <../camera/params.scad>

/* [Part selection] */
part = "assembly"; // [assembly, front, body, carrier, laser_board, rear, base, shims]

/* [Laser board — plate] */
laser_board_thk  = 3.0;   // [2:0.5:6] printed board thickness
// Extra local boss thickness around the laser axis (to seat the TO can).
laser_hub_thk    = 5.0;   // [3:0.5:12]

/* [Laser board — laser + collimator] */
// TO-can outside diameter. TO-18 = 5.6, TO-5/TO-39 = 8.0, 9 mm modules = 9.0.
laser_can_d      = 9.0;   // [5:0.1:12]
laser_can_len    = 10.5;  // [4:0.5:20]
collimator_focal = 4.5;   // [2:0.5:12] documentation only
collimator_d     = 6.35;  // [3:0.05:12] collimating-lens seat bore
collimator_seat  = 2.5;   // [1:0.5:6]
// Barrel outside diameter (must clear the front-plate bore) and the clear beam bore.
laser_barrel_od  = 12.0;  // [6:0.5:15.5]
beam_bore_d      = 4.5;   // [2:0.5:10]
// Where the barrel tip / exit aperture lands, in Z. Negative = ahead of the flange.
// Left a few mm ahead of the flange so the pick-off + BPW34 sit on exposed barrel.
laser_exit_z     = -8.0;  // [-16:0.5:0]

/* [Laser board — pick-off + detector] */
pickoff_angle    = 45;    // [30:1:60] glass pick-off tilt from the optical axis
pickoff_size     = 12;    // [6:0.5:20] coverslip pick-off footprint (square)
pickoff_thk      = 1.2;   // [0.3:0.1:3]
pickoff_setback  = 3.0;   // [1:0.5:8] pick-off centre, this far behind the exit tip
// BPW34 package: "bare" = 2.65 mm ceramic, "leaded" = 5.4 mm through-hole body.
bpw34_pkg        = "leaded";  // [bare, leaded]
bpw34_wall       = "+Y";  // [+Y, -Y] which side of the barrel the detector pocket sits in

/* [Laser board — routing] */
cable_ch_d       = 4.0;   // [2:0.5:8] wire channel from the pockets back toward the carrier

// ===========================================================================
// computed — do not edit; these fall out of the parameters above
// ===========================================================================

bpw34_body_d   = (bpw34_pkg == "bare") ? 2.65 : 5.40;   // detector pocket bore
bpw34_body_h   = (bpw34_pkg == "bare") ? 1.30 : 4.20;   // detector pocket depth

// The laser board bolts to the stock carrier standoffs exactly like a PCB:
// its BACK face sits at pcb_back_z (from scad/lib/camera/params.scad).
lb_back_z      = pcb_back_z;
lb_front_z     = lb_back_z - laser_board_thk;            // board front face
lb_hub_front_z = lb_back_z - laser_hub_thk;              // laser-hub front face

// optical axis, positions in Z (all measured from the flange face)
can_back_z       = lb_back_z;                            // TO can seats to here
can_front_z      = lb_back_z - laser_can_len;
collim_front_z   = can_front_z - collimator_seat;        // collimating lens front
laser_barrel_len = lb_front_z - laser_exit_z;            // -Z projection of the barrel
pickoff_z        = laser_exit_z + pickoff_setback;       // pick-off / BPW34 centre (on exposed barrel)

// ---- extra sanity checks (camera/params.scad already asserts the FFD stack)
assert(laser_barrel_od <= sensor_window_d - 0.5,
    "laser_barrel_od does not clear the front-plate bore (sensor_window_d). Shrink the barrel or widen sensor_window_d.");
assert(laser_exit_z < 0,
    "laser_exit_z must be ahead of the flange (negative) so the beam clears the front plate.");
assert(pickoff_z < -0.5,
    "pick-off lands in / behind the front plate. Reduce pickoff_setback or push laser_exit_z more negative.");
assert(collim_front_z > laser_exit_z + 2,
    "Barrel too short for the can + collimator. Lower board_to_sensor_surface, or push laser_exit_z more negative.");
assert(beam_bore_d < laser_barrel_od - 2*1.5,
    "beam_bore_d leaves no barrel wall. Shrink the bore or grow laser_barrel_od.");

echo(str("== vibrometer ==  stock generic_29mm_c enclosure + printed laser_board"));
echo(str("   laser can D=", laser_can_d, " mm   barrel D=", laser_barrel_od,
         " mm   barrel len=", laser_barrel_len, " mm   exit z=", laser_exit_z, " mm"));
echo(str("   BPW34=", bpw34_pkg, " (pocket ", bpw34_body_d, " mm)   board back z=", lb_back_z, " mm"));
