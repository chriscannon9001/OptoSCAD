use <BOLTS/BOLTS.scad>
use <MCAD/regular_shapes.scad>
use <NopSCADlib/vitamins/spring.scad>

// margins, radial in mm:
// [snug, close, loose, gap]
// snug - may or may not require force
// close - shouldn't require force, but shouldn't be sloppy
// loose - better a little sloppy than risk contact
// gap - plenty of clearance for movement
// def_margins are probably appropriate for most FDM
def_margins = [.06, .1, .2, .35];

module neg_nut_metric(size, margins=def_margins, overhead=0, Lshaft=0, Rshaft=0) {
    mar_tight = margins[1];
    mar_gap = margins[2];
    dims = DIN934_dims(size);
    minor_width = get_dim(dims, "s") + 2*mar_tight;
    thickness = get_dim(dims, "m_max") + 2*mar_gap + overhead;
    hexagon_prism(thickness, minor_width/cos(30)/2);
    // add screw shafts if required
    screw_rad = get_dim(DIN933_dims(size), "d1") / 2;
    if (Lshaft>0) {
        rotate([180, 0, 0]) cylinder(h=Lshaft, r=screw_rad+mar_gap);
    }
    if (Rshaft>0) {
        translate([0, 0, thickness]) cylinder(h=Rshaft, r=screw_rad+mar_gap);
    }
}

module neg_counterbore_metric(size, margins=def_margins, overhead=0, shaft=0) {
    mar_close = margins[1];
    mar_loose = margins[2];
    dims = ISO4762_dims(size);
    //dims = DIN934_dims(size);
    thick = get_dim(dims, "k") + 2*mar_loose + overhead;
    head = get_dim(dims, "d2")/2 + mar_loose;
    cylinder(h=thick, r=head);
    // add screw shafts if required
    screw_rad = get_dim(dims, "d1") / 2 + mar_loose;
    if (shaft>0) {
        translate([0, 0, thick]) cylinder(h=shaft, r=screw_rad+mar_loose);
    }
}

module neg_nutminoraccess_metric(size, access_length, access_taper, margins=def_margins, overhead=0, Lshaft=0, Rshaft=0) {
    mar_tight = margins[1];
    mar_gap = margins[2];
    dims = DIN934_dims(size);
    minor_width = get_dim(dims, "s") + 2*mar_tight;
    thickness = get_dim(dims, "m_max") + 2*mar_gap+overhead;
    radius = minor_width / cos(30) / 2;
    // 5 vertices of the nut, excluding 1 vertex at 0 deg
    x1 = radius * cos(60);
    x2 = radius * cos(120);
    x3 = radius * cos(180);
    x4 = radius * cos(240);
    x5 = radius * cos(300);
    y1 = radius * sin(60);
    y2 = radius * sin(120);
    y3 = radius * sin(180);
    y4 = radius * sin(240);
    y5 = radius * sin(300);
    // 2 vertices of the access slot
    xa1 = access_length+.0001;
    xa2 = access_length+.0001;
    ya2 = y1 + (access_length - x1) * tan(access_taper/2);
    ya1 = -ya2;
    // put them in a polygon and extrude
    linear_extrude(thickness)
        polygon([[x1, y1], [x2, y2], [x3, y3], [x4, y4], [x5, y5], [xa1, ya1], [xa2, ya2]]);
    // add screw shafts if required
    screw_rad = get_dim(DIN933_dims(size), "d1") / 2;
    if (Lshaft>0) {
        rotate([180, 0, 0]) cylinder(h=Lshaft, r=screw_rad+mar_gap);
    }
    if (Rshaft>0) {
        translate([0, 0, thickness]) cylinder(h=Rshaft, r=screw_rad+mar_gap);
    }
}

module neg_nutmajoraccess_metric(size, access_length, access_taper, margins=def_margins, Lshaft=0, Rshaft=0) {
    mar_tight = margins[1];
    mar_gap = margins[2];
    dims = DIN934_dims(size);
    minor_width = get_dim(dims, "s") + 2*mar_tight;
    thickness = get_dim(dims, "m_max") + 2*mar_gap;
    radius = minor_width / cos(30) / 2;
    // 4 vertices of the nut, excluding 2 vertices at +/-30 deg
    x1 = radius * cos(90);
    x2 = radius * cos(150);
    x3 = radius * cos(210);
    x4 = radius * cos(270);
    y1 = radius * sin(90);
    y2 = radius * sin(150);
    y3 = radius * sin(210);
    y4 = radius * sin(270);
    // 2 vertices of the access slot
    xa1 = access_length+.0001;
    xa2 = access_length+.0001;
    ya2 = y1 + (access_length - x1) * tan(access_taper/2);
    ya1 = -ya2;
    // put them in a polygon and extrude
    linear_extrude(thickness)
        polygon([[x1, y1], [x2, y2], [x3, y3], [x4, y4],
        [xa1, ya1], [xa2, ya2]]);
    // add screw shafts if required
    screw_rad = get_dim(DIN933_dims(size), "d1") / 2;
    if (Lshaft>0) {
        rotate([180, 0, 0]) cylinder(h=Lshaft, r=screw_rad+mar_gap);
    }
    if (Rshaft>0) {
        translate([0, 0, thickness]) cylinder(h=Rshaft, r=screw_rad+mar_gap);
    }
}

