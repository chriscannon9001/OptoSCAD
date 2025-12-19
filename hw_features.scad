/*
 * High-level hardware features
 *
 * Authors:
 * Chris Cannon
 */

use <NopSCADlib/vitamins/spring.scad>
use <hw_pockets.scad>

// margins, radial in mm:
// [snug, close, loose, gap]
// snug - may or may not require force
// close - shouldn't require force, but shouldn't be sloppy
// loose - better a little sloppy than risk contact
// gap - plenty of clearance for movement
// def_margins are probably appropriate for most FDM
def_margins = [.06, .1, .2, .35];

// neg_collar_screwnut
// Compressing or expanding a collar.
//
// height, OD - dimensions of collar
// gap - opening gap of collar
// screwsize - e.g. "M3", "M4" or "I6"
// radius_atscrew - on center distance from collar to screw shaft
// Lshaft - screw shaft length inside of collar
// typehead - -1: none, 0: SHC, 1: BHC, 5: flathead (default=0)
// typenut - 2: hex, 3: square, 4: tapped, 6: custom
// margins - see above
// marginal_height - vertical extension of gap height without changing screw height
// access - if true, add side access for nut (default=true)
// top_access - if true, access will be from top instead of side (default=false)
// washer - if true, add space for a washer
module neg_collar_screwnut(height, OD, gap, screwsize, radius_atscrew, Lshaft=2, typehead=0, typenut=2, nscrew=1, margins=def_margins, marginal_height=0, access=true, topaccess=false, washer=false) {
    tmp_r = topaccess ? height/2 : (OD/2-radius_atscrew);
    r_access = access ? tmp_r + .5 : 0;
    mod_rot = topaccess ? -90 : 0;
    // gap the ring
    translate([0, -gap/2, 0])
        cube([OD/2+.001, gap, height+marginal_height]);
    if (typehead>=0) for (i = [1:nscrew]) {
    // screw head
        z = (i-.5) * height/nscrew;
        translate([radius_atscrew, -gap/2, z])
        rotate([90, 0, 0])
        neg_hardware(screwsize, typehead, Lshaft, sink=OD/2, washer=washer, margins=margins);
    }
    for (i = [1:nscrew]) {
        // nut
        z = (i-.5) * height/nscrew;
        translate([radius_atscrew, gap/2, z])
        rotate([-90, 0, 0])
        rotate(mod_rot)
        neg_hardware(screwsize, typenut, Lshaft, sink=OD/2, margins=margins, capture=access, minor_access=r_access);
    }
}

module vit_collar_screwnut(height, OD, gap, screwsize, radius_atscrew, Lshaft=2, typehead=0, typenut=2, nscrew=1, washer=false, topaccess=false) {
    mod_rot = topaccess ? -90 : 0;
    if (typehead>=0) for (i = [1:nscrew]) {
        // screw head
        z = (i-.5) * height/nscrew;
        translate([radius_atscrew, 0, z])
        rotate([90, 0, 0])
        vit_hardware(screwsize, typehead, Lshaft+gap/2, washer=washer);
    }
    for (i = [1:nscrew]) {
        // nut
        z = (i-.5) * height/nscrew;
        translate([radius_atscrew, 0, z])
        rotate([-90, 0, 0])
        rotate(mod_rot)
        vit_hardware(screwsize, typenut, Lshaft+gap/2);
    }
}

// collar_clamp may be higher level than
// neg_collar_screwnut
// ID, height, wallthick - basic dimensions
// L_jaw - protruding length of jaw
// W_jaw - width of jaw
// meld - angle (degrees) to meld against a back wall
module collar_clamp(ID, height, wallthick, L_jaw, W_jaw, gap, nscrew, screwsize, nuttype, meld=50, margins=def_margins) {
    OD = ID+2*wallthick;
    meld_x = sin(meld) * OD/2;
    meld_y = cos(meld) * OD/2;
    difference() {
        union() {
            // OD
            cylinder(h=height, d=OD);
            // jaw protusion
            translate([-W_jaw/2, 0, 0])
                cube([W_jaw, L_jaw+OD/2, height]);
            // melding against the back
            translate([meld_x, -meld_y, 0])
                rotate([0, 0, 180])
                cube([2*meld_x, OD/2+wallthick-meld_y, height]);
        }
        translate([0, 0, -.1]) {
            cylinder(h=height+.2, r=ID/2);
            rotate(90)
            neg_collar_screwnut(height+.2, OD+2*L_jaw, gap, screwsize, OD/2+L_jaw/2, nscrew=nscrew, Lshaft=wallthick, margins=margins, typenut=nuttype, access=false);
        }
    }
}

module neg_thumb_circumscribe(N, OD, dent_diameter, dent_proportion, thick, angle_reduction=0) {
    circumscribe_rad = OD/2 + dent_diameter*(.5 - dent_proportion);
    for (i = [1:N]) {
        theta = i * (360 - angle_reduction) / N;
        rotate([0, 0, theta])
            translate([circumscribe_rad, 0, 0])
                cylinder(h=thick, r=dent_diameter/2);
    }
}

module thumb_knob(N, OD, dent_diameter, dent_proportion, thick, chamfer, angle_reduction=0) {
    thick2 = thick - 2*chamfer;
    rad = OD/2;
    rad2 = rad - chamfer;
    difference() {
        hull() {
            cylinder(h=thick, r=rad2);
            translate([0, 0, chamfer]) cylinder(h=thick2, r=rad);
        }
        neg_thumb_circumscribe(N, OD, dent_diameter, dent_proportion, thick, angle_reduction=angle_reduction);
    }
}

