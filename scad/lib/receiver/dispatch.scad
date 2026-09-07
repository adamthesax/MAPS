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
    // stem sits in the flange frame; the barrel is placed at -flange_to_optic.
    // -D explode_gap=0 shows the parts fitted.
    explode = explode_gap;

    stem();

    translate([0, 0, -flange_to_optic - explode]) {
        barrel();
        % translate([0, 0, -explode * 0.4]) element_ghost();
        translate([0, 0, -(element_edge_thk + retainer_thk) - explode * 0.8])
            lens_retainer();
    }

    // filter + its ring, exploded together out the -Z (barrel) end of the stem cell
    % translate([0, 0, filt_z0 - explode + 4]) cylinder(h = filter_thk, d = filter_d);
    translate([0, 0, filt_z0 - explode]) mirror([0, 0, 1]) filter_ring();
}
