/* 'Cage Plate'
 * Cage plates, right angles, mounts.
 *
 * Authors:
 * Chris Cannon
 */

use <../hw_features.scad>
use <../hw_pockets.scad>

// [snug, close, loose, gap]
margins = [.06, .1, .2, .35];

setscrew = "M3";

nuttype = 3; //[2: hex, 3: square, 4: tapped]

/* [Main Plate] */
Depth = 50;

Length = 52;

Thick = 9.5;

// [rod, oncenter, AOI, ID]
main_cage = [6.35, 30, 0, 25];

with_secondary_cage = false;
// [rod, oncenter, AOI]
sec_cage = [6.35, 45, 0];

base_attach = 1; //[0: None, 1: Right, 2: Clamp]

// Length, width, height of right angle base
RA_base_dimensions = [8, 20, 18];

// What hardware is used for attachment to base
Attach_type = 0; //[0: SHC, 1: BHC, 2: hex, 3: square, 4: tapped, 5: flathead]

Attach_washer = true;

Attach_size = "M4"; 

// Thickness under base attach hardware
Attach_thick = 2;

// Move attachment hardware from the center of the right angle
Attach_bias = -1.5;

/* [Angle Plate] */

angleplate = 1; //[0:None, 1: Right, 2: Left]

Length2 = 52;

// 0 = right angle between plates
Angle = 0;

Chamfer = 8;

// [rod, oncenter, AOI, ID]
right_cage = [6.35, 30, 0, 25];

/* [Clamp type base] */

// ID, wall-thickness, height of clamp, mm
Clamp_dims = [12.7, 1.6, 13];

// L, W, gap of clamp jaw, mm
Clamp_jaw_dims = [7.1, 7.8, 2.5];

Clamp_Nscrew = 1;

Clamp_screwsize = "M3";

Clamp_nuttype = 2; //[2: hex, 3: square, 4: tapped]

module __Customizer_Limit__ () {}

$fa = $preview? 6 : 1;
$fs = $preview? .5 : .2;

Base_length = RA_base_dimensions[0];
Base_width = RA_base_dimensions[1];
Base_height = RA_base_dimensions[2];

Clamp_dia = Clamp_dims[0];
Clamp_wall = Clamp_dims[1];
Clamp_H = Clamp_dims[2];
Clamp_L_jaw = Clamp_jaw_dims[0];
Clamp_W_jaw = Clamp_jaw_dims[1];
Clamp_gap = Clamp_jaw_dims[2];

function rotation(x, y, dx=0, dy=0)
    = [sqrt(x^2+y^2)*cos(atan2(y,x)+Angle)+dx,
       sqrt(x^2+y^2)*sin(atan2(y,x)+Angle)+dy];

module coord_angleplate() {
    if (angleplate==0) {
    } else if (angleplate==1) {
        translate([0, Length/2])
        rotate(Angle)
        translate([Length2/2, Thick+.05])
        rotate([90, 0, 0])
        children();
    } else if (angleplate==2) {
        translate([0, -Length/2])
        rotate(Angle)
        translate([Length2/2, -Thick-.05])
        rotate([-90, 0, 0])
        children();
    }
}

module right_angle_attach() {
    translate([-Thick, 0, -Depth/2])
    rotate(-90)
    rotate([0, 90, 0])
    linear_extrude(Base_width, center=true)
    polygon([[-Base_height, 0], [0, 0], [0, -Base_length]]);
}

module body() {
    m1 = [-Thick, -Length/2];
    m2 = [0, -Length/2];
    m3 = [0, Length/2];
    m4 = [-Thick, Length/2];
    linear_extrude(Depth, center=true)
    if (angleplate==0) {
        polygon([m1, m2, m3, m4]);
    } else if (angleplate==1) {
        // angle plate on right side
        c1 = [0, Length/2-Chamfer];
        c2 = rotation(Chamfer, 0, dy=Length/2);
        r1 = rotation(Length2, 0, dy=Length/2);
        r2 = rotation(Length2, Thick, dy=Length/2);
        r3 = rotation(0, Thick, dy=Length/2);
        polygon([c1, c2, r1, r2, r3, m4, m1, m2]);
    } else if (angleplate==2) {
        // angle plate on left side
        c1 = [0, -Length/2+Chamfer];
        c2 = rotation(Chamfer, 0, dy=-Length/2);
        r1 = rotation(Length2, 0, dy=-Length/2);
        r2 = rotation(Length2, -Thick, dy=-Length/2);
        r3 = rotation(0, -Thick, dy=-Length/2);
        polygon([c1, c2, r1, r2, r3, m1, m4, m3]);
    }
    if (base_attach==2) {
        // collar clamp type of base attachment
        translate([-Thick-Clamp_dia/2, 0, -Depth/2])
        rotate(90)
        collar_clamp(Clamp_dia, Clamp_H, Clamp_wall, Clamp_L_jaw, Clamp_W_jaw, Clamp_gap, Clamp_Nscrew, Clamp_screwsize, Clamp_nuttype, margins=margins);
    } else if (base_attach==1) {
        // extrude for right angle hardware
        right_angle_attach();
    }
}

module all_negatives() {
    ohead = (angleplate==0)? 0 : Chamfer * cos(Angle);
    rad_ss = (Depth - main_cage[1])/2 + 1;
    translate([-Thick-.05, 0])
    rotate([0, 90, 0]) rotate(90) {
        // main cage
        neg_cage1(main_cage[0], main_cage[1], Thick+.1, setscrew, rad_ss, ss_angle=-1,  ss_nut_type=nuttype, AOI=main_cage[2], margins=margins, topaccess=true, overhead=ohead, overbore=0, fast=true);
        // main ID passthrough
        translate([0, 0, -Base_length])
        cylinder(h=Thick+.1+ohead+Base_length, d=main_cage[3]);
        if (with_secondary_cage) {
            // secondary cage
            rad_ss = (Depth - sec_cage[1])/2 + 1;
            neg_cage1(sec_cage[0], sec_cage[1], Thick+.1, setscrew, rad_ss, ss_angle=-1,  ss_nut_type=nuttype, AOI=sec_cage[2], margins=margins, topaccess=true, overhead=ohead, overbore=0, fast=true);
        }
    }
    // for angle plate
    coord_angleplate() {
        // cage
        rad_ss = (Depth - right_cage[1])/2 + 1;
        neg_cage1(right_cage[0], right_cage[1], Thick+.1, setscrew, rad_ss, ss_angle=-1,  ss_nut_type=nuttype, AOI=right_cage[2], margins=margins, overhead=ohead, overbore=0, fast=true);
        // passthrough
        cylinder(h=Thick+.1+ohead, d=right_cage[3]);
    }
    if (base_attach==1) {
        // right angle attachment hardware
        translate([-Thick/2-Base_length/2+Attach_bias, 0, -Depth/2])
        translate([0, 0, -.01])
        neg_hardware(Attach_size, Attach_type, Attach_thick+.01, sink=-Base_height, washer=Attach_washer, margins=margins);
    }
}

difference() {
    body();
    all_negatives();
}
