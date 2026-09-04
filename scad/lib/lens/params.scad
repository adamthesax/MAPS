// mapscam — printed lens barrel: every tunable parameter, in one place.
// Annotations in `// [ ... ]` comments make these sliders in the OpenSCAD Customizer.
// Anything DERIVED lives at the bottom under "computed".
//
// Convention: z = 0 is the FLANGE FACE (the shoulder that seats against the camera
// front plate). +Z points toward the FRONT of the lens; the male 1"-32 thread runs
// from z = 0 toward -Z, into the camera. (Mirror of the camera's +Z-into-body.)

include <../constants.scad>

/* [Part selection] */
part = "assembly"; // [assembly, barrel, retainer, hood]

/* [Camera mount] */
mount_type       = "C";    // [C, CS]
thread_clearance = 0.15;   // [0:0.05:0.5] radial slop on the printed external thread
thread_engage    = 4.5;    // [3:0.5:8] axial length of the male 1"-32 thread

/* [Optical stack] */
// flange face (z=0) -> rear vertex of the rearmost element. +Z toward the lens front.
flange_to_rear_vertex = 6.0;   // [-3:0.5:24]
element_d             = 12.7;  // element outside diameter
element_edge_thk      = 2.5;   // edge (rim) thickness of ONE element = its seat depth
element_count         = 1;     // [1:2]
element_gap           = 0.0;   // [0:0.5:10] air gap between elements (element_count = 2)
clear_aperture_d      = 9.0;   // clear optical bore ahead of / behind the elements
element_fit           = 0.10;  // [0:0.02:0.3] radial slip fit: bore vs element_d

/* [Barrel] */
wall      = 3;      // [2:0.5:5] barrel wall thickness
barrel_od = 0;      // 0 = auto (fits the retainer thread + wall); or pin a value in mm
front_rim = 1.5;    // [0:0.5:6] barrel length ahead of the retainer (recesses it; filter-thread stock)

/* [Filter thread] */
filter_thread = "none"; // [none, M25.5x0.5, M30.5x0.5, M37.5x0.5, M40.5x0.5]

/* [Hood] */
hood_style  = "none";   // [none, round]
hood_length = 16;       // [6:2:48]

/* [Quality] */
$fn = 64;

// ===========================================================================
// computed — do not edit; these fall out of the parameters above
// ===========================================================================

group_thk    = element_count * element_edge_thk + (element_count - 1) * element_gap;
seat_z       = flange_to_rear_vertex;        // rear face of the element group
front_elem_z = seat_z + group_thk;           // front face of the element group
bore_d       = element_d + 2 * element_fit;  // element pocket bore

// coarse printed retainer thread (internal part, no interchange requirement)
retainer_pitch    = 1.0;
retainer_thread_d = bore_d + 3.0;            // major dia of the retainer thread
retainer_thk      = max(2.5, element_edge_thk);
retainer_engage   = 3.0;                     // axial thread length

barrel_od_auto = max(CMOUNT_MAJOR_D + 2 * wall + 2, retainer_thread_d + 2 * wall);
barrel_od_c    = (barrel_od > 0) ? barrel_od : barrel_od_auto;

retainer_z0    = front_elem_z;                     // retainer thread starts here (clamps group back)
barrel_front_z = retainer_z0 + retainer_engage + front_rim;   // barrel front face
total_track    = barrel_front_z + thread_engage;  // rear thread tip -> front face

has_filter   = (filter_thread != "none");
filter_major = filter_thread_spec(filter_thread)[0];
filter_pitch = filter_thread_spec(filter_thread)[1];
filter_len   = min(6, retainer_engage + front_rim + 2);   // threaded front zone length

// ---- sanity checks: fail the render (with -D or `make check`) if the stack is impossible
assert(flange_to_rear_vertex > -thread_engage + 0.5,
    "Rear element vertex lands inside the male thread. Increase flange_to_rear_vertex.");
assert(clear_aperture_d < element_d - 1.0,
    "clear_aperture_d must be >= 1 mm smaller than element_d (need a seat rim).");
assert(barrel_od_c >= retainer_thread_d + 2 * wall - 0.01,
    "Barrel OD too small for the retainer thread + wall. Raise barrel_od, or drop element_d / wall.");
assert(filter_thread == "none" || filter_major > clear_aperture_d + 3,
    "filter_thread major diameter leaves no wall over the clear aperture; pick a larger filter size.");

echo(str("== mapscam lens ==  mount=", mount_type, "  elements=", element_count,
         "  filter=", filter_thread));
echo(str("   flange->rear vertex = ", flange_to_rear_vertex, " mm   group_thk = ", group_thk, " mm"));
echo(str("   barrel_od = ", barrel_od_c, " mm   total_track = ", total_track, " mm"));
