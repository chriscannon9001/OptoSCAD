/* (Truncated) Imperial + Metric tables
 * searchable by string
 *
 * For quickly setting hardware pocket sizes.
 *
 * Authors:
 * Chris Cannon
 */


// screw sizing format
// ["key", OD_shaft, [OD_wash, H_wash], [ODmin_hex, H_hex], [OD_shc, H_shc], [OD_bhc, H_bhc], [ODmin_squ, H_squ], OD_flathead]
_M2 = ["M2", 2, [5, .3], [4, 1.6], [3.8, 2], [3.5, 1.3], [0, 0], 3.8];
_M2_5 = ["M2.5", 2.5, [6, .5], [5, 2], [4.5, 2.5], [4.7, 1.5], [0, 0], 4.7];
_M3 = ["M3", 3, [7, .5], [5.5, 2.4], [5.5, 3], [5.7, 1.65], [5.5, 2.4], 5.6];
_M4 = ["M4", 4, [9, .8], [7, 3.2], [7, 4], [7.6, 2.2], [7, 3.2], 7.5];
_M5 = ["M5", 5, [10, 1], [8, 3.5], [8.5, 5], [9.5, 2.75], [8, 4], 9.2];
_M6 = ["M6", 6, [12, 1.6], [10, 4.7], [10, 6], [10.5, 3.3], [10, 5], 11];
_M8 = ["M8", 8, [16, 1.6], [13, 6.8], [13, 8], [14, 4.4], [13, 6.5], 14.5];
_I2 = ["I2", 2.18, [6.35, 0.51], [4.78, 1.68], [3.56, 2.18], [0, 0], [0 ,0], 4.37];
_I4 = ["I4", 2.84, [7.92, 0.81], [6.35, 2.49], [4.65, 2.84], [5.41, 1.5], [0, 0], 5.72];
_I6 = ["I6", 3.51, [9.53, 1.24], [7.92, 2.9], [5.74, 3.51], [6.65, 1.85], [0, 0], 7.09];
_I8 = ["I8", 4.17, [11.13, 1.24], [8.74, 3.3], [6.86, 4.17], [7.92, 2.21], [0, 0], 8.43];
_I10 = ["I10", 4.83, [12.7, 1.24], [9.53, 3.3], [7.92, 4.83], [9.17, 2.57], [0, 0], 9.78];
_Iq = ["I1/4", 6.35, [15.88, 1.65], [11.13, 4.9], [9.53, 6.35], [11.1, 3.35], [12.7, 6.35], 0];
HW_IDX = [_M2, _M2_5, _M3, _M4, _M5, _M6, _M8, _I2, _I4, _I6, _I8, _I10, _Iq];

/*for (idx = ["M2", "M2.5", "M3", "M4", "M5", "M6", "M8", "I2", "I4", "I6", "I8", "I1/4"]) {
    I = search([idx], HW_IDX, num_returns_per_match=1);
    spec = HW_IDX[I[0]];
    echo(len(spec), spec);
}*/

function hw_getspec(size) = HW_IDX[(search([size], HW_IDX, num_returns_per_match=1))[0]];

function hw_shaft(spec) = spec[1];

function hw_washer(spec) = spec[2];

function hw_hex(spec) = spec[3];

function hw_shc(spec) = spec[4];

function hw_bhc(spec) = spec[5];

function hw_squ(spec) = spec[6];

function hw_flathead(spec) = spec[7];

function hw_envelope(spec) = 
    [max([for (i=[2:6]) spec[i][0]]),
        max([for (i=[2:6]) spec[i][1]])];
