// mapscam receiver — part dispatch. Included after params (or params + overrides).
// Renders the single part named by `part`, or the exploded assembly preview.

use <../util.scad>
use <stem.scad>
use <barrel.scad>
use <retainer.scad>

module element_ghost() {
    // Ø80 optic: flat rear face at z = 0 (barrel-local), convex face toward -Z.
    color([0.4, 0.6, 0.9, 0.30])
        translate([0, 0, -element_edge_thk])
            cylinder(h = element_edge_thk, d = element_d);
}

if      (part == "stem")          stem();
else if (part == "barrel")        barrel();
else if (part == "lens_retainer") lens_retainer();
else if (part == "filter_ring")   filter_ring();
else {
    // exploded preview — NOT for STL export. Parts pulled apart along Z.
    // stem sits in the flange frame; barrel + optic slide to -focus_nominal.
    // -D explode_gap=0 shows the parts fitted at nominal focus.
    explode = explode_gap;

    stem();

    translate([0, 0, -focus_nominal - explode]) {
        barrel();
        % translate([0, 0, -explode * 0.35]) element_ghost();
        translate([0, 0, -(element_edge_thk + retainer_thk) - explode * 0.7])
            lens_retainer();
    }

    // filter + its ring, floated out of the stem toward +Z
    % translate([0, 0, filter_z0 + explode * 0.5]) cylinder(h = filter_thk, d = filter_d);
    translate([0, 0, filter_z1 + explode]) filter_ring();
}
