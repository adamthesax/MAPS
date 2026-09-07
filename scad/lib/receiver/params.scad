// mapscam — vibrometer receiver optic: every tunable parameter, in one place.
// Annotations in `// [ ... ]` comments make these sliders in the OpenSCAD Customizer.
// Anything DERIVED lives at the bottom under "computed".
//
// What this is: a large-aperture receiver telescope for the M.A.P.S. laser
// vibrometer (see docs/receiver-optic.md). A bought Ø80 mm f≈150 mm optic focuses
// the returned beam through a small 808 nm bandpass filter onto the detector on a
// stock mapscam camera. By default (mount = "C") the `stem` ends in a male 1"-32
// thread and screws into a stock generic_29mm_c front plate — no custom plate;
// mount = "flange" gives it a bolt-on front-plate register instead.
//
// FIXED FOCUS for now — one rigid tube: `stem` (camera interface + filter cell)
// plugs into the rear of `barrel` (holds the optic) and is pinned with 3 screws.
// Focus control comes in a later pass, most likely by moving the element inside
// the barrel.
//
// Convention: z = 0 is the SEATING PLANE — the "C" shoulder, or the "flange" front
// face, whichever meets the camera. +Z points INTO the camera (bare thread only,
// then the detector — nothing of the receiver reaches past here); the filter cell
// and the optics are all at -Z, out toward the target. This mirrors
// scad/lib/camera/interface.scad's Z convention.

include <../constants.scad>

/* [Part selection] */
part = "assembly"; // [assembly, stem, barrel, lens_retainer, filter_ring]

/* [Camera interface] */
// How the receiver attaches to the mapscam camera:
//   "C"      : male 1"-32 thread — screws straight into a stock generic_29mm_c
//              front plate (lens_mount_style = "thread"), exactly like any C-mount
//              lens. No custom front plate. z = 0 is the seating shoulder.
//   "flange" : the receiver carries its own front plate (a verbatim copy of the
//              camera register + 4-corner M3 pattern) and bolts to a bare body.
mount            = "C";     // [C, flange]
thread_engage    = 5.0;     // [3:0.5:8]    axial length of the male 1"-32 thread   ("C")
thread_clearance = 0.15;    // [0:0.05:0.5] radial slop on the printed external thread ("C")
// Footprint of the mapscam body — mount = "flange" only. MUST match that body's
// outer_x / outer_y (= board + 2*inner_clear + 2*wall). 39 = the generic 29 mm board.
body_outer_x = 39;   // [30:0.5:80]
body_outer_y = 39;   // [30:0.5:80]

/* [Main optic] */
element_d          = 80;    // optic outside diameter
element_edge_thk   = 6;     // rim / edge thickness = how deep the seat pocket is   [GUESS — measure]
element_sag        = 8;     // convex face bulge past the rim plane — reference only  [GUESS — measure]
clear_aperture_d   = 74;    // clear optical bore through the seat rim
element_fit        = 0.30;  // [0:0.05:0.6] radial slip fit: pocket bore vs element_d
focal_length       = 150;   // nominal lens focal length — reference / echo only

/* [Layout] */
// seating plane (z = 0) -> optic rear (flat) face. Fixed; the camera shim stack
// takes up the detector-position slack, same as a normal lens.
flange_to_optic = 150;   // [80:1:260]
// exposed length of the `stem` neck between the seating plane and the barrel rear.
stem_neck_len   = 18;    // [8:1:60]

/* [stem <-> barrel joint] */
join_len    = 18;    // [8:1:40] axial overlap of the stem neck in the barrel socket
join_fit    = 0.30;  // [0.1:0.05:0.6] radial slip fit: socket bore vs neck OD
join_screw  = "M3";  // [M3, M2.5]  3 radial screws pin the joint

/* [808 nm filter] */
// 808 nm narrow band-pass, circular Ø8.0 x 0.55 mm glass (CWL 808+/-2, HBW 25 nm).
filter_d       = 8.0;   // bandpass filter outside diameter
filter_thk     = 0.55;  // filter thickness (from the datasheet)
filter_clear_d = 6.0;   // field stop / clear aperture (seat inner diameter)
filter_fit     = 0.30;  // [0:0.05:0.6] radial slip fit for the filter in its pocket

