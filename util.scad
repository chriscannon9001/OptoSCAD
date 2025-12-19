
// dict - 2d array
// item - needs to match first element in a row
function selector(item, dict) = dict[search([item], dict)[0]];

module filletsingle(radius, height, angle=90) {
    //
    // a_tri as the half-angle of the wedge
    a_tri = angle/2;
    // a_cir is the corresponding angle from the center of curv
    a_cir = 90-a_tri;
    y = radius*sin(a_cir);
    x1 = radius*cos(a_cir);
    x2 = y / tan(a_tri);
    translate([-x1-x2, 0, 0]) difference() {
        // extrude a wedge and subtract a cylinder
        linear_extrude(height)
            polygon([[x1, y], [x1+x2, 0], [x1, -y]]);
        translate([0, 0, -.001])
            cylinder(h=height+.002, r=radius);
    }
}

// 2d arc
module arc(r1, r2, a1, a2) {
    // r1 - inside radius
    // r2 - outside radius
    // a1 - start angle
    // a2 - end angle
    Np = 6;
    da = (a2 - a1)/(Np);
    r3 = r2*1.5;
    points = [[0,0], for (i=[0:Np]) [r3*cos(i*da+a1), r3*sin(i*da+a1)]];
    difference() {
        intersection() {
            circle(r=r2);
            polygon(points);
        }
        circle(r=r1);
    }
}
