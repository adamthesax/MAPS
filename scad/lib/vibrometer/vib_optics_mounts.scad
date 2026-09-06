// mapscam — vibrometer PHASE 2 SKETCH ONLY (Michelson homodyne quadrature).
//
// Rough geometry to confirm a bench layout fits a 25 mm optical-breadboard grid.
// NOT build-ready and NOT part of the `vibrometer` component's parts list — it is
// excluded from `make check`. The detailed models (kinematic BS-cube holder,
// PZT reference-mirror cell, quadrature detector cluster with a lambda/4 plate +
// two polariser slots + 2-3 BPW34s) are deferred to the Phase-2 build.
// See docs/vibrometer/design-notes.md.

use <../util.scad>

grid = 25;          // breadboard hole pitch (mm)
post_d = 12.7;      // 1/2" optical post
base_t = 6;

module bench_post(h = 30) {
    cylinder(h = h, d = post_d);
    cylinder(h = base_t, d = 25);
}

module bs_cube_holder(cube_mm = 10) {
    difference() {
        translate([0, 0, base_t]) rprism_c(cube_mm + 10, cube_mm + 10, cube_mm + 8, r = 1.5);
        translate([0, 0, base_t + 4])
            rotate([0, 0, 45]) cube([cube_mm, cube_mm, cube_mm + 4], center = true);
        translate([0, 0, base_t + 4]) rotate([90, 0, 0]) cylinder(h = 40, d = 6, center = true);
        translate([0, 0, base_t + 4]) rotate([0, 90, 0]) cylinder(h = 40, d = 6, center = true);
    }
    bench_post(base_t);
}

module pzt_mirror_cell(mirror_d = 12.7) {
    difference() {
        translate([0, 0, base_t]) cylinder(h = 14, d = mirror_d + 8);
        translate([0, 0, base_t + 10]) cylinder(h = 6, d = mirror_d + 0.3);   // mirror seat
        translate([0, 0, base_t + 1]) cylinder(h = 9, d = 7.0);               // PZT stack bore
    }
    bench_post(base_t);
}

module quad_detector_cluster() {
    difference() {
        translate([0, 0, base_t]) rprism_c(30, 24, 20, r = 2);
        translate([0, 0, base_t + 10]) rotate([0, 90, 0]) cylinder(h = 32, d = 10, center = true); // beam bore
        for (s = [-1, 1])
            translate([0, s * 6, base_t + 10]) rotate([0, 90, 0]) cylinder(h = 6, d = 5.6);        // BPW34 pockets
        translate([-6, 0, base_t + 10]) cube([1.5, 20, 20], center = true);   // lambda/4 plate slot
        translate([ 3, 0, base_t + 10]) cube([1.5, 20, 20], center = true);   // polariser slot A
        translate([ 8, 0, base_t + 10]) cube([1.5, 20, 20], center = true);   // polariser slot B
    }
    bench_post(base_t);
}

// Indicative layout on the grid (source -> BS -> {ref arm, target arm} -> detector).
module vib_michelson_layout() {
    translate([0,        0, 0]) bs_cube_holder();
    translate([0,  4*grid, 0]) pzt_mirror_cell();          // reference arm
    translate([4*grid,   0, 0]) %cylinder(h = 5, d = 3);   // target arm exit (to bench)
    translate([0, -2*grid, 0]) quad_detector_cluster();
}

vib_michelson_layout();
