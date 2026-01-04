/* 'Lens Mount, Focal'
 * A lens mount with precision focal adjuster.
 *
 * Authors:
 * Chris Cannon
 */

use <../hw_pockets.scad>
use <../hw_features.scad>
use <../flexure.scad>

vitamins = true;

// [snug, close, loose, gap]
margins = [.06, .1, .2, .35];

/* [Cage Plate] */

Cage_setscrew = "M3";

Cage_nuttype = 2; //[2: hex, 3: square, 4: tapped]

D_plate1 = 44;

L_plate1 = 50;

T_plate1 = 9.5;

// [rod, oncenter, AOI]
Cage_rods = [6.35, 30, 0];

/* [Mirror Plate] */

D_plate2 = 20;

L_plate2 = 30;

T_plate2 = 9.5;

// Mirror diameter, mm
Diameter = 12.7;

// Mirror diameter tolerance +/-, mm
Dia_tol = .3;

// Inner-diameter, thickness of flange, mm
Flange = [10.8, 1];

// Size of setscrew
Setscrew_size = "M4";

Setscrew_type = 2; //[2: hex, 3: square, 4: tapped]

// Offset (mm) from mirror opening to nut for setscrew
Setscrew_nutoffset = 2.5;

// rotation around y-axis where setscrew is attached
Setscrew_position = 90;

/* [Flexure] */

// [Length, Width, Depth, Gap]
Flex = [22, 16, 12, 1.5];

// total length of flex
L_flexTL = 36;

rh_flex = true;

/* [Actuator] */
Screw_dz = "M3";

Supportthick_dz = 3;

Nuttype_dz = 2; //[2: hex, 3: square, 4: tapped]

// springspec - ["name", OD, wire, free-length, N-coils, isclosed, isflat, 2nd-OD, color]
Spring_spec = ["8x20", 8, .8, 20, 4.8, 1, 0, 0, "red"];

compressedLength = 10;

Actuator_inset = 5;

module _end_cust_() {}

$fa = $preview? 5 : 1;
$fs = $preview? .4 : .1;

span = Flex[1] + 2*Flex[3];
s = rh_flex? 1 : -1;

module coord_actuator() {
    x = (span - compressedLength) / 2;
    y = -L_plate1/2 + Actuator_inset;
    z = Flex[2]/2;
    translate([x, s*y, z])
    rotate([0, 90, 0])
    rotate(-s*90)
    children();
}

difference() {
    union() {
        // plate1
        translate([span/2+T_plate1/2, 0])
        linear_extrude(D_plate1+Flex[2])
        square([T_plate1, L_plate1], center=true);
        // plate2
        D2 = D_plate1/2+D_plate2/2;
        translate([-span/2-T_plate2/2, 0]) {
            linear_extrude(D2+Flex[2])
            square([T_plate2, L_plate2], center=true);
            // plate2b
            linear_extrude(Flex[2])
            square([T_plate2, L_plate1], center=true);
        }
        // backing for the adjuster
        linear_extrude(Flex[2])
        polygon([[-span/2, -s*L_plate1/2],
            [span/2-compressedLength, -s*L_plate1/2],
            [span/2-compressedLength, -s*L_flexTL/2],
            [-span/2, -s*L_flexTL/2]]);
        // flexure
        thick3 = (L_flexTL - Flex[0])/2;
        flexure_translation1(Flex[0], Flex[1], Flex[2], thick1=0.8, thick2=2, thick3=thick3, bias=0);
        // connect flexure across the gap
        for (j = [-1,1]) {
            y = j*s*(Flex[0]/2+thick3/2+.25);
            x = j*(Flex[1]/2+Flex[3]/2);
            translate([x, y])
            linear_extrude(Flex[2])
            square([Flex[3], thick3-.5], center=true);
        }
    }
    // mirror cutout
    diag = sqrt(D_plate2^2+L_plate2^2);
    translate([-span/2, 0, D_plate1/2+Flex[2]])
    rotate([0, -90, 0])
    neg_mirror_cutout(diag, T_plate2, Diameter, Dia_tol, Flange, Setscrew_size, Setscrew_type, Setscrew_nutoffset, Setscrew_position, margins=margins);
    // cage rod pockets
    translate([span/2+T_plate1+.05, 0, D_plate1/2+Flex[2]])
    rotate([0, -90, 0]) {
        rad_ss = (D_plate1 - Cage_rods[1])/2 + 1;
        neg_cage1(Cage_rods[0], Cage_rods[1], T_plate1+.1, Cage_setscrew, rad_ss, ss_angle=-1,  ss_nut_type=Cage_nuttype, AOI=Cage_rods[2], margins=margins, fast=$preview, overhead=span+T_plate2, overbore=2*margins[3]);
        cylinder(h=T_plate1+.1, d=Diameter);
    }
    // actuator pockets
    coord_actuator()
    neg_adjuster_screwnutspring(Screw_dz, Spring_spec, typehead=0, typenut=Nuttype_dz, washer=true, l_compressed=compressedLength, support_thick=Supportthick_dz, access_length=10, overhead=10, margins=margins);
}

if (vitamins) {
    coord_actuator()
    vit_adjuster_screwnutspring(Screw_dz, Spring_spec, typehead=0, typenut=2, washer=true,  l_compressed=compressedLength, support_thick=Supportthick_dz);
}

