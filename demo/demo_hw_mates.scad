include <../hw_mates.scad>

// Some demos for hw_mates.scad 
$fa = 1;
$fs = 0.4;
translate([0, 0, 15])
    #neg_nutminoraccess_metric("M8", 8, 20);
translate([0, 0, -15])
    #neg_nutmajoraccess_metric("M8", 8, 20);
translate([0, 0, -25]) {
    #neg_expandring_screwnut(8, 26, 0.5, "M3", 10, 2);
    color("gray")
        vit_expandring_screwnut(8, 26, 0.5, "M3", 10, 2);
}
translate([0, 0, 30]) {
    #neg_compressring_screwnut(8, 26, 0.5, "M3", 10, 2);
    color("gray")
        vit_compressring_screwnut(8, 26, 0.5, "M3", 10, 2);
    //height, OD, gap, screwsize, radius_screw, support_thick=2
}
translate([0, 0, -4]) difference() {
    cylinder(h=5, r=26/2);
    neg_thumb_circumscribe(8, 26, 6, .35, 7);
}
translate([0, 0, 4]) thumb_knob(8, 26, 6, .35, 7, 2);
s1 = ["s1", 6., 0.5, 10, 9.0, 1, false, 0, "red"];
translate([30, 0, 0]) {
    #neg_adjuster_screwnutspring("M3", s1, 6, support_thick=2, access_length=5);
    color("silver")
        vit_adjuster_screwnutspring("M3", s1, 6, support_thick=2);
}
