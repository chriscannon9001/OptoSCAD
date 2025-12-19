use <./util.scad>
include <./hw_pockets.scad>
include <./hw_features.scad>
include <./hwlookup.scad>

// tooth specs
//    ["name",  P,  R1, R2, R3, b,  H,  h,  i,  PLD]
GT2 = ["GT2",   2,  .15,1,  .555,.4,1.38,.75,.63,.254];
GT3 = ["GT3",   3,  .25,1.52,.85,.61,2.4,1.14,1.26,.381];
TOOTHDB = [GT2, GT3];

// coordinates of all timing pulleys are w.r.t.
// the base of the timing teeth, axle up along z

module timing_teeth_neg(W, N, tooth, margins=def_margins, margins=def_margins) {
    // W - width of belt, not including print margin
    // N - number of teeth
    // tooth - "GT2" or "GT3", tooth pitch and profile
    // margins - (optional) printing margins
    marg_snug = margins[0];
    marg_loose = margins[2];
    W2 = W + marg_loose;
    tspec = selector(tooth, TOOTHDB);
    pitch = tspec[1];
    //R1 = tspec[2];
    R2 = tspec[3]-marg_snug;
    R3 = tspec[4]+marg_snug;
    b = tspec[5];
    H = tspec[6];
    h = tspec[7];
    i = tspec[8];
    PLD = tspec[9];
    pitch_circumf = N * pitch;
    pitch_rad = pitch_circumf / PI / 2;
    gearrad = pitch_rad - PLD;
    a_c = atan2(b, R3-h);
    //echo(a_c);
    for (j = [1:N]) {
        // each tooth
        rotate([0, 0, (j-1)*360/N]) translate([gearrad, 0, 0]) hull() {
            translate([-h+R3, 0, 0]) cylinder(h=W2, r=R3);
            translate([0, b, 0]) linear_extrude(W2) arc(0, R2, -a_c, -90);
            translate([0, -b, 0]) linear_extrude(W2) arc(0, R2, 90, a_c);
            linear_extrude(W2) polygon([[i,b-R2], [i+.1,0], [i,R2-b]]);
        }
    }
}

module shaft_sketch(shaft, D=0) {
    difference() {
        circle(r=shaft/2);
        if (D > 0) translate([D, -shaft/2, 0]) square([shaft, shaft]);
    }
}

module autoknob(W, N, tooth, guard, bevel, height=8, margins=def_margins, Nthumb=8) {
    // Generate a knob which automatically has the right
    // diameter and chamfer size to print atop a pulley.
    tspec = selector(tooth, TOOTHDB);
    pitch = tspec[1];
    PLD = tspec[9];
    pitch_circumf = N * pitch;
    pitch_rad = pitch_circumf / PI / 2;
    gearrad = pitch_rad - PLD;
    bevel1 = height/4;
    rad0 = gearrad + bevel;
    rad1 = rad0 + bevel1;
    // .. I could write a formula that varies Nthumb
    dent_dia = min(16, rad1*PI/Nthumb*1.1);
    thumb_knob(Nthumb, rad1*2, dent_dia, .35, height, bevel1);
}

module timingpulley(W, N, tooth, guard, bevel, shaft, D=0, margins=def_margins, autoknob=0) {
    marg_loose = margins[2];
    W2 = W + marg_loose;
    tspec = selector(tooth, TOOTHDB);
    pitch = tspec[1];
    //R1 = tspec[2];
    //R2 = tspec[3];
    //R3 = tspec[4];
    //b = tspec[5];
    //H = tspec[6];
    //h = tspec[7];
    //i = tspec[8];
    PLD = tspec[9];
    pitch_circumf = N * pitch;
    pitch_rad = pitch_circumf / PI / 2;
    gearrad = pitch_rad - PLD;
    difference() {
        union() {
            // pulley, teeth
            difference() {
                cylinder(h=W2, r=gearrad);
                timing_teeth_neg(W, N, tooth, margins=margins);
            }
            // top guard
            translate([0, 0, W2]) hull() {
                cylinder(h=guard, r=gearrad);
                translate([0, 0, bevel]) cylinder(h=guard-bevel, r=gearrad+bevel);
            }
            // bottom guard
            rotate([180, 0, 0]) hull() {
                cylinder(h=guard, r=gearrad);
                translate([0, 0, bevel]) cylinder(h=guard-bevel, r=gearrad+bevel);
            }
            // knob if required
            if (autoknob > 0) difference() {
                translate([0, 0, W2+guard]) autoknob(W, N, tooth, guard, bevel, height=autoknob, margins=margins);
                translate([0, 0, W2+guard-.001]) linear_extrude(autoknob+.002) shaft_sketch(shaft, D=D);
            }
        }
        // shaft
        translate([0, 0, -guard-.001]) linear_extrude(W2+2*guard+.002) shaft_sketch(shaft, D=D);
        //cylinder(h=W+2*guard+.002, r=shaft/2);
    }
}

