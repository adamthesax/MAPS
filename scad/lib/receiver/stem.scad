// mapscam receiver — stem: the narrow draw tube the lens barrel telescopes over.
// Its top is a female helicoid collar that threads onto the flange's male boss for
// fine focus; a radial M3 grub in the collar locks the setting.
//
// Authored in the flange frame (z = 0 at the flange face). Drawn at mid fine-travel:
// the helicoid thread itself provides the +/- fine_travel/2 range.

include <params.scad>
include <helix.scad>
use <../util.scad>
use <../hardware.scad>

module stem() {
    ct = stem_top_z;                    // helicoid collar top face (mid-travel, negative)
    cb = ct - helix_collar_len;         // collar bottom
    nb = stem_neck_bot;                 // neck bottom = draw-tube top
    grip_z = (ct + cb) / 2;

    difference() {
        union() {
            // female-helicoid collar
            translate([0, 0, cb]) cylinder(h = helix_collar_len, d = stem_collar_od);
            // neck cone down to the draw tube
            translate([0, 0, nb]) cylinder(h = neck_len, d1 = draw_od, d2 = stem_collar_od);
            // draw tube
            translate([0, 0, -stem_len]) cylinder(h = nb + stem_len, d = draw_od);
        }

        // through bore
        translate([0, 0, -stem_len - 1])
            cylinder(h = stem_len + 1 + ct + 1, d = draw_id, $fn = 48);
        // female helicoid thread in the collar
        translate([0, 0, cb])
            helix_female_cut(helix_major, helix_collar_len, helix_pitch, slop = helix_fit);
        // ease the Ø(helix_major) -> Ø(draw_id) step just below the collar
        translate([0, 0, cb - 3.001])
            cylinder(h = 3.01, d1 = draw_id, d2 = helix_major - 2*HELIX_DEPTH, $fn = 48);

        // grip scallops around the collar
        for (i = [0 : 11])
            rotate([0, 0, 30 * i])
                translate([stem_collar_od/2 + 1.1, 0, grip_z])
                    cylinder(h = helix_collar_len - 2, d = 3.2, center = true, $fn = 16);

        // radial M3 grub: locks the helicoid against the flange boss thread
        translate([0, 0, grip_z]) rotate([0, 90, 0])
            cylinder(h = stem_collar_od, d = M3_TAP, $fn = 24);
    }
}

stem();
