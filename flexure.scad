//use <./hw_mates.scad>
use <./hw_features.scad>
use <./util.scad>

module slot(h, r, x1, y1, x2, y2) {
    hull() {
        translate([x1, y1, 0]) cylinder(h=h, r=r);
        translate([x2, y2, 0]) cylinder(h=h, r=r);
    }
}

module flexure_rotation1(length, width, height, n_spans, uncut_length=2, thick=0.8, vgap=0.2, fillet=0.4) {
    // flexure_rotation1 is a pair of webs that span front and
    // back plates. From the top, the cross-section of the webs
    // is an X, but the spans of the two webs don't intersect.
    // This is a classic rotation flexure, with high stiffness
    // the other 5 axes.
    // Coordinates w.r.t. center bottom, as with cylinder module
    //
    // length: mm, gap in y between front, back plates
    // width: mm, width in x of front, back plates
    // height: mm, height in z of module
    // n_spans: int, number of spans per web from plate to plate
    // uncut_length: mm, each web needs an amount of diag length not cut into spans
    // thick: mm, default 0.8, thickness of spans, normally 2x nozzle diameter
    // vgap: mm, default 0.2, need a gap between spans so they don't fuse
    // fillet: mm, radius of fillet on inside corner of spans
    length2 = length + thick/1.414;
    width2 = width - thick/1.414;
    theta = atan(length2/width2);
    diag = sqrt(length2^2 + width2^2);
    cut_len = diag - uncut_length*2;
    dy = height/(n_spans*2);
    // front and back bases
    translate([0, length/2+thick/2, height/2])
        cube([width, thick, height], center=true);
    translate([0, -length/2-thick/2, height/2])
        cube([width, thick, height], center=true);
    // even flexes
    rotate([0, 0, theta])
        difference() {
            translate([0, 0, height/2]) cube([diag, thick, height], center=true);
            for (i = [1:n_spans]) {
                y = dy * (i * 2 -.5);
                translate([0, 0, y]) cube([cut_len, thick+1, dy+vgap*2], center=true);
            }
        }
    // odd flexes
    rotate([0, 0, -theta])
        difference() {
            translate([0, 0, height/2]) cube([diag, thick, height], center=true);
            for (i = [1:n_spans+.5]) {
                y = dy * (i * 2 - 1.5);
                translate([0, 0, y]) cube([cut_len, thick+1, dy+vgap*2], center=true);
            }
        }
    // fillet
    angle = theta/2;
    y = length/2;
    x = width/2 - thick/sin(theta);
    translate([x, y, 0]) rotate([0, 0, angle])
        filletsingle(fillet, height, angle=angle*2);
    translate([-x, y, 0]) rotate([0, 0, 180-angle])
        filletsingle(fillet, height, angle=angle*2);
    translate([x, -y, 0]) rotate([0, 0, -angle])
        filletsingle(fillet, height, angle=angle*2);
    translate([-x, -y, 0]) rotate([0, 0, 180+angle])
        filletsingle(fillet, height, angle=angle*2);
}

module flexure_rotation2(length, width, height, n_spans, uncut_length=2, thick=0.8, vgap=0.2, fillet=0.4) {
    length2 = length + thick/1.414;
    width2 = width - thick/1.414;
    theta = atan(length2/width2);
    diag = sqrt(length2^2 + width2^2);
    cut_len = diag - uncut_length*2;
    dy = height/(n_spans*2);
    // front and back bases
    translate([0, length/2+thick/2, height/2])
        cube([width, thick, height], center=true);
    translate([0, -length/2-thick/2, height/2])
        cube([width, thick, height], center=true);
}

module flexure_translation1(length, width, height, thick1=0.8, thick2=2, thick3=5, bias=0) {
    // flexure_translation1 is the simplest 2-leaf translation flexure
    // This is a classic translation flexure, with high stiffness
    // the other 5 axes.
    // coordinates w.r.t. center bottom, as with cylinder module
    //
    // length: mm, gap in y between front, back plates
    // width: mm, width in x of front, back plates
    // height: mm, height in z of module
    // thick1: mm, default 0.8, thickness of leafs at their thinnest, normally 2x nozzle diameter
    // thick2: mm, default 2, thickness of leafs at their max
    // thick3: mm, default 5, thickness of ground, floating bases
    // bias: mm, default 0, top and bottom are shifted by this amount (clockwise)
    radius = thick2 - thick1;
    slope = 2*bias/length;
    difference() {
        union() {
            // bottom base
            translate([-width/2-bias, -length/2-thick3, 0]) cube([width, thick3, height]);
            // top base
            translate([-width/2+bias, length/2, 0]) cube([width, thick3, height]);
            // left side with slope (bias)
            translate([-width/2, 0, 0]) linear_extrude(height) polygon([[-bias, -length/2], [thick2-bias, -length/2], [thick2+bias, length/2], [bias, length/2]]);
            // right side with slope (bias)
            translate([width/2, 0, 0]) linear_extrude(height) polygon([[-bias, -length/2], [-thick2-bias, -length/2], [-thick2+bias, length/2], [bias, length/2]]);
        }
        dl = 1.1*thick1;
        for (s = [-1, 1]) {
            y1 = s*(.7*radius - length/2);
            y2 = y1 + s*dl;
            dx1 = y1 * slope;
            dx2 = y2 * slope;
            translate([0, 0, -.001]) slot(height+.002, radius, dx1-width/2+thick2, y1, dx2-width/2+thick2, y2);
            translate([0, 0, -.001]) slot(height+.002, radius, dx1+width/2-thick2, y1, dx2+width/2-thick2, y2);
        }
    }
}

