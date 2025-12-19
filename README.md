# OptoSCAD
Parametric 3d Printable Opto-mechanics.

Plastic is always going to be second-rate for opto-mech, but it actually can do many jobs as long it's not expected to carry a heavy load or high torque, or meet interferometer precision.

This project is all about turning opto-mech around faster and cheaper.

## Installation

Install OpenSCAD, find the libraries folder.

Clone from git into the libraries folder. Same goes for NopSCADlib (dependency) [https://github.com/nophead/NopSCADlib](https://github.com/nophead/NopSCADlib).

Load customizer from OpenSCAD/cust/*.scad

## What you need

* 3d Printer
* stock of screws/nuts
* stock of springs
* (optional) chop saw
* (optional) metal bar or tube stock, e.g. 12.7mm dia (posts) and 6mm dia (cages)

## Filaments

***Ranked by creep:***

* PLA (worst)
* PETG
* ASA, ABS
* PC (best)

(Where does PA belong, perhaps between PETG and ASA? Some say composite filaments are more stable but my first impression is the effect of filament filler is rather weak; PA-CF has higher creep than PC.)

PETG (and PLA) work but need to be limited to stable temperature and modest mechanical loads. PC is best although for many purposes the difference may be unimportant.

## Project Status

Organizing every form of opto-mech would be a little ambitious.

***Finished or mostly finished:***

* Adapter Plates
* Angle Right Angle
* Post holder
* Mirror Mount (post, clamp, cage, and HeNe attachments)

But the mirror mount still needs to be put in a test bed for benchmarks.

***Future plans:***

* Lens Mount
* Integrating Sphere
* Robotics