module timingpulley_clamp(W, N, tooth, guard, bevel, shaft, D=0, cscrew="M2.5", margins=def_margins, autoknob=0, washer=false) {
    marg_loose = margins[2];
    W2 = W + marg_loose;
    //washer_rad = get_dim(DIN125A_dims(cscrew), "d2") / 2;
    spec = hw_getspec(cscrew);
    tmp = washer? hw_washer(spec) : hw_shc(spec);
    OD_hw = tmp[0];
    dia_clamp = shaft + 2*OD_hw + 2;
    rad_atscrew = shaft/2 + OD_hw/2;
    heightclamp = 1.1*OD_hw + 2;
    zclamp = -guard - heightclamp;
    // get a timing pulley
    timingpulley(W, N, tooth, guard, bevel, shaft, D=D, margins=margins, autoknob=autoknob);
    // clamp zone
    difference() {
        translate([0, 0, zclamp]) cylinder(h=heightclamp, r=dia_clamp/2);
        translate([0, 0, zclamp-.001]) linear_extrude(heightclamp+.002) shaft_sketch(shaft, D=D);
        translate([0, 0, zclamp-.001]) neg_collar_screwnut(heightclamp+.001, dia_clamp, .6, cscrew, rad_atscrew, Lshaft=1.2, margins=margins);
        translate([0, 0, zclamp-.001]) rotate([0, 0, 180]) neg_collar_screwnut(heightclamp+.001, dia_clamp, .6, cscrew, rad_atscrew, Lshaft=1.2, margins=margins);
    }
}

module timingpulley_clamp_vit(W, N, tooth, guard, bevel, shaft, D=0, cscrew="M2.5", margins=def_margins, washer=false) {
    marg_loose = margins[2];
    W2 = W + marg_loose;
    //washer_rad = get_dim(DIN125A_dims(cscrew), "d2") / 2;
    spec = hw_getspec(cscrew);
    tmp = washer? hw_washer(spec) : hw_shc(spec);
    OD_hw = tmp[0];
    dia_clamp = shaft + 2*OD_hw + 2;
    rad_atscrew = shaft/2 + OD_hw/2;
    heightclamp = 1.1*OD_hw + 2;
    zclamp = -guard - heightclamp;
    translate([0, 0, zclamp]) vit_collar_screwnut(heightclamp, dia_clamp, .6, cscrew, rad_atscrew, Lshaft=1.2, washer=washer);
    translate([0, 0, zclamp]) rotate([0, 0, 180]) vit_collar_screwnut(heightclamp, dia_clamp, .6, cscrew, rad_atscrew, Lshaft=1.2, washer=washer);
}

module timingpulley_hex(W, N, tooth, guard, bevel, hex="M4", Lshaft=1.2, margins=def_margins, autoknob=0) {
    marg_close = margins[1];
    marg_loose = margins[2];
    W2 = W + marg_loose;
    difference() {
        // get a timing pulley
        timingpulley(W, N, tooth, guard, bevel, 0.5, margins=margins, autoknob=autoknob);
        // hex
        translate([0, 0, -guard-.05]) neg_hex(hex, Lshaft, sink=2*guard+W+autoknob-Lshaft, margins=margins);
    }
}

