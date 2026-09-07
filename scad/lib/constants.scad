// mapscam — physical constants. No geometry, no dependencies.
// Everything a design decision depends on lives here so it is greppable and citable.

// ---------------------------------------------------------------------------
// C / CS lens mount (ISO C-mount)
// ---------------------------------------------------------------------------
C_MOUNT_FFD   = 17.526;   // flange face -> sensor plane, mm (flange focal distance)
CS_MOUNT_FFD  = 12.526;   // same thread, 5.000 mm shorter
C_CS_SPACER   = 5.000;    // C-to-CS adapter ring thickness

CMOUNT_MAJOR_D = 25.4;    // 1.000 in major diameter
CMOUNT_TPI     = 32;      // threads per inch
CMOUNT_PITCH   = 25.4 / 32;   // 0.79375 mm
CMOUNT_ANGLE   = 30;      // UN thread half-angle -> 60 deg included

// mount_type -> flange focal distance
function ffd(m) = (m == "CS") ? CS_MOUNT_FFD : C_MOUNT_FFD;

// ---------------------------------------------------------------------------
// Fasteners (mm). *_TAP = self-tap into plastic, *_CLEAR = free-fit clearance.
// *_HEATSET = pocket for a brass threaded heat-set insert.
// ---------------------------------------------------------------------------
M2_TAP   = 1.7;   M2_CLEAR   = 2.4;
M2_5_TAP = 2.1;   M2_5_CLEAR = 2.9;
M3_TAP   = 2.5;   M3_CLEAR   = 3.4;   M3_HEAD_D = 6.0;

M2_HEATSET_D  = 3.2;   M2_HEATSET_H  = 4.0;
M3_HEATSET_D  = 4.0;   M3_HEATSET_H  = 5.0;

// 1/4"-20 UNC photo/tripod thread, as a brass heat-set insert
INSERT_1420_D = 8.0;   INSERT_1420_H = 10.0;

// ---------------------------------------------------------------------------
// NATO accessory rail — Picatinny / STANAG 4694 family clamping profile, run
// smooth (no recoil grooves) and low. A bought or printed NATO clamp grips the
// upper 45 deg chamfers; the width across them is the Picatinny 21.2 mm so
// off-the-shelf clamps fit. MIL-STD-1913 does not fix a height, so it is kept
// low here. Still worth a test fit against your actual clamp before committing.
// ---------------------------------------------------------------------------
NATO_W_MAX  = 21.2;   // width across the 45 deg clamp chamfers   (0.835 in)
NATO_W_TOP  = 15.7;   // top flat                                 (~0.617 in)
NATO_W_BASE = 18.5;   // rail footprint where it meets the face
NATO_TIP    = 0.5;    // vertical land at the widest point (no knife edge)
NATO_NECK   = 1.0;    // vertical web between the face and the lower chamfer
NATO_H      = NATO_NECK + (NATO_W_MAX - NATO_W_BASE)/2 + NATO_TIP
                       + (NATO_W_MAX - NATO_W_TOP)/2;   // falls out at 45 deg

// Common cable gland panel-hole diameters (metric PG series)
function gland_hole_d(g) =
    (g == "PG9")  ? 15.2 :
    (g == "PG11") ? 18.6 :
    (g == "PG7")  ? 12.5 :
    0;   // "none"

// ---------------------------------------------------------------------------
// Front filter threads (CCTV / photo accessory sizes). [major_d, pitch] in mm.
// "none" -> [0, 0]. Printed at real pitch; FDM accuracy is marginal at 0.5 mm.
// ---------------------------------------------------------------------------
function filter_thread_spec(name) =
    (name == "M25.5x0.5") ? [25.5, 0.5] :
    (name == "M30.5x0.5") ? [30.5, 0.5] :
    (name == "M37.5x0.5") ? [37.5, 0.5] :
    (name == "M40.5x0.5") ? [40.5, 0.5] :
    [0, 0];   // "none"
