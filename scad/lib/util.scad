// mapscam — tiny geometry helpers, no external deps.

// Rounded rectangular prism, centred in X/Y, sitting on z=0..h.
module rprism(x, y, h, r = 2) {
    r2 = min(r, x/2 - 0.01, y/2 - 0.01);
    linear_extrude(height = h)
        offset(r = r2) square([x - 2*r2, y - 2*r2], center = true);
}

// Same but centred on the origin in all axes.
module rprism_c(x, y, h, r = 2) {
    translate([0, 0, -h/2]) rprism(x, y, h, r);
}
