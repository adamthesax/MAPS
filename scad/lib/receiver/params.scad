// mapscam — vibrometer receiver optic: every tunable parameter, in one place.
// Annotations in `// [ ... ]` comments make these sliders in the OpenSCAD Customizer.
// Anything DERIVED from these values lives at the bottom under "computed".
//
// What this is: a large-aperture receiver telescope for the M.A.P.S. laser
// vibrometer (see docs/vibrometer/). A bought Ø80 mm f≈150 mm singlet focuses the
// returned beam through a small 808 nm bandpass filter onto the detector, which
// rides on a stock mapscam `body` bolted to the rear flange.
//
// Focus has two stages: a COARSE draw-tube (the wide lens `barrel` telescopes over
// the narrow `stem`, a wrap `clamp` locks it) and a FINE printed helicoid between
// the `flange` and the `stem` (rotate the stem ~2 turns, lock with a radial grub).
//
// Convention: z = 0 is the FLANGE FACE — the shoulder that seats against the
// mapscam `body` front, exactly where a camera `front_plate` sits. +Z points INTO
// the body (toward the detector); the optics project to -Z, out toward the target.
// This mirrors scad/lib/camera/interface.scad's Z convention.

include <../constants.scad>

/* [Part selection] */
part = "assembly"; // [assembly, flange, stem, barrel, clamp, lens_retainer, filter_ring]

/* [Camera-body interface] */
// Footprint of the mapscam body this flange bolts onto. MUST match that body's
// outer_x / outer_y (= board + 2*inner_clear + 2*wall). 39 = the generic 29 mm board.
body_outer_x = 39;   // [30:0.5:80]
body_outer_y = 39;   // [30:0.5:80]

/* [Main optic] */
element_d          = 80;    // optic outside diameter
element_edge_thk   = 6;     // rim / edge thickness = how deep the seat pocket is   [GUESS — measure]
element_sag        = 8;     // convex face bulge past the rim plane — clearance check only  [GUESS — measure]
clear_aperture_d   = 74;    // clear optical bore through the seat rim
element_fit        = 0.30;  // [0:0.05:0.6] radial slip fit: pocket bore vs element_d
focal_length       = 150;   // nominal lens focal length — reference / echo only

/* [Focus travel] */
// element rear (flat) face -> flange face (z = 0), at mid-travel of BOTH stages.
focus_nominal = 150;  // [80:1:260]
focus_travel  = 25;   // [5:1:60]  ± coarse draw-tube adjustment about focus_nominal

/* [Fine focus helicoid] */
// Printed thread between the flange (male boss) and the stem (female collar).
// Rotate the stem for continuous fine focus; lock with a radial M3 grub in the collar.
fine_travel  = 6;    // [0:1:16]   total axial range of the helicoid
helix_pitch  = 2.5;  // [1:0.25:3] printed helicoid thread pitch (mm/turn)
helix_engage = 8;    // [5:1:16]   thread length always meshed, at any focus setting

/* [Draw tube / stem] */
draw_od     = 24;    // [16:0.5:40] stem (draw-tube) outside diameter
draw_id     = 17;    // [8:0.5:34]  clear bore up the stem
slide_fit   = 0.35;  // [0.1:0.05:0.8] radial: barrel slide-collar bore vs draw_od
collar_len  = 30;    // [15:1:60] length of the barrel's split bearing collar

/* [Focus clamp] */
// A separate wrap-around split collar squeezes the barrel's slit collet onto the
// stem (covers the collet slots -> also a light seal). One tangential pinch screw.
clamp_relief = 2.0;  // [1.2:0.2:4] width of the collet relief slots in the barrel
clamp_wall   = 3.5;  // [2:0.5:6] wall of the wrap clamp ring
clamp_screw  = "M4"; // [M3, M4] tangential pinch screw
clamp_fit    = 0.35; // [0.1:0.05:0.8] radial: clamp bore vs barrel collet OD

/* [808 nm filter] */
filter_d       = 8.0;   // bandpass filter outside diameter
filter_thk     = 1.2;   // filter thickness                     [GUESS — measure]
filter_clear_d = 6.0;   // field stop / clear aperture at the filter
filter_fit     = 0.25;  // [0:0.05:0.5] radial slip fit for the filter

/* [Barrel] */
wall            = 3;    // [2:0.5:6] barrel / stem wall thickness
barrel_od       = 0;    // 0 = auto (element_d + 2*wall + 4); or pin a value in mm
front_rim       = 2.0;  // [0:0.5:6] barrel material ahead of the lens retainer
retainer_thk    = 4.0;  // [2:0.5:8] lens retainer ring thickness

/* [Quality] */
$fn = 64;

// assembly-preview only: how far to pull the parts apart along Z (0 = show fitted).
explode_gap = 80;

// ===========================================================================
// computed — do not edit; these fall out of the parameters above
// ===========================================================================

// ---- interface register + bolt pattern (copied verbatim from
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

// ---- optical / mechanical stack ----
pocket_bore   = element_d + 2*element_fit;
seat_rim_w    = (element_d - clear_aperture_d) / 2;
barrel_od_c   = (barrel_od > 0) ? barrel_od : element_d + 2*wall + 4;
barrel_bore   = max(clear_aperture_d + 2, draw_od + 2*slide_fit + 8);
collar_bore   = draw_od + 2*slide_fit;              // barrel collet bore, rides the stem
collar_od     = collar_bore + 2*wall + 3;           // barrel collet outside diameter

