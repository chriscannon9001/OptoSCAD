/* 'Mirror Mount, Pushpull'
 * A precision mirror mount using push-pull screw-spring
 * adjusters.
 *
 * Authors:
 * Chris Cannon
 */

use <MCAD/regular_shapes.scad>
use <../hw_features.scad>
use <../hw_pockets.scad>

// [snug, close, loose, gap]
margins = [.06, .1, .2, .35];

// Rendering selection
Render = 0; //[0:Model,1:Back-only,2:Front-only,3:Inverse hardware pockets,4:Printable1,5:Printable2]

/* [Mirror Specs] */

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

/* [Plates] */

// Height, Width of mount faces, mm
Faces = [42, 42];

// Thickness of front plate, gap, back plate, mm
Thickness = [8.5, 2.5, 8.5];

// Add-on back-plate bore diameter, -1 suppresses bore, mm
Back_overbore = 0;

// Add-on bores for AOI (z-axis rotation)
AOI_overbore = 45;

// Distance from the flange to the optic-front for the purpose of AOI_overbore
AOI_optic_thick = 5;

// Extra height at bottom of back plate for right-angle version, mm
Overhang = .6;

/* [Adjusters] */

// Eliminate adjusters (tweak plate thickness also) to get a fixed mount
No_Adjusters = false;

// Size of adjuster screw
Adjuster_screwsize = "M3";

Adjuster_support_thick = 1.2;

Adj_headtype = 1; //[0: SHC, 1: BHC]

Adj_nuttype = 2; //[2: hex, 3: square]

Adj_washer = true;

// springspec - ["name", OD, wire, free-length, N-coils, isclosed, isflat, 2nd-OD, color]
Spring_spec = ["6x20", 6, .4, 20, 12, 1, 0, 0, "red"];

// Length of compressed spring when the mirror is at the nominal gap thickness
Spring_compressedL = 8;

// Margin from adjuster center to edges, mm
Adjuster_toEdge = 5;

// Make adjustments from front or back side
Adjuster_reversed = false;

// 3 or 4 adusters can be oriented a few ways
Adjuster_orientation = 0; //[0:Right,1:Left,3:All4(Any)]

/* [Base] */

// Type of base attachment
Base_Type = 0; //[0:Right Angle,1:Straight,2:Clamp,3:HeNe,4:Cage]

// What hardware is used for attachment to base
Attach_type = 0; //[0: SHC, 1: BHC, 2: hex, 3: square, 4: tapped, 5: flathead]

Attach_washer = true;

Attach_size = "M4"; 

// Thickness under base attach hardware
Attach_thick = 2;

// Move attachment hardware from the center of the right angle
Attach_bias = -1.5;

// Length, width, height of right angle base
RA_base_dimensions = [5, 16, 18];

/* [Clamp type base] */

// ID, wall-thickness, height of clamp, mm
Clamp_dims = [12.7, 1.6, 15];

// L, W, gap of clamp jaw, mm
Clamp_jaw_dims = [7.1, 7.8, 2.5];

Clamp_Nscrew = 1;

Clamp_screwsize = "M3";

Clamp_nuttype = 2; //[2: hex, 3: square, 4: tapped]

/* [HeNe type base] */

R1 = 17;

R2 = 19;

hene_theta0 = -45;

hene_screw = "M3";

hene_washer = false;

/* [Cage type base] */

// [rod, oncenter, AOI]
cage = [6.35, 30, 0];

cage_setscrew = "M3";

cage_nuttype = 2; //[2: hex, 3: square, 4: tapped]

// 0 means cage at an AOI intercepts center at the back of optic
cageAOI_center = 0;

// if cage has AOI: faster preview at expense of accuracy
fastcagepreview = true;

module __Customizer_Limit__ () {}

$fa = $preview? 5 : 1;
$fs = $preview? 0.5: 0.1;

flange_W = Flange[0];
flange_T = Flange[1];
Height = Faces[0];
Width = Faces[1];
Thick_front = Thickness[0];
Thick_gap = Thickness[1];
Thick_back = Thickness[2];
Base_length = RA_base_dimensions[0];
Base_width = RA_base_dimensions[1];
Base_height = RA_base_dimensions[2];
Clamp_dia = Clamp_dims[0];
Clamp_wall = Clamp_dims[1];
Clamp_H = Clamp_dims[2];
Clamp_L_jaw = Clamp_jaw_dims[0];
Clamp_W_jaw = Clamp_jaw_dims[1];
Clamp_gap = Clamp_jaw_dims[2];

dx_adj = Width/2 - Adjuster_toEdge;
dz_adj = Height/2 - Adjuster_toEdge;

dx_cage = -tan(cage[2])*((Thick_back+Thick_gap)/2+flange_T);

// override overhang for straight attach
Overhang2 = (Base_Type==1) ? 0 : Overhang;

