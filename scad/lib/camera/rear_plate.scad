// mapscam — rear module: closes the body, carries the cable gland, an optional
// desiccant pocket, and the 1/4"-20 tripod insert.

include <params.scad>
use <interface.scad>
use <../util.scad>
use <../hardware.scad>

rear_thk = tripod_insert ? 12 : 6;   // thick enough to take a side 1/4"-20 insert

module rear_plate() {
    rz = front_mate_z + body_length;   // body rear face
    gd = gland_hole_d(gland);

    difference() {
        union() {
            translate([0, 0, rz]) rprism(outer_x, outer_y, rear_thk, r = corner_r);
            translate([0, 0, rz]) corner_ears(rear_thk);
            translate([0, 0, rz]) mirror([0, 0, 1]) reg_boss();   // boss into body
        }
        // mate screws: from the rear face toward the body's rear inserts
        translate([0, 0, rz + rear_thk]) mirror([0, 0, 1])
            mate_screws("clear", h = rear_thk + reg_boss_h + 1);
        for (p = mate_screw_xy())
            translate([p[0], p[1], rz + rear_thk]) mirror([0, 0, 1]) cap_counterbore("M3", 2.5);

        // cable gland
        if (gd > 0)
            translate([0, 0, rz - reg_boss_h - 1])
                cylinder(h = rear_thk + reg_boss_h + 2, d = gd);

        // extra rectangular cutout
        if (panel_cut_x > 0 && panel_cut_y > 0)
            translate([0, 0, rz - reg_boss_h - 1])
                rprism(panel_cut_x, panel_cut_y, rear_thk + reg_boss_h + 2, r = 1);

        // desiccant pocket, opening into the cavity (-Z)
        if (desiccant_pocket)
            translate([0, outer_y/4, rz - reg_boss_h - 0.01])
                rprism(outer_x - 2*wall - 6, 8, 6, r = 1);

        // 1/4"-20 tripod insert, bored into the -Y edge
        if (tripod_insert)
            translate([0, -outer_y/2 - 0.01, rz + rear_thk/2])
                rotate([-90, 0, 0]) insert_1420();
    }
}

rear_plate();
