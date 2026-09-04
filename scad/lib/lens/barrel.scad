// mapscam lens — barrel: male C-mount thread, element pocket + rear seat, internal
// retainer thread, optional external front filter thread.
//
// z = 0 is the flange face. Male thread runs z = -thread_engage .. 0 (into camera).
// Elements load from the front against the seat rim at z = seat_z; the retainer
// threads in ahead of them and clamps the group back.

include <params.scad>
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
use <../util.scad>

module barrel() {
    body_top = barrel_front_z - (has_filter ? filter_len : 0);

    difference() {
        union() {
            // rear male 1"-32 thread
            translate([0, 0, -thread_engage / 2])
                threaded_rod(d = CMOUNT_MAJOR_D - 2 * thread_clearance,
                             l = thread_engage, pitch = CMOUNT_PITCH,
                             internal = false, $fn = 96);
            // main barrel
            cylinder(h = body_top, d = barrel_od_c);
            // optional external front filter thread (turned to filter_major)
            if (has_filter)
                translate([0, 0, barrel_front_z - filter_len / 2])
                    threaded_rod(d = filter_major, l = filter_len,
                                 pitch = filter_pitch, internal = false, $fn = 160);
        }

        // clear optical aperture, full length
        translate([0, 0, -thread_engage - 1])
            cylinder(h = total_track + 2, d = clear_aperture_d);

        // element pocket — the step to clear_aperture_d at z = seat_z is the seat rim
        translate([0, 0, seat_z])
            cylinder(h = group_thk + 0.02, d = bore_d);

        // internal retainer thread (coarse printed pitch)
        translate([0, 0, retainer_z0 + retainer_engage / 2])
            threaded_rod(d = retainer_thread_d + 2 * 0.15,
                         l = retainer_engage + 0.02,
                         pitch = retainer_pitch, internal = true, $fn = 96);

        // wide mouth ahead of the retainer (recesses it; clearance to fit/remove the ring)
        translate([0, 0, retainer_z0 + retainer_engage - 0.01])
            cylinder(h = front_rim + filter_len + 1, d = retainer_thread_d + 0.3);
    }
}

barrel();
