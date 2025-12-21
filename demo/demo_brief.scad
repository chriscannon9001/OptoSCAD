include <OptoSCAD/hw.scad>

$fa=2;
$fs=.2;

// SHC and hex nut with pockets
translate([0, -7, 0]) {
    %neg_hex("M3", 1.0, sink=5, capture=true, minor_access=5);
    vit_hex("M3", 1, TLshaft=8);
}
translate([0, -7, -6]) rotate([180, 0, 0]) {
    %neg_boreSHC("M3", 1.0, sink=3);
    vit_SHC("M3", 1);
}

// spring/screw adjuster with SHC and hex nut
// springspec - ["name", OD, wire, free-length, N-coils, isclosed, isflat, 2nd-OD, color]
spring = ["6x20", 6, .4, 20, 12, 1, 0, 0, "red"];
translate([0, 7, 0]) {
    %neg_adjuster_screwnutspring("M3", spring, l_compressed=6, washer=true, typehead=0, typenut=2, overhead=4);
    vit_adjuster_screwnutspring("M3", spring, l_compressed=6, washer=true, typehead=0, typenut=2);
}
