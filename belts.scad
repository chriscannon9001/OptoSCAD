// Terminology:
// L - distance between pulley centers
// Cb - total Circumference of belt
// d1, d2 - diameters of pulleys
// C1, C2 - Circumferences of pulleys
// pitch - pitch from tooth to tooth
// Tb - number of teeth of belt
// T1, T2 - number of teeth of pulleys
// alpha - angle (degrees)
// beltspec - [L, pitch, Tb, T1, T2, alpha]

// an intermediate
function d0(Cb, d1, d2) = 4*Cb-2*PI*(d1+d2);

// lower level - returns the distance between pulley axles
function L_pulley_d0(d0, d1, d2) = (d0 + sqrt(d0^2 - 32*(d1-d2)^2))/16;

// returns L, the distance between pulleys
function L_pulley(Cb, d1, d2) = L_pulley_d0(d0(Cb, d1, d2), d1, d2);

// return Cb, the length of the belt
function Cb_pulley(L, d1, d2) = 2*L + PI*(d1+d2)/2 + (d1-d2)^2/(4*L);

function alpha(L, d1, d2) = asin((d1-d2)/L/2);

// round a up to the nearest mod
function next_up(a, mod) = mod*ceil(a/mod);

function Tb_nearest_belt(T1, T2, L, pitch, nearest=2) = next_up(Cb_pulley(L/pitch, T1/PI, T2/PI), nearest);

// beltspec - [L, pitch, Tb, T1, T2, alpha]
function beltspec1(T1, T2, L, pitch) = [L, pitch, Cb_pulley(L, T1/PI, T2/PI)/pitch, T1, T2, alpha(L/pitch, T1/PI, T2/PI)];

function beltspec2(T1, T2, Tb, pitch) = [pitch*L_pulley(Tb, T1/PI, T2/PI), pitch, Tb, T1, T2, alpha(L_pulley(Tb, T1/PI, T2/PI), T1/PI, T2/PI)];

// returns beltspec with Tb rounded up and L to match
function beltspec_nearest(T1, T2, L, pitch, nearest=2) = beltspec2(T1, T2, Tb_nearest_belt(T1, T2, L, pitch, nearest=nearest), pitch);

// similar to circle, but limits angular extent between a1 to a2 (degrees)
module arc(r, a1, a2) {
    del_a = abs(a2 - a1);
    // points carries a triangle wedge with a low polygon circle between arms
    points = [[0,0], for (i=[0:6]) [r*1.5*cos(a1 + i*del_a/6),r*1.5*sin(a1 + i*del_a/6)]];
    intersection() {
        polygon(points);
        circle(r);
    }
}

// form a 2d sketch of the belt
module belt_2d(beltspec, thick) {
    L = beltspec[0];
    pitch = beltspec[1];
    Tb = beltspec[2];
    T1 = beltspec[3];
    T2 = beltspec[4];
    alpha = beltspec[5];
    r1 = T1*pitch/PI/2;
    r2 = T2*pitch/PI/2;
    a11 = 90-alpha;
    a12 = 270+alpha;
    a21 = -90+alpha;
    a22 = 90-alpha;
    d = sqrt(L^2 - (r2-r1)^2);
    // belt around gear1
    difference() {
        arc(r1+thick, 90-alpha, 270+alpha);
        circle(r1);
    }
    // belt around pulley2
    translate([L, 0, 0]) difference() {
        arc(r2+thick, -90+alpha, 90-alpha);
        circle(r2);
    }
    // belt along top straight
    x = r1*cos(a11);
    y = r1*sin(a11);
    translate([x, y, 0]) rotate([0, 0, -alpha]) square([d, thick]);
    // belt along bottom straight
    x2 = (r1+thick)*cos(a12);
    y2 = (r1+thick)*sin(a12);
    translate([x2, y2, 0]) rotate([0, 0, alpha]) square([d, thick]);
}

// a little demo
spec = beltspec_nearest(50, 20, 35, 2, nearest=2);
echo(spec);
linear_extrude(6) belt_2d(spec, 2);
