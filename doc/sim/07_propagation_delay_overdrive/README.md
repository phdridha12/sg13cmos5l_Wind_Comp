# 07_propagation_delay_overdrive

**Propagation Delay (tPLH, tPHL) at +/-10 mV Overdrive**

| Field | Value |
| :--- | :--- |
| **Project** | `WINCOMP_Verification_Suite` |
| **Target Block** | `wind_comp` (TOP) |
| **Suite** | Proposal |
| **PDK Corner / Conditions** | `mos_tt` |
| **Hardcopy Target** | `../plots/@name\\.svg` |
| **Data Export** | `write` |
| **Overall Status** | `FAIL` |

## 1. Measured Results Metrics

| Parameter | Target Spec | Measured Value | Unit | Status |
| :--- | :--- | :--- | :-: | :-: |
| `tplh` | ≤ 20 (Typ 10) | **580.4** | ns | FAIL |
| `tphl` | ≤ 20 (Typ 10) | **753.5** | ns | FAIL |

## 2. Engineering Notes

******
** ngspice-47 : Circuit level simulation program
** Compiled with KLU Direct Linear Solver
** The U. C. Berkeley CAD Group
** Copyright 1985-1994, Regents of the University of California.
** Copyright 2001-2026, The ngspice team.
** Please get your ngspice manual from https://ngspice.sourceforge.io/docs.html
** Please file your bug-reports at http://ngspice.sourceforge.net/bugrep.html
** Creation Date: Thu Oct 15 12:58:05 UTC 2026
******
||: No such file or directory

Note: No compatibility mode selected!


Circuit: ** sch_path: /foss/designs/skills/sg13cmos5l_wind_comp/schematic/xschem/wind_comp/wind_comp_tb.sch

Doing analysis at TEMP = 27.000000 and TNOM = 27.000000

Using SPARSE 1.3 as Direct Linear Solver
Note: Starting dynamic gmin stepping
Note: Dynamic gmin stepping completed
 Reference value :  0.00000e+00
No. of Data Rows : 1
ASCII raw file "wind_comp_tb.raw"
Doing analysis at TEMP = 27.000000 and TNOM = 27.000000

Using SPARSE 1.3 as Direct Linear Solver
Note: Starting dynamic gmin stepping
Note: Dynamic gmin stepping completed

Initial Transient Solution
--------------------------

Node                                   Voltage
----                                   -------
xcomp1.x1.votap                         1.0666
vin                                       0.29
xcomp1.x1.tail                        0.427272
vss                                          0
vdd                                        1.2
xcomp1.x1.votan                       0.673842
vh                                         0.9
xcomp1.x1.ibias_en                    0.179032
xcomp1.x1.vom                          0.55445
xcomp1.x1.vop                      4.96897e-05
xcomp1.x1.net2                     4.50246e-05
xcomp1.x1.net1                        0.952043
xcomp1.x1.x4.ibp                      0.653393
xcomp1.x1.x4.vt                       0.954275
xcomp1.x1.x4.n_mrr                    0.394196
xcomp1.x1.en_n                     6.03265e-08
en                                         1.2
xcomp1.net1                                1.2
ibias                                 0.179702
xcomp1.x2.votap                       0.793573
vl                                         0.3
xcomp1.x2.tail                       0.0203013
xcomp1.x2.votan                       0.802642
xcomp1.x2.ibias_en                    0.179032
xcomp1.x2.vom                         0.115453
xcomp1.x2.vop                          0.34875
xcomp1.x2.net2                             1.2
xcomp1.x2.net1                     0.000186358
xcomp1.x2.x4.ibp                      0.653393
xcomp1.x2.x4.vt                        0.60851
xcomp1.x2.x4.n_mrr                    0.488888
xcomp1.x2.en_n                       6.033e-08
xcomp1.net2                        6.02931e-08
xcomp1.x3.net1                             1.2
xcomp1.x3.net2                         1.02641
vout                               5.98745e-08
vin#branch                        -5.48957e-13
ven#branch                        -2.32164e-10
vss#branch                         8.77984e-06
vvl#branch                        -7.83915e-13
vvh#branch                        -6.04178e-12
vdd#branch                         -8.7796e-06

 Reference value :  4.99919e-05
