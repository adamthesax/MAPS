// mapscam receiver — barrel: holds the Ø80 optic at the front, clamped by a
// threaded lens_retainer ring; its rear is a socket the stem neck plugs into,
// pinned by 3 radial screws.
//
// Authored in its own frame: z = 0 is the optic's rear (flat) face, +Z runs back
// toward the body, the optic + retainer sit at -Z. `dispatch.scad` places the part
// at z = -flange_to_optic for the assembly view.

include <params.scad>
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
use <../util.scad>
use <../hardware.scad>

taper_len = 14;                                 // blend from barrel OD down to the socket
cell_h    = element_edge_thk + retainer_engage + front_rim;
socket_od = socket_bore + 2*wall;

module barrel() {
    socket_z0  = barrel_len - join_len;         // socket starts here (local z)
    trunk_top  = socket_z0 - taper_len;         // main Ø tube ends here

    difference() {
        union() {
            // lens cell + main tube
            translate([0, 0, -cell_h]) cylinder(h = cell_h + trunk_top, d = barrel_od_c);
            // taper to the socket
            translate([0, 0, trunk_top]) cylinder(h = taper_len, d1 = barrel_od_c, d2 = socket_od);
            // socket collar
            translate([0, 0, socket_z0]) cylinder(h = join_len, d = socket_od);
        }

        // ---- optical path -----------------------------------------------
        // clear optical aperture, the full depth of the cell
        translate([0, 0, -cell_h - 0.01])
            cylinder(h = cell_h + 0.02, d = clear_aperture_d);
        // element pocket — the step up from clear_aperture_d at z = -element_edge_thk
        // is the seat rim the optic rests on (loads in from the front / muzzle)
        translate([0, 0, -element_edge_thk - 0.01])
            cylinder(h = element_edge_thk + 0.02, d = pocket_bore);
        // internal retainer thread — lens_retainer screws in ahead of the optic and
        // clamps it back onto the seat; its own flat face is the clamp face (same
        // scheme as scad/lib/lens/retainer.scad). Replaces the old set-screw ring.
        translate([0, 0, -element_edge_thk - retainer_engage/2])
            threaded_rod(d = retainer_thread_d, l = retainer_engage,
                         pitch = retainer_pitch, internal = true, $fn = $fn);
        // wide mouth ahead of the retainer (recesses it; clearance to fit/remove the ring)
        translate([0, 0, -cell_h - 0.01])
            cylinder(h = front_rim + 0.02, d = retainer_thread_d + 0.3);
        translate([0, 0, -0.01])
            cylinder(h = trunk_top + 0.02, d = barrel_bore);                      // main bore
        translate([0, 0, trunk_top - 0.01])
            cylinder(h = taper_len + 0.02, d1 = barrel_bore, d2 = socket_bore);   // bore taper
        translate([0, 0, socket_z0 - 0.01])
            cylinder(h = join_len + 0.02, d = socket_bore);                       // socket bore
        translate([0, 0, barrel_len - 2.5])
            cylinder(h = 2.51, d1 = socket_bore, d2 = socket_bore + 3);           // socket lead-in

        // ---- 3 radial join screws (tapped) through the socket wall -------
        for (i = [0:2])
            rotate([0, 0, 120*i + 60])
                translate([0, 0, socket_z0 + join_len/2])
                    rotate([0, 90, 0])
                        cylinder(h = socket_od, d = join_screw_tap, $fn = 20);
    }
}

barrel();