module neg_compressring_screwnut(height, OD, gap, screwsize, radius_screw, support_thick=2, margins=def_margins, marginal_height=0, access=true, topaccess=false) {
    mar_tight = margins[1];
    mar_gap = margins[2];
    // lookup screw and washer sizes in BOLTS
    screw_rad = get_dim(DIN933_dims(screwsize), "d1") / 2;
    washer_rad = get_dim(DIN125A_dims(screwsize), "d2") / 2;
    // gap the ring
    translate([0, -gap/2, 0])
        cube([OD/2+.001, gap, height+marginal_height]);
    // bore the screw
    translate([radius_screw, 0, height/2])
        rotate([90, 0, 0])
        cylinder(h=OD, r=screw_rad+mar_gap, center=true);
    // counterbore the washer
    translate([radius_screw, -support_thick-gap/2, height/2])
        rotate([90, 0, 0])
        cylinder(h=OD/2, r=washer_rad+mar_gap);
    if (access) {
        if (topaccess) {
            translate([radius_screw, support_thick+gap/2, height/2])
                rotate([0, 0, 90])
                rotate([0, 90, 0])
                neg_nutminoraccess_metric(screwsize, height/2+.001, 12, margins=margins);
        } else {
            access_length = OD/2 - radius_screw;
            translate([radius_screw, support_thick+gap/2, height/2])
                rotate([-90, 0, 0])
                neg_nutminoraccess_metric(screwsize, access_length+.001, 12, margins=margins);
        }
    } else {
        translate([radius_screw, support_thick+gap/2, height/2])
            rotate([-90, 0, 0])
            neg_nut_metric(screwsize, margins=margins);
    }
}

module vit_compressring_screwnut(height, OD, gap, screwsize, radius_screw, support_thick=2, l=10) {
    translate([radius_screw, support_thick+gap/2, height/2])
        rotate([0, 0, 90])
        rotate([0, 90, 0])
        ISO4032(screwsize);
    translate([radius_screw, -support_thick-gap/2, height/2])
        rotate([-90, 0, 0])
        ISO4762(screwsize, l=l);
}

module neg_expandring_screwnut(height, OD, gap, screwsize, radius_screw, support_thick=2, margins=def_margins, marginal_height=0, preserve_height=0, topaccess=false) {
    mar_tight = margins[1];
    mar_gap = margins[2];
    screw_rad = get_dim(DIN933_dims(screwsize), "d1") / 2;
    washer_rad = get_dim(DIN125A_dims(screwsize), "d2") / 2;
    // gap
    translate([0, -gap/2, preserve_height])
        cube([OD/2+.001, gap, height+marginal_height-preserve_height]);
    // screw bore
    translate([radius_screw, 0, height/2])
        rotate([-90, 0, 0])
        cylinder(h=OD/2, r=screw_rad+mar_gap);
    // nut with access
    if (topaccess) {
        translate([radius_screw, support_thick+gap/2, height/2])
            rotate([0, 0, 90])
            rotate([0, 90, 0])
            neg_nutminoraccess_metric(screwsize, height/2+.001, 12, margins=margins);
    } else {
        access_length = OD/2 - radius_screw;
        translate([radius_screw, support_thick+gap/2, height/2])
            rotate([-90, 0, 0])
            neg_nutminoraccess_metric(screwsize, access_length+.001, 12, margins=margins);
    }
}

module vit_expandring_screwnut(height, OD, gap, screwsize, radius_screw, support_thick=2) {
    // nut
    translate([radius_screw, support_thick+gap/2, height/2])
        rotate([0, 0, 90])
        rotate([0, 90, 0])
        ISO4032(screwsize);
    // screw
    translate([radius_screw, OD/2, height/2])
        rotate([90, 0, 0])
        ISO4762(screwsize, l=OD/2);
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

module neg_adjuster_screwnutspring(screwsize, springspec, l_compressed=0, support_thick=2, access_length=0, overhead=5, margins=def_margins) {
    mar_tight = margins[1];
    mar_gap = margins[2];
    screw_rad = get_dim(DIN933_dims(screwsize), "d1") / 2;
    washer_rad = get_dim(DIN125A_dims(screwsize), "d2") / 2;
    // calculations
    if (l_compressed==0) {l_compressed = spring_length(springspec);}
    h = l_compressed+2*(support_thick+overhead);
    // spring hole
    rad_s = spring_od(springspec)/2 + mar_gap;
    cylinder(h=l_compressed, r=rad_s, center=true);
    // screw bore
    cylinder(h=h, r=screw_rad+mar_gap, center=true);
    // nut
    if (access_length > 0) {
        translate([0, 0, l_compressed/2 + support_thick])
            neg_nutminoraccess_metric(screwsize, access_length, 12, margins=margins);
    } else {
        translate([0, 0, l_compressed/2 + support_thick])
            neg_nut_metric(screwsize, margins=margins, overhead=overhead);
    }
    // counterbore
    translate([0, 0, -l_compressed/2 - support_thick])
        rotate([0, 180, 0])
        cylinder(h=overhead, r=washer_rad+mar_gap);
}

module vit_adjuster_screwnutspring(screwsize, springspec, l_compressed=0, support_thick=2) {
    //if (l_compressed==0) {l_compressed = spring_length(springspec);}
    // calculations
    Lc = (l_compressed>0) ? l_compressed : spring_length(springspec);
    h = Lc+2*(support_thick+5);
    //spring
    translate([0, 0, -Lc/2])
        comp_spring(springspec, l=Lc);
    // nut
    translate([0, 0, Lc/2 + support_thick])
        rotate([0, 0, 30])
        color("silver")
        ISO4032(screwsize);
    // screw
    echo(h);
    translate([0, 0, -Lc])
        color("silver")
        ISO4762(screwsize, l=h);
    // I'm frustrated ISO4762 gives off a warning
}
