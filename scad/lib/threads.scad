// mapscam — printable threads. Every PRIVATE printed-to-printed thread pair (a
// retainer ring into its barrel, a filter ring into its cell) goes through
// print_thread() so it gets the repo's FDM thread rules for free. The rules and the
// reasoning behind them are in docs/printable-threads.md.
//
// INTERCHANGE threads that must mate a bought metal part (the 1"-32 C-mount, the
// Mxx x0.5 filter threads) keep their standard ISO/UN profile and call BOSL2
// threaded_rod() directly, tagged `// interchange: <standard>` on the line above.
// `make check-threads` fails on any untagged threaded_rod() outside this file.
//
// Usage — `use <../threads.scad>`; both halves take the SAME nominal d:
//   print_thread(d = 84.6, l = 7.5, pitch = 2.5);                    // male
//   print_thread(d = 84.6, l = 8.5, pitch = 2.5, internal = true);   // female cutter
// The internal cutter carries all the clearance, so a mating pair is just "same d".
// Both are centred on the origin like threaded_rod().

include <constants.scad>
include <BOSL2/std.scad>
include <BOSL2/threading.scad>

// Diametral clearance for a printed pair of major diameter d. Grows with d: print
// shrinkage and out-of-round both scale with the size of the circle.
function print_thread_clearance(d) = PT_CLEAR_BASE + PT_CLEAR_PER_MM * d;
// Radial thread depth for a given pitch (45° flanks, flat crest + root).
function print_thread_depth(pitch) = PT_DEPTH_RATIO * pitch;
// Minor diameter of the male thread — what must still clear the bore inside it.
function print_thread_minor(d, pitch) = d - 2 * print_thread_depth(pitch);
// Major diameter the internal cutter actually cuts — what the wall behind it sees.
function print_thread_bore(d, clearance = undef) =
    d + (is_undef(clearance) ? print_thread_clearance(d) : clearance);

// A printable thread: 90° included angle (45° flanks — the steepest overhang an
// FDM printer lays down cleanly with the axis vertical), flat crests, blunt starts
// (no feather-edge partial turn to cross-thread), 45° bevels at both ends (lead-in,
// and they eat first-layer elephant's foot), fine facets.
//   d         : nominal major diameter — pass the same value to both halves.
//   l         : threaded length. Must be >= PT_MIN_TURNS pitches.
//   internal  : true -> a cutter to difference() out of the female part.
//   clearance : diametral, applied to the internal cutter only. undef = auto.
//   bevel1/2  : bottom / top end bevels (true = one thread depth | false | size in mm).
module print_thread(d, l, pitch, internal = false, clearance = undef,
                    bevel1 = true, bevel2 = true) {
    c = is_undef(clearance) ? print_thread_clearance(d) : clearance;
    // `true` -> one thread depth at 45°. (BOSL2's own default with blunt_start is
    // r/6 — 7 mm on the Ø85 receiver retainer, longer than the thread.)
    function bev(b) = (b == true) ? print_thread_depth(pitch) : (b == false) ? 0 : b;
    assert(pitch >= PT_MIN_PITCH,
        str("print_thread: pitch ", pitch, " < ", PT_MIN_PITCH,
            " mm — too fine to print (docs/printable-threads.md rule 2)."));
    assert(l >= PT_MIN_TURNS * pitch - 0.01,
        str("print_thread: l = ", l, " is under ", PT_MIN_TURNS, " turns of a ", pitch,
            " mm pitch — lengthen it (docs/printable-threads.md rule 5)."));
    assert(c >= PT_CLEAR_BASE - 0.001,
        str("print_thread: clearance ", c, " < ", PT_CLEAR_BASE,
            " mm — printed threads need slop (docs/printable-threads.md rule 3)."));
    assert(d >= PT_MIN_D,
        str("print_thread: d = ", d, " < ", PT_MIN_D, " mm — use a heat-set insert instead."));
    trapezoidal_threaded_rod(
        d = internal ? d + c : d, l = l, pitch = pitch,
        thread_angle = 90, thread_depth = print_thread_depth(pitch),
        internal = internal, blunt_start = true,
        bevel1 = bev(bevel1), bevel2 = bev(bevel2),
        $slop = 0,                         // clearance is explicit above, not 4*$slop
        $fn = 0, $fa = PT_FA, $fs = PT_FS);
}
