// mapscam receiver — part dispatch. Included after params (or params + overrides).
// Renders the single part named by `part`, or the exploded assembly preview.

use <../util.scad>
use <flange.scad>
use <stem.scad>
use <barrel.scad>
use <clamp.scad>
use <retainer.scad>

module element_ghost() {
    // Ø80 optic: flat rear face at z = 0 (barrel-local), convex face toward -Z.
    color([0.4, 0.6, 0.9, 0.30])
        translate([0, 0, -element_edge_thk])
            cylinder(h = element_edge_thk, d = element_d);
}

if      (part == "flange")        flange();
else if (part == "stem")          stem();
else if (part == "barrel")        barrel();
else if (part == "clamp")         clamp();
else if (part == "lens_retainer") lens_retainer();
else if (part == "filter_ring")   filter_ring();
else {
    // exploded preview — NOT for STL export. Parts pulled apart along Z.
    // Everything is authored in the flange frame at mid fine-travel.
    // -D explode_gap=0 shows the parts fitted at nominal focus.
    explode = explode_gap;

    flange();

    // stem: threads onto the flange boss (floated -Z when exploded)
    translate([0, 0, -explode * 0.5]) stem();

    // barrel + optic at nominal coarse focus, floated further -Z
    translate([0, 0, -focus_nominal - explode]) {
        barrel();
        % translate([0, 0, -explode * 0.35]) element_ghost();
        translate([0, 0, -(element_edge_thk + retainer_thk) - explode * 0.7])
            lens_retainer();
    }

    // wrap clamp over the collet (slides on from the rear)
    translate([0, 0, -(focus_nominal - barrel_len) - clamp_h - explode * 1.35])
        clamp();

    // filter + its ring, floated out of the flange toward +Z
    % translate([0, 0, fs_z1 + explode * 0.5]) cylinder(h = filter_thk, d = filter_d);
    translate([0, 0, filt_z1 + explode]) filter_ring();
}