// hardware tables, metric and imperial
mnut_width = [3.2, 4, 5, 5.5, 7, 8, 10, 13, 16, 4.77, 6.36, 7.94, 8.74, 9.53, 11.12];
mnut_thick = [1.3, 1.6, 2, 2.4, 3.2, 3.5, 4.7, 6.8, 8.4, 1.59, 2.39, 2.78, 3.18, 3.18, 4.83];
mscrew_dia = [1.6, 2, 2.5, 3, 4, 5, 6, 8, 10, 1.99, 2.78, 3.58, 3.97, 4.77, 6.36];
mscrew_bore = [4, 5, 6, 7, 9, 10, 12, 16, 20, 6.36, 7.94, 9.53, 11.12, 12.71, 15.88];

Adjuster_head = Base_length+1;

module adjuster_vit() {
    rot = Adjuster_reversed ? -90 : 90;
    rotate([rot, 0, 0])
    vit_adjuster_screwnutspring(Adjuster_screwsize, Spring_spec, l_compressed=Spring_compressedL, washer=Adj_washer, typehead=Adj_headtype, typenut=Adj_nuttype, support_thick=Adjuster_support_thick);
}

module adjuster_cutout() {
    max_plate = max(Thickness[0], Thickness[2]);
    spring_sunk = (Spring_compressedL - Thickness[1])/2;
    overhead = max_plate - Adjuster_support_thick - spring_sunk;
    rot = Adjuster_reversed ? -90 : 90;
    rotate([rot, 0, 0])
    neg_adjuster_screwnutspring(Adjuster_screwsize, Spring_spec, l_compressed=Spring_compressedL, washer=Adj_washer, typehead=Adj_headtype, typenut=Adj_nuttype, overhead=overhead, support_thick=Adjuster_support_thick, margins=margins);
}

module adjuster_kit() {
    if (!No_Adjusters) {
        // a set of 3 adjusters
        if (Adjuster_orientation != 0)
            translate([dx_adj, 0, dz_adj]) adjuster_cutout();
        if (Adjuster_orientation != 1)
            translate([-dx_adj, 0, dz_adj]) adjuster_cutout();
        translate([dx_adj, 0, -dz_adj]) adjuster_cutout();
        translate([-dx_adj, 0, -dz_adj]) adjuster_cutout();
    }
    // HeNe and cage attachment goes here
    // just because they affect front and back plates
    if (Base_Type == 3) {
        // slotted screw counterbores for HeNe
        rotate([-90, 0, 0])
        for (theta = [0, 90, 180, 270])
        rotate(theta+hene_theta0)
        translate([(R1+R2)/2, 0]) {
            translate([0, 0, -Thick_gap/2-Thick_back-.01])
            neg_boreSHC(hene_screw, 1, slot=R2-R1, sink=-Thick_back, washer=hene_washer, margins=margins);
            translate([0, 0, Thick_gap/2-.01])
            neg_boreSHC(hene_screw, Thick_front+.1, slot=R2-R1, sink=-.1, margins=margins);
        }
    } else if (Base_Type == 4) {
        // cage attachment
        rad_ss = (Height - cage[1])/2 + 1;
        translate([dx_cage, -Thick_gap/2-Thick_back-.05])
        rotate([-90, 0, 0])
        neg_cage1(cage[0], cage[1], Thick_back+.05, cage_setscrew, rad_ss, ss_angle=-1,  ss_nut_type=cage_nuttype, AOI=cage[2], margins=margins, topaccess=false, overhead=Thick_gap+Thick_front+.05, overbore=2, fast=fastcagepreview&&$preview);
    }
}

module adjuster_kit_vit() {
    if (!No_Adjusters) {
        // a set of 3 adjusters
        if (Adjuster_orientation != 0)
            translate([dx_adj, 0, dz_adj]) adjuster_vit();
        if (Adjuster_orientation == 0)
            translate([-dx_adj, 0, dz_adj]) adjuster_vit();
        translate([dx_adj, 0, -dz_adj]) adjuster_vit();
        translate([-dx_adj, 0, -dz_adj]) adjuster_vit();
    }
}

module AOI_overbore_front() {
    if (abs(AOI_overbore)>.1) {
        y_flange = Flange[1] + AOI_optic_thick + Thick_gap/2;
        x_tx = Thick_front * tan(AOI_overbore);
        translate([0, y_flange])
        rotate([-90, 0, 0])
        hull() for (x=[-x_tx, x_tx]) {
            cylinder(h=.01, d=Diameter);
            translate([x, 0, Thick_front]) cylinder(h=.01, d=Diameter);
        }
    }
}

module AOI_overbore_back() {
    if (abs(AOI_overbore)>.1) {
        thick = Thick_back+Thick_gap+Base_length;
        x_tx = thick * tan(AOI_overbore);
        translate([0, Thick_gap/2])
        rotate([-90, 0, 0])
        hull() for (x=[-x_tx, x_tx]) {
            cylinder(h=.01, d=Diameter);
            translate([x, 0, -thick]) cylinder(h=.01, d=Diameter);
        }
    }
}

