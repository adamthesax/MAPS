// mapscam receiver — a light single-start square/ACME-ish helical thread for the
// fine-focus helicoid. Modelled with `linear_extrude(twist=…)` instead of BOSL2
// `threaded_rod` — an order of magnitude cheaper under CGAL, and a square profile
// prints more reliably on FDM than a 60° V anyway.
//
// Right-hand thread. `helix_male` returns a solid to union; `helix_female_cut`
// returns the matching negative (bore + groove) to subtract from your own collar.

HELIX_FN    = 60;    // facets around the core
HELIX_DEPTH = 1.5;   // radial thread depth (major_d = root_d + 2*HELIX_DEPTH)

// ~22 extrude slices per thread turn -> a smooth helix, not a coarse polygon.
function helix_slices(len, pitch) = max(48, ceil((len / pitch) * 22));

module helix_rib(root_d, len, pitch, depth, w) {
    linear_extrude(height = len, twist = -360 * len / pitch,
                   convexity = 6, slices = helix_slices(len, pitch))
        translate([root_d / 2, 0]) square([2 * depth, w], center = true);
}

// Solid male thread, z = 0 .. len, major diameter `major_d`.
module helix_male(major_d, len, pitch, depth = HELIX_DEPTH) {
    root = major_d - 2 * depth;
    union() {
        cylinder(h = len, d = root, $fn = HELIX_FN);
        helix_rib(root, len, pitch, depth, pitch * 0.55);
    }
}

// Negative for a female thread: subtract from a collar cylinder. `slop` is the
// radial + axial running clearance onto the male thread.
module helix_female_cut(major_d, len, pitch, depth = HELIX_DEPTH, slop = 0.4) {
    root = major_d - 2 * depth;
    union() {
        translate([0, 0, -0.01])
            cylinder(h = len + 0.02, d = root + 2 * slop, $fn = HELIX_FN);
        helix_rib(root + 2 * slop, len, pitch, depth + 1.0, pitch * 0.55 + 2 * slop);
    }
}