module timingpulley_setscrew(W, N, tooth, guard, bevel, shaft, D=0, setscrew="M3", min_shell=1.6, margins=def_margins, autoknob=0) {
    marg_loose = margins[2];
    W2 = W + marg_loose;
    // get a timing pulley
    timingpulley(W, N, tooth, guard, bevel, shaft, D=D, margins=margins, autoknob=autoknob);
    // add a collar for setscrews
    spec = hw_getspec(setscrew);
    tmp = hw_hex(spec);
    nut_width = tmp[0];
    nut_thick = tmp[1];
    rad_ring = min_shell + sqrt((nut_width/2+.12)^2 + (shaft/2+nut_thick+.4+min_shell)^2);
    h_ring = nut_width/cos(30) + 2*1.2;
    translate([0, 0, -guard]) rotate([0, 180, 0]) difference() {
        cylinder(h=h_ring, r=rad_ring);
        translate([0, 0, -.001]) linear_extrude(h_ring+.002) shaft_sketch(shaft, D=D);
        for (theta=[0, 180]) translate([0, 0, h_ring/2]) rotate([0, 90, theta]) {
            rotate([0, 0, 180])
            neg_hex(setscrew, min_shell+shaft/2, sink=min_shell+shaft/2, capture=true, minor_access=h_ring/2+.2);
        }
    }
}

module timingpulley_knobsetscrew(W, N, tooth, guard, bevel, shaft, D=0, setscrew="M3", min_shell=1.6, margins=def_margins, minknob=8) {
    marg_loose = margins[2];
    W2 = W + marg_loose;
    tspec = selector(tooth, TOOTHDB);
    rad_gear = (tspec[1]*N/PI)/2;
    // calculated parameters
    //nut_width = get_dim(DIN934_dims(setscrew), "s");
    //nut_thick = get_dim(DIN934_dims(setscrew), "m_max");
    sspec = hw_hex(hw_getspec(setscrew));
    nut_width = sspec[0];
    nut_thick = sspec[1];
    rad_ring = min_shell + sqrt((nut_width/2+.12)^2 + (shaft/2+nut_thick+.4+min_shell)^2);
    h_ring = nut_width/cos(30) + 2*1.2;
    h_knob = max(minknob, h_ring);
    difference() {
        union() {
            // get a timing pulley
            timingpulley(W, N, tooth, guard, bevel, shaft, D=D, margins=margins, autoknob=h_knob);
            // minimum collar for setscrews
            translate([0, 0, W2+guard]) rotate([0, 0, 0]) cylinder(h=h_knob, r=rad_ring);
        }
        translate([0, 0, W2+guard]) rotate([0, 0, 0]) union() {
            translate([0, 0, -.001]) linear_extrude(h_knob+.002) shaft_sketch(shaft, D=D);
            for (theta=[0, 180]) translate([0, 0, h_knob/2]) rotate([0, 90, theta]) {
        // the setscrew and nut pockets
        rotate([0, 0, 180]) neg_hex(setscrew, min_shell+shaft/2, minor_access=h_knob/2+.2, margins=margins, capture=true, sink=max(rad_gear,min_shell*1.5));
            }
        }
    }
}


$fa = .5;
$fs = 0.1;
//margins = [0, 0, 0, 0];
translate([0, 30, 0]) timingpulley(6, 30, "GT2", 1, .5, 4, 1.5, autoknob=8);
timingpulley_clamp(6, 40, "GT2", 1, .5, 5, cscrew="M2.5", D=2);
#timingpulley_clamp_vit(6, 40, "GT2", 1, .5, 5, cscrew="M2.5", D=2);
translate([30, 0, 0]) timingpulley_hex(6, 30, "GT2", 1, .5, hex="M3", autoknob=8);
translate([-30, 0, 0]) timingpulley_setscrew(6, 35, "GT2", 1, .5, 5, autoknob=8);
translate([0, -30, 0]) timingpulley_knobsetscrew(6, 30, "GT2", 1, .5, 5, minknob=10);
