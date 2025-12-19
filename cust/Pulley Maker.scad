use <../pulleys.scad>

/* [General] */
// [snug, close, loose, gap]
margins = [.06, .1, .2, .35];

/* [Teeth] */

Nteeth = 20;

Profile = "GT2"; //["GT2", "GT3"]

Belt_width = 6;

/* [Features] */

// height of guards above and below the pulley
guard = 1; //[0:.1:10]

// height of 45deg bevel leading into guards
bevel = 0.5; //[.1:.1:5]

shaft_type = 0; //[0: hex, 1: shaft, 2:setscrew, 3:knobsetscrew, 4:clamp]

// exact shaft size (no margins applied)
shaft_size = 5.0; //[0:.01:50]

// [0:ignored] radial distance to add D profile to shaft
D_rad = 0; //[0:.01:20]

hex_size = 3; //[0: M1.6, 1:M2, 2: M2.5, 3: M3, 4: M4, 5:M5, 6:M6, 7:M7, 8:M8]
setscrew_size = 3; //[0: M1.6, 1:M2, 2: M2.5, 3: M3, 4: M4, 5:M5, 6:M6, 7:M7, 8:M8]
setscrew_minshell = 1.6;
clampscrew_size = 3; //[0: M1.6, 1:M2, 2: M2.5, 3: M3, 4: M4, 5:M5, 6:M6, 7:M7, 8:M8]

// [0:ignored] height of knob above pulley (other dimensions are auto)
autoknob = 0; //[0:.5:50]

module _end_cust_() {}

SIZE_LIST = ["M1.6", "M2", "M2.5", "M3", "M4", "M5", "M6", "M7", "M8"];
hex = SIZE_LIST[hex_size];
setscrew = SIZE_LIST[setscrew_size];
clampscrew = SIZE_LIST[clampscrew_size];

if (shaft_type == 0) {
    // hex type
    timingpulley_hex(Belt_width, Nteeth, Profile, guard, bevel, hex=hex, margins=margins, autoknob=autoknob);
} else if (shaft_type == 1) {
    // basic shaft
    timingpulley(Belt_width, Nteeth, Profile, guard, bevel, shaft_size, D_rad, margins=margins, autoknob=autoknob);
} else if (shaft_type == 2) {
    // grab shaft with setscrew
    timingpulley_setscrew(Belt_width, Nteeth, Profile, guard, bevel, shaft_size, D_rad, setscrew=setscrew, margins=margins, min_shell=setscrew_minshell, autoknob=autoknob);
} else if (shaft_type == 3) {
    // setscrew is embedded in a knob
    timingpulley_knobsetscrew(Belt_width, Nteeth, Profile, guard, bevel, shaft_size, D_rad, setscrew=setscrew, margins=margins, min_shell=setscrew_minshell, minknob=autoknob);
} else if (shaft_type == 4) {
    // grab shaft with clamp
    timingpulley_clamp(Belt_width, Nteeth, Profile, guard, bevel, shaft_size, D_rad, cscrew=clampscrew, margins=margins, autoknob=autoknob);
}