No. of Data Rows : 5057
tplh                =  5.80439e-07 targ=  2.58094e-06 trig=  2.00050e-06
tphl                =  7.53522e-07 targ=  2.27550e-05 trig=  2.20015e-05
tplh = 5.804392e-07
tphl = 7.535221e-07
ASCII raw file "7.raw"
Warning: Missing charsets in String to FontSet conversion

The file "../plots/7.svg" has the Scalable Vector Graphics format.
ngspice 2 ->

## 3. Principal Code (`principal.spice`)

```spice
.param vdd=1.2 vss=0 vcm=0.6 vrise=0.3
.param vh={vcm+vrise} vl={vcm-vrise}
.param ibias=1u en=1.2 cload=0.1p rload=1G
.param fin=10k vamp=0.6 tnom=27
.param ac_vdd=0 ac_vss=0
.temp {tnom}
.option method=gear
.option savecurrents
.option filetype=ascii
.option color0=white
.option color1=black
.option hcopydevtype=svg
Vdd vdd 0 dc {vdd} ac {ac_vdd}
Vvh vh 0 dc {vh}
Cload vout 0 {cload}
Rload vout vss {rload}
Vvl vl 0 dc {vl}
Ibias vdd ibias dc {ibias}
Vss vss 0 dc {vss} ac {ac_vss}
Ven en 0 dc {en}
```

## 4. Active Code (`active.spice`)

```spice
Vin vin 0 pulse(0.29 0.31 50n 100p 100p 100n 200n)
.control
save all
tran 100p 250n
meas tran tplh TRIG v(vin) VAL=0.3 RISE=1 TARG v(vout) VAL=0.6 RISE=1
meas tran tphl TRIG v(vin) VAL=0.3 FALL=1 TARG v(vout) VAL=0.6 FALL=1
print tplh tphl
write @name\\.raw v(vin) v(vout)
plot v(vin) v(vout) title "07_propagation_delay_overdrive"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg v(vin) v(vout) title "07_propagation_delay_overdrive"
.endc
```

## 5. Xschem `code_shown.sym` Snippets (`xschem_code_shown.txt`)

```text
C {devices/code_shown.sym} -220 -160 0 0 {name=PRINCIPAL_BLOCK
only_toplevel=true
format="tcleval( @value )"
value="
.param vdd=1.2 vss=0 vcm=0.6 vrise=0.3
.param vh={vcm+vrise} vl={vcm-vrise}
.param ibias=1u en=1.2 cload=0.1p rload=1G
.param fin=10k vamp=0.6 tnom=27
.param ac_vdd=0 ac_vss=0
.temp {tnom}
.option method=gear
.option savecurrents
.option filetype=ascii
.option color0=white
.option color1=black
.option hcopydevtype=svg
Vdd vdd 0 dc {vdd} ac {ac_vdd}
Vvh vh 0 dc {vh}
Cload vout 0 {cload}
Rload vout vss {rload}
Vvl vl 0 dc {vl}
Ibias vdd ibias dc {ibias}
Vss vss 0 dc {vss} ac {ac_vss}
Ven en 0 dc {en}
"
place=header}
C {devices/code_shown.sym} -220 80 0 0 {name=07_propagation_delay_overdrive
only_toplevel=true
format="tcleval( @value )"
value="
Vin vin 0 pulse(0.29 0.31 50n 100p 100p 100n 200n)
.control
save all
tran 100p 250n
meas tran tplh TRIG v(vin) VAL=0.3 RISE=1 TARG v(vout) VAL=0.6 RISE=1
meas tran tphl TRIG v(vin) VAL=0.3 FALL=1 TARG v(vout) VAL=0.6 FALL=1
print tplh tphl
write @name\\.raw v(vin) v(vout)
plot v(vin) v(vout) title \"07_propagation_delay_overdrive\"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg v(vin) v(vout) title \"07_propagation_delay_overdrive\"
.endc
"
place=end}
```

## 6. Result Figures

### Figure 1: 07_propagation_delay_overdrive — 7.svg

![07_propagation_delay_overdrive — 7.svg](pre_layout/figures/07_propagation_delay_overdrive.svg)
