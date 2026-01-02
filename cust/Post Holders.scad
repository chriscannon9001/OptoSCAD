/* 'Post Holders'
 * Customizable printable post holders.
 *
 * Authors:
 * Chris Cannon
 */

vitamins = true;

// [snug, close, loose, gap]
margins = [.06, .1, .2, .35];

// Enter nominal tube OD; actual ID = ID + 2*close
ID = 12.7;

OD = 25;

// Hint: hexed prints easier on its side
Hexed = 0; //[0: Cylindrical, 1: Hexed]

Height = 40;

// Cam allows the post center to move away from the bolt hole
Cam = 20;

lockscrew = "M5";

lockscrewtype = 2; //[2: hex, 3: square, 4: tapped]

// Thickness substrate for base screw
Base_thick = 12;

// Size of base screw, e.g. "M6" or "I1/4"
basescrew = "M6";

// Thickness of substrate leftover under 
Base_min = 4;

// Internal chamfer that widens stance
Base_chamfer = 1.5;

basescrewtype = 1; //[0: SHC, 1: BHC, 2: hex, 3: square, 5: flatead]

basescrewwasher = true;

module _end_cust_() {}

use <../hw_pockets.scad>
use <../hwlookup.scad>
use <MCAD/regular_shapes.scad>

$fa=1;
$fs=.1;

rID = ID + 2*margins[1];
w1 = 14;
w2 = min(OD*cos(30), 22);

lspec = hw_hex(hw_getspec(lockscrew));
lthick0 = lspec[1] + margins[3] + 4;
lockthick = max(lthick0, (OD-ID)/2);

module LockBrace() {
    h = Height - w2/2;
    x = Cam - ID/2 - margins[1];
    translate([x, 0, h]) rotate([0, -90, 0]) {
        linear_extrude(lockthick, scale=w1/w2)
        square(w2, center=true);
    }
}

module LockHW() {
    h = Height - w2/2;
    x = Cam - ID/2 - margins[1] - 1;
    translate([Cam, 0, h]) rotate([0, -90, 0]) rotate([0, 0, -90])
    neg_hardware(lockscrew, lockscrewtype, ID/2+2, minor_access=OD/2, margins=margins, capture=true, sink=lockthick);
}

module body() {
    difference() {
        linear_extrude(Height) if (Hexed == 1) {
            hexagon(OD/2);
        } else {
            circle(d=OD);
        }
        // bore
        translate([0, 0, 6]) cylinder(h=Height, d=rID);
        // stabilizing bore relief
        translate([rID/4+margins[3], 0, 6]) linear_extrude(Height) square([rID/2,rID*.5], center=true);
    }
}

module slot_for_cam() {
    hull() for (x = [0, Cam]) {
        translate([x, 0, 0])
        children();
    }
}

module cam_body() {
    linear_extrude(Base_thick) slot_for_cam() {
        if (Hexed == 1) {
            hexagon(OD/2);
        } else {
            circle(d=OD);
        }
    }
}

module base_hw() {
    env = hw_envelope(hw_getspec(basescrew));
    sink = max(1, Base_thick - env[1] + 1);
    translate([Cam/2, 0, -.1])
    neg_hardware(basescrew, basescrewtype, Base_min+.1, sink=sink, slot=Cam, margins=margins, washer=basescrewwasher);
    // also Base_chamfer
    if (Base_chamfer > 0) {
        shaft = hw_shaft(hw_getspec(basescrew));
        OD = shaft+2*Base_chamfer;
        translate([0, 0, -.05]) slot_for_cam()
        cylinder(h=Base_chamfer+.05, d1=OD, d2=shaft);
    }
}

difference() {
    union() {
        translate([Cam, 0, 0]) body();
        if (Cam > 0) {cam_body();}
        LockBrace();
    }
    base_hw();
    LockHW();
}

if (vitamins) {
    #vit_hardware(basescrew, basescrewtype, Base_min, TLshaft=12, washer=basescrewwasher);
    h = Height - w2/2;
    x = Cam - ID/2 - margins[1] - 1;
    translate([x, 0, h]) rotate([0, -90, 0]) {
        #vit_hardware(lockscrew, lockscrewtype, 1, TLshaft=3);
        translate([0, 0, 12])
        #vit_hardware(lockscrew, 0, 0, TLshaft=12);
    }
}
