// mapscam receiver — stem: the camera interface + the 808 nm filter cell + a short
// rigid neck whose front end plugs into the barrel rear.
//
// Authored in the flange frame: z = 0 is the seating plane, +Z runs into the
// camera (filter, detector), the neck runs to -Z toward the target.
//
//   mount = "C"      : a male 1"-32 thread + a Ø shoulder disc. Screws into a stock
//                      generic_29mm_c front plate (lens_mount_style = "thread").
//   mount = "flange" : a verbatim copy of scad/lib/camera/interface.scad's register
//                      + 4-corner M3 pattern, so any stock body bolts on.

include <params.scad>
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
use <../util.scad>
use <../hardware.scad>

// --- interface primitives (mirror of camera/interface.scad) ---------------
module vr_corner_ears(h) {
    for (p = mate_screw_xy())
        translate([p[0], p[1], 0]) cylinder(h = h, d = ear_d);
}

module vr_reg_boss() {
    union() {
        rprism(reg_x - 2*reg_fit, reg_y - 2*reg_fit, reg_boss_h, r = max(0.5, corner_r - 1));
        translate([reg_x/2 - reg_fit - 1, 0, 0])
            rprism(3, 6, reg_boss_h, r = 0.6);
    }
}

module vr_mate_screws(h) {
    for (p = mate_screw_xy())
        translate([p[0], p[1], 0]) screw_clear("M3", h);
}

// --- the filter cell + neck, shared by both mounts -----------------------
// A negative: the axial optical path, -Z (target) up to +Z (body / detector).
//   Ø neck_bore -> Ø6 field stop -> [SEAT] -> Ø8.6 filter pocket -> funnel
//   -> Ø fring_d retainer thread -> clearance -> body cavity
module vr_optical_path() {
    // wide neck bore, up toward the seat; necks to the field stop just below z = 0
    translate([0, 0, stem_end_z - 1])
        cylinder(h = -0.6 - (stem_end_z - 1), d = neck_bore, $fn = 48);
    translate([0, 0, -0.6])
        cylinder(h = fs_z0 + 0.6, d1 = neck_bore, d2 = filter_clear_d, $fn = 48);
    // field stop (Ø6) — ends at the seat shoulder
    translate([0, 0, fs_z0 - 0.01])
        cylinder(h = (fs_z1 - fs_z0) + 0.02, d = filter_clear_d, $fn = 48);
    // Ø8.6 filter pocket — holds the filter and guides the ring nose
    translate([0, 0, fs_z1])
        cylinder(h = fring_z0 - 1.5 - fs_z1 + 0.02, d = filter_pocket_d, $fn = 48);
    // funnel: Ø8.6 pocket up to the retainer thread bore
    translate([0, 0, fring_z0 - 1.5])
        cylinder(h = 1.51, d1 = filter_pocket_d, d2 = fring_d, $fn = 48);
    // retainer thread — the filter_ring body screws in here
    translate([0, 0, fring_z0 + fring_engage/2])
        threaded_rod(d = fring_d + 0.4, l = fring_engage + 0.02,
                     pitch = fring_pitch, internal = true, $fn = 48);
    // clearance above the thread so the ring body passes through to the cavity
    translate([0, 0, fring_z0 + fring_engage - 0.01])
        cylinder(h = filter_cell_base_z + filter_boss_h - (fring_z0 + fring_engage) + 1.5,
                 d = fring_d + 0.6, $fn = 48);
    // lead-in chamfer at the neck tip (eases the plug into the socket)
    translate([0, 0, stem_end_z - 0.01])
        cylinder(h = 2, d1 = neck_od + 1, d2 = neck_od - 3);
    // shallow groove around the plug for the barrel's 3 join-screw tips
    translate([0, 0, stem_end_z + join_len/2])
        rotate_extrude($fn = $fn)
            translate([neck_od/2 - 0.7, 0]) circle(d = 2.6, $fn = 20);
}

// --- "C": male 1"-32 thread ---------------------------------------------
module stem_cmount() {
    difference() {
        union() {
            // male 1"-32 thread, z = 0 .. thread_engage (into the camera)
            translate([0, 0, thread_engage/2])
                threaded_rod(d = cmount_male_d, l = thread_engage,
                             pitch = CMOUNT_PITCH, internal = false, $fn = 96);
            // grip / backstop shoulder, just proud of the seating plane (-Z)
            translate([0, 0, -shoulder_thk]) cylinder(h = shoulder_thk, d = shoulder_d);
            // compact filter-cell boss, toward the detector
            cylinder(h = filter_boss_h, d = filter_boss_d_c);
            // rigid neck, hanging toward -Z (its front join_len is the barrel plug)
            translate([0, 0, stem_end_z]) cylinder(h = -stem_end_z, d = neck_od);
        }
        vr_optical_path();
        // thread lead-in chamfer at the tip (into the camera)
        translate([0, 0, thread_engage - 0.01])
            cylinder(h = 1.2, d1 = cmount_male_d + 0.6, d2 = cmount_male_d - 2.5);
        // shoulder edge chamfer
        translate([0, 0, -shoulder_thk - 0.01])
            cylinder(h = 1.0, d1 = shoulder_d + 1, d2 = shoulder_d - 2);
    }
}

// --- "flange": camera register + 4-corner M3 ----------------------------
module stem_flange() {
    difference() {
        union() {
            rprism(outer_x, outer_y, flange_thk, r = corner_r);
            vr_corner_ears(flange_thk);
            translate([0, 0, flange_thk]) vr_reg_boss();
            // filter-cell boss, projecting into the body cavity (+Z)
            translate([0, 0, flange_thk - 0.01])
                cylinder(h = filter_boss_h + 0.01, d = filter_boss_d_c);
            // rigid neck, hanging toward -Z (its front join_len is the barrel plug)
            translate([0, 0, stem_end_z]) cylinder(h = -stem_end_z, d = neck_od);
            // fillet where the neck meets the flange
            translate([0, 0, -wall]) cylinder(h = wall, d1 = neck_od, d2 = neck_od + 2*wall);
        }
        vr_optical_path();
        // 4-corner mate screws + cap-head counterbores on the flange face
        vr_mate_screws(flange_thk + reg_boss_h + 1);
        for (p = mate_screw_xy())
            translate([p[0], p[1], -0.01]) cylinder(h = 2.5, d = M3_HEAD_D);
    }
}

module stem() {
    if (is_cmount) stem_cmount();
    else           stem_flange();
}

stem();
