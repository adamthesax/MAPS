// mapscam — NATO-style accessory rail for a module face.
//
// A smooth 45 deg dovetail (the de facto camera-gear "NATO rail"), optionally
// with a row of M3 heat-set inserts down the crown so adapters can bolt straight
// on. Both ends open — a NATO clamp is held by jaw friction plus a stop screw in
// an end crown hole. This is NOT the inter-module register; it is a separate
// add-on mount interface, documented in docs/modularity.md.
//
// Authored in the host module's absolute coordinates: the caller passes the
// footprint, the start Z and the run length, so a rail always matches the part
// it sits on (e.g. body_length) instead of re-deriving anything.

include <../constants.scad>
use <../hardware.scad>

// 2D cross-section. X = rail width, Y = distance out from the face (<= 0, i.e. -Y).
module nato_section() {
    fl = (NATO_W_HEAD - NATO_W_BASE) / 2;   // 45 deg -> rise == run
    ch = 0.7;                               // crown edge break
    polygon([
        [-NATO_W_BASE/2, 0], [ NATO_W_BASE/2, 0],
        [ NATO_W_BASE/2, -NATO_NECK],
        [ NATO_W_HEAD/2, -NATO_NECK - fl],
        [ NATO_W_HEAD/2, -NATO_H + ch],
        [ NATO_W_HEAD/2 - ch, -NATO_H],
        [-NATO_W_HEAD/2 + ch, -NATO_H],
        [-NATO_W_HEAD/2, -NATO_H + ch],
        [-NATO_W_HEAD/2, -NATO_NECK - fl],
        [-NATO_W_BASE/2, -NATO_NECK],
    ]);
}

// Crown M3 hole Z positions for a rail spanning [z0, z0 + len]. Anchored at both
// ends (those seat the clamp stop-screws); interior holes fill in at <= `pitch`
// and are adapter bolt points.
function nato_hole_zs(z0, len, pitch, end_margin = 5) =
    let(m    = min(end_margin, len/2 - 1),
        za   = z0 + m,
        zb   = z0 + len - m,
        span = zb - za,
        n    = (span < 1) ? 1 : max(2, ceil(span / max(1, pitch)) + 1))
    (n == 1) ? [ z0 + len/2 ]
             : [ for (i = [0 : n - 1]) za + i * span / (n - 1) ];

// ---- one rail, canonical: on the face at y = -half, pointing -Y, running Z ----

module nato_rail(half, z0, len) {
    translate([0, -half + 0.02, z0])
        linear_extrude(height = len)
            nato_section();
}

// crown M3 pockets (recessed so a flush insert never fouls a clamp)
module nato_pockets(half, z0, len, pitch) {
    for (z = nato_hole_zs(z0, len, pitch))
        translate([0, -half - NATO_H - 0.01, z])
            rotate([-90, 0, 0]) {
                heatset("M3", open = "down");
                cylinder(h = 0.8, d = M3_HEATSET_D + 1.6);   // clamp-clearance relief
            }
}

// ---- multi-face dispatch: put rails on any of "-Y" "+Y" "-X" "+X" ----

function nato_face_rot(f)  = (f == "+Y") ? 180 : (f == "+X") ? 90 : (f == "-X") ? -90 : 0;
function nato_face_half(f, ox, oy) = (f == "-X" || f == "+X") ? ox/2 : oy/2;

module acc_rails(faces, ox, oy, z0, len) {
    for (f = faces)
        rotate([0, 0, nato_face_rot(f)])
            nato_rail(nato_face_half(f, ox, oy), z0, len);
}

module acc_rail_pockets(faces, ox, oy, z0, len, pitch) {
    for (f = faces)
        rotate([0, 0, nato_face_rot(f)])
            nato_pockets(nato_face_half(f, ox, oy), z0, len, pitch);
}
