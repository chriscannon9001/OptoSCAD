/* 'Adapter Right Angle'
 * Customizable printable right angle adapters.
 *
 * Authors:
 * Chris Cannon
 *
 */
 
use <../hw_pockets.scad>
use <../hw_features.scad>
 
vitamins = true;

// [snug, close, loose, gap]
margins = [.06, .1, .2, .35];

// Width
Width = 50.8;

// Length of bottom arm
Length = 63.5;

// Thickness of both arms
Thick = 8.5;

// Height of right arm
Height = 48.5;

// Larger chamfer can reinforce
Chamfer = 10;

// 0 = right angle between arms
Angle = 0;

/* [Bottom Hardware] */
offsetcenter_bot = 2;
even_bot = 1;
pitch_bot = 25;
N_bot = [0, 0];
size_bot = "M3";
Bshaft_bot = 1.4;
type_bot = 1; //[0: SHC, 1: BHC, 2: hex, 3: square, 4: tapped, 5: flathead, 6: custom]
washer_bot = false;
capture_bot = false;
// for hex or square, also the exact bore diameter for custom type
minor_access_bot = 0; //.01
TLshaft_bot = 8;

/* [Right Hardware] */
offsetcenter_right = 2;
even_right = 0;
pitch_right = 20;
N_right = [0, 0];
size_right = "M4";
Bshaft_right = 0.8;
type_right = 2; //[0: SHC, 1: BHC, 2: hex, 3: square, 4: tapped, 5: flathead, 6: custom]
washer_right = false;
capture_right = false;
// for hex or square, also the exact bore diameter for custom type
minor_access_right = 0; //.01
TLshaft_right = 8;

function rotation(x, y)
    = [sqrt(x^2+y^2)*cos(atan2(y,x)+Angle),
       sqrt(x^2+y^2)*sin(atan2(y,x)+Angle)];

module coord_right() {
    rotate(Angle)
    translate([-Thick, offsetcenter_right + Height/2])
    rotate([0, 90, 0])
    children();
}

module body() {
    difference() {
        linear_extrude(Width, center=true)
        polygon([[Chamfer, 0],
                 [Length, 0],
                 [Length, -Thick],
                 [-Thick, -Thick],
                 rotation(-Thick, 0),
                 rotation(-Thick, Height),
                 rotation(0, Height),
                 rotation(0, Chamfer)]);
        rotate(Angle)
        linear_extrude(Width+1, center=true)
        polygon([[-Thick, -Thick],
                 [-Thick, Thick],
                 [-Thick*2, Thick],
                 [-Thick*2, -Thick]]);
    }
}

$fa = $preview? 3 : 1;
$fs = $preview? 0.5: 0.25;

difference() {
    body();
    // bottom side fasteners
    dx = offsetcenter_bot + Length/2;
    translate([dx, -Thick, 0])
    rotate([-90, 0, 0])
    fastener_array(even_bot, pitch_bot, size_bot, N_bot, Width, Length-offsetcenter_bot) {
        neg_hardware(size_bot, type_bot, Bshaft_bot, sink=Thick+Chamfer, capture=capture_bot, washer=washer_bot, minor_access=minor_access_bot, margins=margins);
        if (vitamins) #vit_hardware(size_bot, type_bot, Bshaft_bot, washer=washer_bot, TLshaft=TLshaft_bot);
    }
    // right angle side fasteners
    //dy = offsetcenter_right + Length/2;
    //translate([-Thick, dy, 0])
    //rotate([0, 90, 0])
    coord_right()
    fastener_array(even_right, pitch_right, size_right, N_right, Height-offsetcenter_right, Width) {
        neg_hardware(size_right, type_right, Bshaft_right, sink=Thick+Chamfer, capture=capture_right, washer=washer_right, minor_access=minor_access_right, margins=margins);
        if (vitamins) #vit_hardware(size_right, type_right, Bshaft_right, washer=washer_right, TLshaft=TLshaft_right);
    }
}
