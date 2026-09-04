// mapscam lens — part dispatch. Included after params (or params + overrides).
// Renders the single part named by `part`, or the exploded assembly preview.

use <../util.scad>
use <barrel.scad>
use <retainer.scad>
use <hood.scad>

module element_ghost() {
    color([0.4, 0.6, 0.9, 0.30])
        for (i = [0 : element_count - 1])
            translate([0, 0, seat_z + i * (element_edge_thk + element_gap)])
                cylinder(h = element_edge_thk, d = element_d);
}

if      (part == "barrel")   barrel();
else if (part == "retainer") retainer();
else if (part == "hood")     hood();
else {
    // exploded preview — parts pulled apart along +Z. Not for STL export.
    explode = 10;
    barrel();
    translate([0, 0, retainer_z0 + explode]) retainer();
    % translate([0, 0, explode * 0.5]) element_ghost();
    if (hood_style != "none")
        translate([0, 0, barrel_front_z + explode * 1.6]) hood();
}
