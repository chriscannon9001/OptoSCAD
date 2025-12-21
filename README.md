# OptoSCAD
Parametric 3d Printable Opto-mechanics.

Plastic is always going to be second-rate for opto-mech, but it actually can do many jobs as long it's not expected to carry a heavy load or high torque, or meet interferometer precision.

This project is all about turning opto-mech around faster and cheaper.

## Installation

Install OpenSCAD, find the libraries folder.

Clone from git into the libraries folder. Same goes for NopSCADlib (dependency) [https://github.com/nophead/NopSCADlib](https://github.com/nophead/NopSCADlib).

## Getting started

The folder OptoSCAD/render has some example .stl files you can open in CAD or a slicer just to get a feel for some of the common variants that are easy to produce.

See below under Project status to find links to Thingiverse, which offers 3d views of the same rendered .stl files.

Load customizer from OpenSCAD/cust/*.scad to start customizing a design.

## Required hardware

* 3d Printer
* stock of screws and nuts (e.g. M3, M4, M6)
* stock of springs (e.g. 6x20x.4 mm)
* (optional) chop saw
* (optional) metal bar or tube stock, e.g. 12.7mm dia (posts) and 6mm dia (cages)

## Filaments

***Ranked by creep:***

* PLA (worst)
* PETG
* ASA, ABS
* PC (best)

Coincidentally or not, that's the same as sorting by increasing glass transition temperature Tg.

(Where does PA belong, perhaps between PETG and ASA?)

Some say composite filaments are more stable but my impression is the effect of filament filler is rather weak; PA-CF has higher creep and is also softer than PC.

## Project Status

Bringing every form of opto-mech into the project would be a little ambitious.

***Finished or mostly finished:***

* Adapter Plates
* Adapter Right Angle
* Post Holder (on [thingiverse](https://www.thingiverse.com/thing:7243131))
* Cage Plate (on [thingiverse](https://www.thingiverse.com/thing:7243140)
* Mirror Mount with attachments for: post, clamp, cage, and HeNe. (on [thingiverse](https://www.thingiverse.com/thing:7243133))

But the mirror mount still needs to be put in a test bed for benchmarks.

***Future plans:***

* Lens Mount
* Integrating Sphere
* Robotics

## Hardware Library

There are other hardware libraries out there already, but OptoSCAD includes its own hardware library. Why do that? OptoSCAD's internal hw lib is aimed at forming negatives (pockets) for trapping nuts, counterboring screws (on the low level side) and forming screw/spring adjuster sets and other things (on the high level side), all with 3d printing in mind.

Here is a brief demo snippet.

```
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
```

![OptoSCAD demo_brief preview](./screenshots/OptoSCAD demo_brief preview.png)

Goto the folder OptoSCAD/demo and open of the demo files in OpenSCAD to see demonstrations in more detail. The files hw_pockets.scad and hw_features.scad and hwlookup.scad have additional usage documentation inline.