// wrap clamp ring
clamp_id      = collar_od + clamp_fit;
clamp_od      = clamp_id + 2*clamp_wall;
clamp_h       = collar_len - 3;
clamp_screw_clear = (clamp_screw == "M3") ? 3.4 : 4.4;   // M3 / M4 free-fit
clamp_nut_af      = (clamp_screw == "M3") ? 5.5 : 7.0;   // hex nut across-flats

// ---- fine-focus helicoid (flange male boss <-> stem female collar) ----
helix_major      = draw_od + 12;                    // helicoid major diameter
helix_fit        = 0.35;                            // radial slop on the printed helicoid
helix_boss_len   = helix_engage + fine_travel + 2;  // flange boss length, -Z from z = 0
helix_collar_len = helix_engage + fine_travel;      // stem female-thread length
stem_collar_od   = helix_major + 2*wall + 3;        // stem helicoid collar OD
stem_top_z       = -(fine_travel/2 + 2);            // stem collar top face, at mid-travel
neck_len         = 8;                               // stem: helicoid collar -> draw tube cone
stem_neck_bot    = stem_top_z - helix_collar_len - neck_len;  // draw-tube top (mid-travel)

// barrel is authored in its own frame: element rear face at z = 0, tube toward +Z.
// barrel_rear_gap keeps the barrel collet clear of the stem neck at the far extreme.
barrel_rear_gap = 58;                       // flange face -> barrel rear face, at nominal focus
barrel_len      = focus_nominal - barrel_rear_gap;   // element rear face -> barrel rear face

// stem is authored in the flange frame (z = 0 at the flange face, tube toward -Z).
// At the near-focus extreme the barrel is pulled out to -(focus_nominal+focus_travel);
// the stem must still fill its slide collar, whose front edge is then this deep:
stem_len = focus_travel + barrel_rear_gap + collar_len + 8;

// ---- 808 nm filter cell, in the flange (fixed to the body) ----
filter_pocket_d = filter_d + 2*filter_fit;
fs_z0   = 0.8;                       // field stop front face (z into the flange plate)
fs_z1   = fs_z0 + 1.4;               // field stop back face / filter front face
filt_z1 = fs_z1 + filter_thk;        // filter back face
fring_pitch     = 1.5;
fring_d         = draw_id;                   // filter retainer threads here
fring_engage    = 4.0;

// ---- sanity checks: fail the render (`make check` / -D) on an impossible stack
assert(clear_aperture_d <= element_d - 2.0,
    "clear_aperture_d must be >= 2 mm smaller than element_d (need a seat rim).");
assert(barrel_bore + 2*wall <= barrel_od_c + 0.01,
    "barrel_od too small for the bore + 2*wall. Raise barrel_od or drop clear_aperture_d / wall.");
assert(draw_id + 2*wall <= draw_od + 0.01,
    "draw_id + 2*wall exceeds draw_od. Thin the wall or widen draw_od.");
assert(collar_bore + 8 < barrel_bore,
    "stem OD is too close to the barrel bore — it will bind before the collar engages. Drop draw_od or raise clear_aperture_d.");
assert(filter_clear_d + 2.0 <= filter_d,
    "filter_clear_d leaves no seat rim under the filter.");
assert(fring_d + 2*wall <= draw_od + 0.01,
    "filter retainer thread has no wall inside the stem. Widen draw_od or drop draw_id.");
assert(barrel_len > collar_len + 10,
    "focus_nominal is too short for this barrel — the slide collar swallows the whole tube.");
assert(focus_nominal - focus_travel > barrel_rear_gap + 5,
    "focus_travel reaches past the flange — reduce focus_travel or focus_nominal.");
assert(stem_top_z + fine_travel/2 < -0.5,
    "fine_travel is too large — the stem helicoid collar crashes into the flange face.");
assert(focus_travel - barrel_rear_gap - stem_neck_bot + 3 <= 0,
    "At far-focus the barrel collet rides onto the stem neck. Raise barrel_rear_gap.");
assert(helix_major + 2*wall <= stem_collar_od + 0.01,
    "stem helicoid collar wall is thinner than `wall`.");

echo(str("== mapscam receiver ==  element Ø", element_d, " f", focal_length,
         "  coarse focus ", focus_nominal - focus_travel, "..", focus_nominal + focus_travel,
         " mm  + fine ", fine_travel, " mm"));
echo(str("   barrel  Ø", barrel_od_c, " x ", barrel_len, " mm   bore Ø", barrel_bore));
echo(str("   stem    Ø", draw_od, " x ", stem_len, " mm   bore Ø", draw_id,
         "   collet Ø", collar_od, " x ", collar_len));
echo(str("   clamp   Ø", clamp_od, " x ", clamp_h, " mm   ", clamp_screw, " pinch"));
echo(str("   flange  ", outer_x, " x ", outer_y, " mm   helicoid Ø", helix_major,
         " x ", helix_pitch, " pitch   filter Ø", filter_d, " (stop Ø", filter_clear_d, ")"));
