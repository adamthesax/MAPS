// mapscam — every tunable parameter, in one place.
// Annotations in `// [ ... ]` comments make these sliders in the OpenSCAD Customizer.
// Anything DERIVED from these values lives at the bottom under "computed".

include <constants.scad>

/* [Part selection] */
// Which piece to render / export.
part = "assembly"; // [assembly, front, body, carrier, rear, base, shims, spacer]

/* [Lens mount] */
mount_type       = "C";       // [C, CS, blank]
// "thread" = printed 1"-32 thread. "ring" = pocket for a captured metal C-mount ring.
lens_mount_style = "thread";  // [thread, ring]
thread_clearance = 0.15;      // [0:0.05:0.5] radial slop added to printed internal thread
thread_engage    = 5.0;       // [3:0.5:8] axial length of printed thread
ring_bore_d      = 25.6;      // captured-ring pocket bore
ring_depth       = 6.0;       // captured-ring seat depth
ring_grubs       = 3;         // [0:6] radial M2 set screws retaining the ring

/* [Sensor board] */
board_x                = 29;   // PCB width  (X)
board_y                = 29;   // PCB height (Y)
board_hole_pitch_x     = 22;   // mounting hole spacing X
board_hole_pitch_y     = 22;   // mounting hole spacing Y
board_hole_d           = 2.2;  // mounting hole diameter in the PCB
board_thickness        = 1.6;
// PCB front face -> sensor active surface (die top / cover glass). Check your datasheet.
board_to_sensor_surface = 2.5; // [0.5:0.1:6]
standoff_h              = 4.0; // [2:0.5:10] gap from carrier floor to PCB back face
sensor_window_d         = 16;  // clear optical aperture through the whole stack

/* [Enclosure] */
wall        = 3;    // [2:0.5:5] shell wall thickness
inner_clear = 2;    // radial gap: PCB edge -> inner wall
corner_r    = 3;    // outer corner radius

/* [Rear panel] */
gland           = "PG7";  // [none, PG7, PG9, PG11]
panel_cut_x     = 0;      // extra rectangular cutout width  (0 = none)
panel_cut_y     = 0;      // extra rectangular cutout height (0 = none)
desiccant_pocket = true;  // internal pocket for a silica-gel pack

/* [Base mount] */
tripod_insert = true;     // 1/4"-20 heat-set insert in the rear cap floor

/* [Back-focus shims] */
shim_values = [0.1, 0.1, 0.2, 0.2, 0.5];  // one printed shim per entry
shim_nominal = 0.6;       // nominal stack designed-in (sum you can add or remove)

/* [Quality] */
$fn = 64;

// ===========================================================================
// computed — do not edit; these fall out of the parameters above
// ===========================================================================

// footprint
outer_x = board_x + 2*inner_clear + 2*wall;
outer_y = board_y + 2*inner_clear + 2*wall;

// carrier plate
carrier_thk = 3;
carrier_x   = board_x + 2*inner_clear - 0.4;   // slides inside the cavity
carrier_y   = board_y + 2*inner_clear - 0.4;

// inter-module register
reg_inset   = 6;                       // register footprint inset from outer edge
reg_x       = outer_x - 2*reg_inset;
reg_y       = outer_y - 2*reg_inset;
reg_boss_h  = 2.6;                      // male boss height
reg_pocket_h = 3.0;                     // female pocket depth
reg_fit     = 0.15;                     // radial slip fit

ledge_thk   = 2.0;                      // carrier support ledge

// --- Z axis: 0 at the C/CS flange face, +Z toward the sensor / back of camera ---
front_base_thk = 4;                     // flat part of the front plate
front_mate_z   = front_base_thk;        // body front face

sensor_z       = ffd(mount_type);              // target: active surface here
pcb_front_z    = sensor_z - board_to_sensor_surface;
pcb_back_z     = pcb_front_z + board_thickness;
carrier_face_z = pcb_back_z + standoff_h;      // carrier floor, front face
carrier_back_z = carrier_face_z + carrier_thk;

ledge_z        = carrier_face_z - shim_nominal; // body ledge the carrier shims against

rear_reg_h     = reg_pocket_h;
rear_margin    = 4.0;                          // slack behind the carrier
body_length    = carrier_back_z + rear_margin + rear_reg_h - front_mate_z;
min_body_length = 6;

lens_tower_h   = thread_engage + 1.5;
lens_outer_d   = CMOUNT_MAJOR_D + 2*wall + 2;

// ---- sanity checks: fail the render (with -D or `make check`) if the stack is impossible
assert(ledge_z > front_mate_z + 2,
    "Sensor stack lands ahead of / into the body front face. Reduce standoff_h or board_to_sensor_surface, or switch to CS mount.");
assert(body_length > min_body_length,
    "Computed body_length is below min_body_length.");
assert(carrier_x > board_hole_pitch_x + 4 && carrier_y > board_hole_pitch_y + 4,
    "Board mounting holes fall outside the carrier. Increase inner_clear or check board_hole_pitch.");

echo(str("== mapscam ==  mount=", mount_type, " (", lens_mount_style, ")  FFD=", ffd(mount_type), " mm"));
echo(str("   outer      = ", outer_x, " x ", outer_y, " mm"));
echo(str("   body_length= ", body_length, " mm"));
echo(str("   ledge_z    = ", ledge_z, " mm    carrier_face_z = ", carrier_face_z, " mm"));