/* [Enclosure] */
wall            = 3;    // [2:0.5:6] barrel / stem wall thickness
barrel_od       = 0;    // 0 = auto (element_d + 2*wall + 4); or pin a value in mm
front_rim       = 2.0;  // [0:0.5:6] barrel material ahead of the lens retainer
retainer_thk    = 4.0;  // [2:0.5:8] lens retainer ring thickness

/* [Quality] */
$fn = 64;

// assembly-preview only: how far to pull the parts apart along Z (0 = show fitted).
explode_gap = 40;

// ===========================================================================
// computed — do not edit; these fall out of the parameters above
// ===========================================================================

is_cmount = (mount == "C");

// ---- "flange" interface: register + bolt pattern (copied verbatim from
//      scad/lib/camera/interface.scad so a stock body mates unchanged) ----
outer_x    = body_outer_x;
outer_y    = body_outer_y;
corner_r   = 3;
reg_inset  = 6;
reg_x      = outer_x - 2*reg_inset;
reg_y      = outer_y - 2*reg_inset;
reg_boss_h = 2.6;
reg_fit    = 0.15;
ear_d      = 7;
flange_thk = 4;     // = camera front_base_thk

function mate_screw_xy() = [
    for (sx = [-1, 1], sy = [-1, 1])
        [sx * (outer_x/2 - 3.5), sy * (outer_y/2 - 3.5)]
];

// ---- "C" interface: male 1"-32 thread ----
// z = 0 is the seating shoulder — it lands on the camera front plate's C-mount
// tower rim, the same plane the flange front face sat on, so flange_to_optic is
// unchanged. The thread runs z = 0 .. thread_engage, into the camera; a plain
// shoulder disc gives a finger grip and backstops the thread.
cmount_male_d = CMOUNT_MAJOR_D - 2*thread_clearance;
shoulder_thk  = 3.0;

// ---- optic cell ----
pocket_bore   = element_d + 2*element_fit;
seat_rim_w    = (element_d - clear_aperture_d) / 2;
barrel_od_c   = (barrel_od > 0) ? barrel_od : element_d + 2*wall + 4;
barrel_bore   = clear_aperture_d + 2;                  // main bore behind the element

// ---- the light cone behind the optic ----
// Ø0 at the flange face, Ø clear_aperture_d at the optic (focus ~ at the flange —
// conservative; the real focus is a few mm inside the body).
function cone_d(z) = clear_aperture_d * abs(z) / flange_to_optic;

// ---- stem <-> barrel joint ----
// The stem neck plugs `join_len` into a socket in the barrel rear.
socket_mouth_z = -stem_neck_len;                       // barrel rear face, global z
socket_bot_z   = -stem_neck_len - join_len;            // deepest point of the socket / stem neck tip
neck_bore      = ceil(cone_d(socket_bot_z) + 4);       // clears the cone at the socket bottom
neck_od        = neck_bore + 2*wall;
socket_bore    = neck_od + 2*join_fit;

shoulder_d     = max(neck_od + 6, 30);                 // "C" grip / thread backstop disc

// barrel authored in its own frame: optic rear face at z = 0, tube toward +Z,
// rear face at barrel_len. Placed at global z = -flange_to_optic for assembly.
barrel_len     = flange_to_optic - stem_neck_len;      // optic rear -> barrel rear face
join_screw_tap = (join_screw == "M2.5") ? M2_5_TAP : M3_TAP;

// stem authored in the flange frame: z = 0 is the seating plane ("C" shoulder /
// "flange" front face), +Z runs into the camera, the neck runs to -Z and ends at
// the socket bottom.
stem_end_z     = socket_bot_z;                         // neck tip, global z

