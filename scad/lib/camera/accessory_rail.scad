// mapscam — NATO-style accessory rail for a module's -Y face.
//
// A smooth 45 deg dovetail (the de facto camera-gear "NATO rail"), plus an
// optional row of M3 heat-set inserts down the crown so adapters can bolt
// straight on. This is NOT the inter-module register — it is a separate add-on
// mount interface, documented in docs/modularity.md.
//
// Authored in the host module's absolute coordinates: the caller passes the
// face Y, the start Z and the run length, so the rail always matches the part
// it sits on (e.g. body_length) instead of re-deriving anything.

include <../constants.scad>
use <../hardware.scad>

// 2D cross-section. X = rail width, Y = distance out from the face (<= 0, -Y).
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

// Crown M3 hole Z positions for a rail spanning [z0, z0 + len].
// The end holes double as clamp stop-screw seats; the rest are adapter bolt points.
function nato_hole_zs(z0, len, pitch, end_margin = 5) =
    let(za = z0 + end_margin,
        zb = z0 + len - end_margin,
        n  = max(1, floor((zb - za) / max(1, pitch)) + 1))
    [ for (i = [0 : n - 1]) zb - i * pitch ];

// Additive — union into the host solid.
//   face_y     : the -Y outer face (negative)
//   z0, len    : rail runs z0 .. z0 + len
//   front_dam  : raised fixed stop at the z0 end (clamp slides on from the far end)
module nato_rail(face_y, z0, len, front_dam = true) {
    eps = 0.02;
    translate([0, face_y + eps, z0])
        linear_extrude(height = len)
            nato_section();

    if (front_dam)
        translate([0, face_y + eps, z0])
            linear_extrude(height = 3.6)
                polygon([[-NATO_W_HEAD/2, 0], [ NATO_W_HEAD/2, 0],
                         [ NATO_W_HEAD/2, -NATO_H - 2], [-NATO_W_HEAD/2, -NATO_H - 2]]);
}

// Subtractive — difference out of the host solid. Crown M3 pockets (recessed so a
// flush insert never fouls a clamp) that also serve as adapter bolt holes.
module nato_rail_pockets(face_y, z0, len, pitch) {
    for (z = nato_hole_zs(z0, len, pitch))
        translate([0, face_y - NATO_H - 0.01, z])
            rotate([-90, 0, 0]) {
                heatset("M3", open = "down");
                cylinder(h = 0.8, d = M3_HEATSET_D + 1.6);   // mouth relief
            }
}