module mirror_cutout() {
    rotate([0, -Setscrew_position, 0]) {
    dy = (flange_W > 0 && flange_T > 0) ? + flange_T : -.1;
    y = Thick_gap/2 + dy;
    depth = (Thick_front + .3 - dy);
    dia = Diameter + Dia_tol;
    // the mirror itself
    translate([0, y, 0])
        rotate([-90, 0, 0])
        cylinder(h=depth, r=dia/2);
    // slot type clearance around right side
    translate([Dia_tol*2, y, 0])
        rotate([-90, 0, 0])
        cylinder(h=depth, r=dia/2);
    translate([Dia_tol, depth/2+y, 0])
        cube([Dia_tol*2, depth, dia], center=true);
    // flange bore
    if (flange_W > 0 && flange_T > 0) {
        rotate([-90, 0, 0])
            cylinder(h=Thick_gap/2+flange_T+.1, r=(flange_W/2));
    }
    // smaller bore opening to the left of the mirror, focusing stress on 2 lines
    translate([-dia/5, y, 0])
        rotate([-90, 0, 0])
        cylinder(h=depth, r=dia/2/1.4);
    // setscrew
    translate([0, (Thick_gap+Thick_front)/2, 0])
        rotate([0, 90, 0])
        rotate(90)
        neg_hardware(Setscrew_size, Setscrew_type, Setscrew_nutoffset+(Diameter+Dia_tol)/2, capture=true, minor_access=10, sink=(Width/1.41-Diameter/2), margins=margins);
    }
    AOI_overbore_front();
}

module right_angle_attach() {
    difference() {
        rotate([0, 90, 0])
            linear_extrude(Base_width, center=true)
            polygon([[-Base_height, 0], [0, 0], [0, -Base_length]]);
    }
}

module front_plate() {
    difference() {
        translate([0, (Thick_gap + Thick_front)/2, 0])
            cube([Width, Thick_front, Height], center=true);
        adjuster_kit();
        mirror_cutout();
    }
}

module hardware_attach() {
    if (Base_Type != 1) {
        if (Back_overbore >= 0) {
            // bore through back plate for transmitted beam
            // suppressed if Back_overbore < 0
            rotate([90, 0, 0])
                cylinder(h=Thick_gap/2+Thick_back+Base_length, r=(Diameter+Dia_tol*1.5)/2+margins[2]+Back_overbore/2);
                    AOI_overbore_back();
        }
    }
    if (Base_Type == 0) {
        translate([0, -Thick_gap/2-Thick_back/2-Base_length/2+Attach_bias, -Height/2-Overhang2])
            translate([0, 0, -.01])
            neg_hardware(Attach_size, Attach_type, Attach_thick+.01, sink=-Base_height, washer=Attach_washer, margins=margins);
    } else if (Base_Type == 1) {
        translate([0, -Thick_back-Thick_gap/2, 0])
            rotate([-90, 0, 0])
            translate([0, 0, -.01])
            neg_hardware(Attach_size, Attach_type, Attach_thick+.01, sink=-Base_height, washer=Attach_washer, margins=margins);
    }
}

module back_plate() {
    difference() {
        union() {
            translate([0, -(Thick_gap + Thick_back)/2, -Overhang2/2])
                cube([Width, Thick_back, Height+Overhang2], center=true);
            if (Base_Type == 0) {
                translate([0, -Thick_gap/2-Thick_back, -Height/2-Overhang])
                    right_angle_attach();
            } else if (Base_Type == 2) {
                translate([0, -Thick_gap/2-Thick_back-Clamp_dia/2, -Height/2-Overhang])
                rotate([0, 0, 180])
                collar_clamp(Clamp_dia, Clamp_H, Clamp_wall, Clamp_L_jaw, Clamp_W_jaw, Clamp_gap, Clamp_Nscrew, Clamp_screwsize, Clamp_nuttype, margins=margins);
            }
        }
        adjuster_kit();
        hardware_attach();
    }
}

if (Render == 0) {
    back_plate();
    front_plate();
    adjuster_kit_vit();
} else if (Render == 1) {
    back_plate();
} else if (Render == 2) {
    front_plate();
} else if (Render == 3) {
    %front_plate();
    %back_plate();
    mirror_cutout();
    adjuster_kit();
    hardware_attach();
} else if (Render == 4) {
    translate([Width/2+5, 0, -Thick_gap/2])
        rotate([-90, 0, 0])
        back_plate();
    translate([-Width/2-5, 0, -Thick_gap/2])
        rotate([90, 0, 0])
        front_plate();
} else if (Render == 5) {
    back_plate();
    translate([0, 6, -Overhang])
        front_plate();
}