// ---- 808 nm filter cell ----
// Entirely on the -Z (target/barrel) side of the seating plane, cut into the stem
// neck root — NOTHING projects toward +Z past the bare thread / flange into the
// camera, so the receiver stays a clean C-mount citizen and body variants are free.
// Stack, reading -Z from the seating plane (z = 0) toward the barrel:
//   [Ø thread_bore_d clear bore] | Ø6 field-stop & seat land | Ø8.6 filter | ring
//   nose | funnel | Ø fring_d retainer thread | ring lead-in | -> neck bore -> barrel
// The filter drops in from the -Z (barrel) end and the filter_ring screws in behind
// it; assemble the cell BEFORE plugging the barrel onto the neck.
filter_pocket_d = filter_d + 2*filter_fit;          // Ø8.6 filter pocket
fs_len   = 0.8;                                     // field-stop / seat land length
fs_z1    = 0;                                       // seat land top = seating plane
fs_z0    = fs_z1 - fs_len;                          // -0.8  (its -Z face is the filter seat)
filt_z1  = fs_z0;                                   // filter +Z (camera-side) face — on the seat
filt_z0  = filt_z1 - filter_thk;                    // filter -Z (target-side) face
fring_pitch  = 1.5;
fring_d      = 17;                                  // filter retainer thread major dia
fring_nose_h = 2.0;                                 // filter_ring nose: filter face -> its thread shoulder
// stem thread starts exactly where the ring's body shoulder lands when the nose is
// on the filter -> full engagement AND zero clamping stress on the 0.55 mm glass.
fring_z1     = filt_z0 - fring_nose_h;              // ring thread shoulder / stem thread start (-Z)
fring_engage = 3.5;                                 // thread length
fring_z0     = fring_z1 - fring_engage;             // -Z end of the stem retainer thread
cell_z0      = fring_z0 - 2.0;                      // -Z end of the cell (ring lead-in)
// clear bore through the male thread / flange, toward the detector
marg_tan     = (clear_aperture_d / 2) / flange_to_optic;   // marginal ray slope
thread_bore_top = is_cmount ? thread_engage : flange_thk;
thread_bore_d   = ceil(filter_clear_d + 2 * thread_bore_top * marg_tan + 3);

// ---- sanity checks ----
assert(clear_aperture_d <= element_d - 2.0,
    "clear_aperture_d must be >= 2 mm smaller than element_d (need a seat rim).");
assert(barrel_bore + 2*wall <= barrel_od_c + 0.01,
    "barrel_od too small for the bore + 2*wall. Raise barrel_od or drop clear_aperture_d / wall.");
assert(filter_clear_d + 1.5 <= filter_d,
    "filter_clear_d leaves too little seat rim under the filter.");
assert(fring_d - 1.95*fring_pitch >= filter_pocket_d,
    "retainer thread minor diameter clashes the Ø8.6 filter pocket — raise fring_d.");
assert(fring_d + 2*wall <= neck_od,
    "filter retainer thread + wall does not fit the stem neck — raise stem_neck_len/join_len (grows neck_od) or drop fring_d.");
assert(!is_cmount || thread_bore_d + 2*wall <= cmount_male_d - 1,
    "thread_bore_d leaves too little wall on the male 1\"-32 thread.");
assert(cell_z0 > socket_bot_z + join_len + 3,
    "filter cell runs into the stem<->barrel joint — shorten the cell or lengthen stem_neck_len.");
assert(neck_bore >= cone_d(socket_bot_z) + 2,
    "stem neck bore vignettes the light cone at the joint. Shorten stem_neck_len / join_len.");
assert(socket_bore + 2*wall <= barrel_od_c,
    "barrel wall around the stem socket is thinner than `wall`.");
assert(barrel_len > join_len + 20,
    "flange_to_optic too short for this barrel.");
assert(stem_neck_len > 4,
    "stem_neck_len must leave a visible neck between the seating plane and the barrel.");

echo(str("== mapscam receiver ==  element Ø", element_d, " f", focal_length,
         "  flange->optic ", flange_to_optic, " mm  (fixed focus)"));
echo(str("   barrel  Ø", barrel_od_c, " x ", barrel_len, " mm   bore Ø", barrel_bore));
echo(str("   stem    neck Ø", neck_od, " (bore Ø", neck_bore, ")   plug ", join_len,
         " mm x3 ", join_screw));
echo(is_cmount
     ? str("   mount   C — male 1\"-32, ", thread_engage, " mm engage, shoulder Ø", shoulder_d)
     : str("   mount   flange ", outer_x, " x ", outer_y, " mm"));
echo(str("   filter  Ø", filter_d, " x ", filter_thk, "   stop Ø", filter_clear_d,
         "   cell z[", cell_z0, ",0]  ring thread Ø", fring_d,
         "   thread bore Ø", thread_bore_d));