module flexure_translation2(length, width, height, gap1=2, gap2=1, thick1=0.8, thick2=2., thick3=5) {
    // flexure_translation2 is a 4-leaf translation flexure
    // This is a classic translation flexure, with high stiffness
    // the other 5 axes.
    // Coordinates are w.r.t. the floating base
    //
    // length: mm, gap in y between front, back plates
    // width: mm, width in x of front, back plates
    // height: mm, height in z of module
    // gap1: mm, gap allowing movement
    // gap2: mm, air gap between floating and ground
    // thick1: mm, default 0.8, thickness of leafs at their thinnest, normally 2x nozzle diameter
    // thick2: mm, default 2, thickness of leafs at their max
    // thick3: mm, default 6, thickness of ground, floating bases
    radius = thick2 - thick1;
    width_g = width - 2*(thick1 + radius*2 + gap1);
    length2 = length - thick3 - gap2;
    difference() {
        union() {
            // ground platform
            translate([-width_g/2, -thick3, 0]) cube([width_g, thick3, height]);
            // moving platform
            translate([-width/2, -thick3*2-gap2, 0]) cube([width, thick3, height]);
            // floating platform
            translate([-width/2, length2, 0]) cube([width, thick3, height]);
            // leafs
            translate([(width-thick2)/2, (length2-thick3-gap2)/2, height/2]) cube([thick2, length, height], center=true);
            translate([-(width-thick2)/2, (length2-thick3-gap2)/2, height/2]) cube([thick2, length, height], center=true);
            translate([-(width_g-thick2)/2, length2/2, height/2]) cube([thick2, length2, height], center=true);
            translate([(width_g-thick2)/2, length2/2, height/2]) cube([thick2, length2, height], center=true);
            // fillets
            translate([width_g/2, length2, -.001]) rotate([0, 0, 135]) filletsingle(radius, height+.002, angle=90);
            translate([-width_g/2, length2, -.001]) rotate([0, 0, 45]) filletsingle(radius, height+.002, angle=90);
        }
        // remove cylinders to make flex lines
        translate([-width_g/2+radius+thick1, 0, -.001]) cylinder(h=height+.002, r=radius);
        translate([width_g/2-radius-thick1, 0, -.001]) cylinder(h=height+.002, r=radius);
        translate([-width/2+radius+thick1, 0, -.001]) cylinder(h=height+.002, r=radius);
        translate([width/2-radius-thick1, , -.001]) cylinder(h=height+.002, r=radius);
        translate([-width_g/2+radius+thick1, length2-radius, -.001]) cylinder(h=height+.002, r=radius);
        translate([width_g/2-radius-thick1, length2-radius, -.001]) cylinder(h=height+.002, r=radius);
        translate([width/2-radius-thick1, length2-radius, -.001]) cylinder(h=height+.002, r=radius);
        translate([-width/2+radius+thick1, length2-radius, -.001]) cylinder(h=height+.002, r=radius);
    }
}

module adjuster_alongside_neg(screwsize, springspec, H, W, l_compressed, support_thick=2, decenter=0) {
    translate([0, W/2+decenter, H/2]) rotate([0, 90, 0]) rotate([0, 0, 90]) neg_adjuster_screwnutspring(screwsize, springspec, l_compressed=l_compressed, support_thick=support_thick, overhead=W+support_thick);
}

module adjuster_alongside(screwsize, springspec, H, W, l_compressed, support_thick=2, decenter=0) {
    x1 = l_compressed/2;
    x2 = x1 + support_thick + W/2;
    x3 = x2 + W/2;
    difference() {
        union() for (s = [-1, 1]) {
            linear_extrude(H) polygon([[s*x1, 0], [s*x1, W], [s*x2, W], [s*x3, 0]]);
        }
        adjuster_alongside_neg(screwsize, springspec, H, W, l_compressed, support_thick=support_thick, decenter=decenter);
    }
}

module adjuster_alongside_vit(screwsize, springspec, H, W, l_compressed, support_thick=2, decenter=0) {
    translate([0, W/2+decenter, H/2]) rotate([0, 90, 0]) rotate([0, 0, 90]) vit_adjuster_screwnutspring(screwsize, springspec, l_compressed=l_compressed, support_thick=support_thick);
}

module flexure_translationxy1(length, width, height, thick1=0.8, thick2=2.) {
    pitch = length+width;
    xl = [0, pitch, pitch/2, pitch/2];
    yl = [pitch/2, pitch/2, 0, pitch];
    rl = [0, 0, 90, 90];
    for (i=[0:3]) {
        translate([xl[i], yl[i]])
        rotate(rl[i])
        flexure_translation1(length, width, height, thick1=thick1, thick2=thick2, thick3=width);
    }
}

$fa = 1;
$fs = 0.4;
flexure_rotation1(10, 16, 20, 4, uncut_length=3, fillet=0.6);
translate([0, -30, 0]) flexure_rotation2(10, 16, 20, 4, uncut_length=3, fillet=0.6);
translate([30, 0, 0]) flexure_translation1(10, 20, 10);
translate([55, 0, 0]) flexure_translation1(10, 20, 10, bias=1);
translate([-30, 0, 0]) flexure_translation2(16, 24, 10, thick1=0.4);
s1 = ["s1", 6., 0.5, 10, 9.0, 1, false, 0, "red"];
translate([0, 30, 0]) {
    adjuster_alongside("M3", s1, 10, 8, 6, decenter=-1);
    adjuster_alongside_vit("M3", s1, 10, 8, 6, decenter=-1);
}
