/* 'Adapter Plates'
 * Customizable printable adapter plates.
 *
 * Authors:
 * Chris Cannon
 *
 */

use <../hw_pockets.scad>
use <../hw_features.scad>

vitamins = true;

// [snug, close, loose, gap]
margins = [.06, .1, .2, .35];

Width = 50.8;

Length = 63.5;

Height = 8.5;

/* [Top Hardware] */
even_top = 0;
pitch_top = 20;
N_top = [0, 0];
size_top = "M4";
Bshaft_top = 0.8;
type_top = 2; //[0: SHC, 1: BHC, 2: hex, 3: square, 4: tapped, 5: flathead, 6: custom]
washer_top = false;
capture_top = false;
// for hex or square, also the exact bore diameter for custom type
minor_access_top = 0; //.01
TLshaft_top = 8;

/* [Bottom Hardware] */
even_bot = 1;
pitch_bot = 25;
N_bot = [0, 0];
size_bot = "M3";
Bshaft_bot = 1.4;
type_bot = 1; //[0: SHC, 1: BHC, 2: hex, 3: square, 4: tapped, 5: flathead, 6: custom]
washer_bot = false;
capture_bot = false;
// for hex or square, also the exact bore diameter for custom type
minor_access_bot = 0; //.01
TLshaft_bot = 8;

/* [General] */

module __end_cust__() {}

$fa = 2;
$fs = .1;
difference() {
    linear_extrude(Height) square([Width, Length], center=true);
    translate([0, 0, -.01])
    fastener_array(even_top, pitch_top, size_top, N_top, Length, Width) {
        neg_hardware(size_top, type_top, Bshaft_top, sink=-Height, capture=capture_top, washer=washer_top, minor_access=minor_access_top, margins=margins);
        if (vitamins) #vit_hardware(size_top, type_top, Bshaft_top, washer=washer_top, TLshaft=TLshaft_top);
    }
    translate([0, 0, Height+.01]) rotate([180, 0, 0])
    fastener_array(even_bot, pitch_bot, size_bot, N_bot, Length, Width) {
        neg_hardware(size_bot, type_bot, Bshaft_bot, sink=-Height, capture=capture_bot, washer=washer_bot, minor_access=minor_access_bot, margins=margins);
        if (vitamins) #vit_hardware(size_bot, type_bot, Bshaft_bot, washer=washer_bot, TLshaft=TLshaft_bot);
    }
}