// springspec - [OD, wire, free-length, N-coils]
module neg_adjuster_screwnutspring(screwsize, springspec, typehead=0, typenut=2, washer=false, l_compressed=0, support_thick=2, access_length=0, overhead=5, margins=def_margins) {
    mar_gap = margins[2];
    // calculations
    Lc = (l_compressed>0) ? l_compressed : spring_length(springspec);
    h = Lc+2*(support_thick+overhead);
    rad_s = spring_od(springspec)/2 + mar_gap;
    // spring hole
    cylinder(h=Lc, r=rad_s, center=true);
    // screw head side
    translate([0, 0, Lc/2])
    neg_hardware(screwsize, typehead, support_thick, sink=overhead, minor_access=access_length, washer=washer, margins=margins);
    // nut
    rotate([180, 0, 0]) translate([0, 0, Lc/2])
    neg_hardware(screwsize, typenut, support_thick, sink=overhead, minor_access=access_length, washer=washer, margins=margins);
}

module vit_adjuster_screwnutspring(screwsize, springspec, typehead=0, typenut=2, washer=false,  l_compressed=0, support_thick=2) {
    // calculations
    Lc = (l_compressed>0) ? l_compressed : spring_length(springspec);
    h = Lc+2*(support_thick+5);
    //spring
    translate([0, 0, -Lc/2])
        comp_spring(springspec, l=Lc);
    // screw
    translate([0, 0, Lc/2])
        color("silver")
        vit_hardware(screwsize, typehead, support_thick, washer=washer, TLshaft=support_thick+Lc/2);
    // nut
    translate([0, 0, -Lc/2])
        rotate([180, 0, 0])
        color("silver")
        vit_hardware(screwsize, typenut, support_thick, washer=washer, TLshaft=support_thick+Lc/2);
}

// A cylinder rotated (y axis) by AOI
// and intersected with a square plate
// I.e. the cross section normal to AOI
// is circular.
module cylinder_wAOI(h, d, AOI, center=false, fast=false) {
    h2 = h / cos(AOI) + d * tan(abs(AOI)) + .1;
    w = d/cos(AOI) + h*tan(abs(AOI));
    tz = center? 0 : h/2;
    tx = center? 0 : h*tan(AOI)/2;
    if (fast) translate([tx, 0, tz]) {
        rotate([0, AOI, 0])
        cylinder(h=h2, d=d, center=true);
    } else translate([tx, 0, tz]) intersection() {
        linear_extrude(h, center=true)
        square([w, d], center=true);
        rotate([0, AOI, 0])
        cylinder(h=h2, d=d, center=true);
    }
}

// neg_cage1 makes pockets for attaching cage rods
// cage1 - rods enter into a plate and are
// held there by setscrews.
//
// rod - OD of rods
// oncenter - rod spacing on center
// depth - depth of rod pockets / depth of plate
// setscrew - size e.g. "M3" of setscrew that holds rods
// rad_setscrew - length of setscrew bore as measured from center of rod
// overhead - (default=0) depth of a clearance zone the top of the plate 
// overbore - (default=2) bore overhead dia=rod+overbore
// ss_angle - (defalt=45) angle from radial at which setscrew is placed, -1 means facing top/bottom (y-axis) instead
// ss_nut_type - (default=2) 2: hex, 3: square, 4: tapped
// N - (default=4) number of rods
// AOI - (default=0) angle-of-incidence between the cage and the plate, rotatation about y-axis
module neg_cage1(rod, oncenter, depth, setscrew, rad_setscrew, overhead=0, overbore=2, ss_angle=0, ss_nut_type=2, N=4, AOI=0, topaccess=false, fast=false, margins=def_margins) {
    // calculations
    diag = oncenter/sin(.5*360/N)/2;
    is_ud = (ss_angle<0) || (abs(AOI)>=1);
    r_z = topaccess? 180 : 0;
    union() for (i = [0:N-1]) {
        theta = (i+.5)*360/N;
        x = diag * cos(theta) / cos(AOI);
        y = diag * sin(theta);
        ss_theta = is_ud? (floor(theta/180)*180+90) : theta+ss_angle;
        translate([x, y, depth/2]) {
            cylinder_wAOI(depth, rod+2*margins[0], AOI, center=true, fast=fast||abs(AOI)<1);
            rotate(ss_theta)
            rotate([0, 90, 0])
            rotate(r_z)
            neg_hardware(setscrew, ss_nut_type, rod/2+1.6, minor_access=depth/2, capture=true, sink=-rad_setscrew, margins=margins);
            if (overhead>0) {
                dx = depth*tan(AOI)/2;
                translate([dx, 0, depth/2-.05])
                cylinder_wAOI(overhead+.05, rod+overbore, AOI, center=false, fast=fast||abs(AOI)<1);
            }
        }
    }
}

module fastener_array(even, pitch, sizespec, N, L, W) {
    Nx = N[0];
    Ny = N[1];
    halfx = (Nx<1) ? floor(W/pitch/2-even/2)+even/2 : (Nx-1)/2;
    halfy = (Ny<1) ? floor(L/pitch/2-even/2)+even/2 : (Ny-1)/2;
    startx = -halfx*pitch;
    endx = -startx;
    starty = -halfy*pitch;
    endy = -starty;
    //echo(startx, endx, starty, endy);
    for (x = [startx:pitch:endx]) for (y = [starty:pitch:endy]) {
        //echo(x, y);
        translate([x, y]) children();
    }
}
