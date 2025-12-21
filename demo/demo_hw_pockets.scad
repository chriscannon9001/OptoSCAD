/*
 * Demo showing all the built in variability
 * of hardware attachment pockets,
 * and how to setup a customizer.
 */

use <../hw_pockets.scad>

// [snug, close, loose, gap]
margins = [.06, .1, .2, .35];

// text like "M2.5", "M4" for metric, "I4", "I1/4" for imperial
size = "M5";

// type of hardware
type = 0; //[0: SHC, 1: BHC, 2: hex, 3: square, 4: tapped, 5: flathead, 6: custom]

// for all
Lshaft = 3.5;

// for all
sink = 6; //.1

// for any except tapped
slot = 0; //.1

// for SHC or BHC
washer = true;

// for hex or square, also the exact bore diameter for custom type
minor_access = 8; //.01

// for hex
major_access = 0; //.1

// for nuts only
capture = true;

// for tapped only
rel_thread = 0.15;

TLshaft = 12;

module _end_cust_() {}

$fa = 2;
$fs = 0.1;

#neg_hardware(size, type, Lshaft, sink=sink, slot=slot, capture=capture, minor_access=minor_access, major_access=major_access, access_draft=12, washer=washer, rel_thread=rel_thread, margins=margins);
vit_hardware(size, type, Lshaft, washer=washer, TLshaft=TLshaft);
