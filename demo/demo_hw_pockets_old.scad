use <../hwlookup.scad>
use <../hw_pockets.scad>

with_washer = 0; //[1: yes, 0: no]

size = "M5";

module _end_() {}

spec = hw_getspec(size);
s = hw_shaft(spec);
washer = hw_washer(spec);
hex = hw_hex(spec);
shc = hw_shc(spec);
bhc = hw_bhc(spec);
env = hw_envelope(spec);
echo("spec", spec);
echo("shaft", s);
echo("washer", washer);
echo("hex", hex);
echo("shc", shc);
echo("bhc", bhc);
echo("env", env);

$fa=2;
$fs=.1;
translate([10, 0, 0]) #neg_hex(size, 2, minor_access=5);
translate([-10, 0, 0]) #neg_tapped(size, 6);
translate([0, 10, 0]) #neg_boreSHC(size, 2, washer=with_washer, slot=5);
translate([0, -10, 0]) #neg_boreBHC(size, 2, washer=with_washer);
