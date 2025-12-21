/*
 * Demo showing all the variability
 * of hw_features.
 */

use <../hw_features.scad>

/* [neg_collar_screwnut] */
OD = 50;
ID = 33;
H = 10;
rad_atscrew = 20;
Lshaft = 1.5;
screwtype = "M3";
nscrew = 1;
typehead = 0; //[-1: expansion, 0: SHC, 1: BHC, 5: flathead]
typenut = 2; //[2: hex, 3: square, 4: tapped]
washer=true;
access=true;

/* [thumb_knob] */
// number of dents
N_tk = 8;
// outer diameter of knob
OD_tk = 26;
// diameter of dents
dent_diameter = 6;
// proportion of diameter internal to OD
dent_proportion = .35;
// thickness of knob
thick_tk = 7;
// chamfer, projected
chamfer = 2;
// angle having no dents
angle_reduction = 0;

/* [neg_adjuster_screwnutspring] */
size_adj = "M3";
// springspec - ["name", OD, wire, free-length, N-coils, isclosed, isflat, 2nd-OD, color]
spring = ["6x20", 6, .4, 20, 12, 1, 0, 0, "red"];
// length of spring compressed
l_compressed = 12;
// include a washer
washer_adj = true;
overhead = 5;
typehead_adj = 0; //[0: SHC, 1: BHC, 5: flathead]
typenut_adj = 2; //[2: hex, 3: square, 4: tapped]

/* [cages] */
rod = 6;
oncenter = 30;
depth = 9;
AOI_cage1 = 0;
setscrew_cage1 = "M3";
ss_rad_cage1 = 5;
ss_nuttype_cage1 = 3; //[2: hex, 3: square, 4: tapped]
ss_angle_cage1 = 0;
overhead_cage1 = 10;
overbore_cage1 = 2;

module _end_cust_() {}

$fa=2;
$fs=.1;
%difference() {
    linear_extrude(H) difference() {
        circle(d=OD);
        circle(d=ID);
    }
    translate([0, 0, -.05]) {
    neg_collar_screwnut(H+.1, OD, Lshaft, screwtype, rad_atscrew, typehead=typehead, typenut=typenut, nscrew=nscrew,  topaccess=false, access=access, washer=washer);
    }
}
vit_collar_screwnut(H, OD, Lshaft, screwtype, rad_atscrew, typehead=typehead, typenut=typenut, nscrew=nscrew, washer=washer);

translate([0, 0, -10]) thumb_knob(N_tk, OD_tk, dent_diameter, dent_proportion, thick_tk, chamfer, angle_reduction=angle_reduction);


translate([0, 35]) {
    #neg_adjuster_screwnutspring(size_adj, spring, l_compressed=l_compressed, washer=washer_adj, typehead=typehead_adj, typenut=typenut_adj, overhead=overhead);
    vit_adjuster_screwnutspring(size_adj, spring, l_compressed=l_compressed, washer=washer_adj, typehead=typehead_adj, typenut=typenut_adj);
}

translate([0, 0, 20]) #neg_cage1(rod, oncenter, depth, setscrew_cage1, ss_rad_cage1, overhead=overhead_cage1, overbore=overbore_cage1, ss_angle=ss_angle_cage1, ss_nut_type=ss_nuttype_cage1, AOI=AOI_cage1);
