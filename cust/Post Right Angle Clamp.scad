/* 'Post Right Angle Clamp'
 * Customizable printable post holders.
 *
 * Authors:
 * Chris Cannon
 */

use <../hw_features.scad>

// [snug, close, loose, gap]
margins = [.06, .12, .24, .35];

Post = 12.7;

Pitch = 14;

Outer = 18;

Gap = 1;

Clampscrew = "M3";

Length = 40;

Typehead = 0;

Typenut = 2;

Washer = true;

module coord1() {
    translate([Pitch/2, 0, -Outer/2-.05])
    children();
}

module coord2() {
    translate([-Pitch/2, Outer/2+.05])
    rotate([90, 0, 0])
    rotate(180)
    children();
}

margin = (Length - Pitch - Post)/2;

rad_ss = (Post + margin)/2;

OD = Post + 2*margin;

$fa=2;
$fs=.2;

difference() {
    cube([Length, Outer, Outer], center=true);
    coord1() cylinder(h=Outer+.1, d=Post);
    coord1() neg_collar_screwnut(Outer+.1, OD, Gap, Clampscrew, rad_ss, Lshaft=5, typehead=Typehead, typenut=Typenut, access=false, washer=Washer, margins=margins);
    coord2() cylinder(h=Outer+.1, d=Post);
    coord2() neg_collar_screwnut(Outer+.1, OD, Gap, Clampscrew, rad_ss, Lshaft=5, typehead=Typehead, typenut=Typenut, access=false, washer=Washer, margins=margins);
}
