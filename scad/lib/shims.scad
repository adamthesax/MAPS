// mapscam — printable back-focus shim set. One frame per entry in `shim_values`,
// laid out in a row. They stack between the sensor carrier and the body ledge.

include <params.scad>
use <util.scad>

module one_shim(t) {
    linear_extrude(height = t)
        difference() {
            offset(r = 1.5) square([carrier_x - 6, carrier_y - 6], center = true);
            circle(d = sensor_window_d + 3);
        }
}

module shims() {
    for (i = [0 : len(shim_values) - 1])
        translate([i * (carrier_x + 3), 0, 0])
            one_shim(shim_values[i]);
}

shims();
