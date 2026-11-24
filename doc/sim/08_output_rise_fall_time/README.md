# 08_output_rise_fall_time

**Output Rise / Fall Time (tR, tF, 10-90%)**

| Field | Value |
| :--- | :--- |
| **Project** | `WINCOMP_Verification_Suite` |
| **Target Block** | `wind_comp` (TOP) |
| **Suite** | Proposal |
| **PDK Corner / Conditions** | `mos_tt` |
| **Hardcopy Target** | `../plots/@name\\.svg` |
| **Data Export** | `write` |
| **Overall Status** | `PASS` |

## 1. Measured Results Metrics

| Parameter | Target Spec | Measured Value | Unit | Status |
| :--- | :--- | :--- | :-: | :-: |
| `trise (10-90%)` | ≤ 3.0 (Typ 1.5) | **0.423** | ns | PASS |
| `tfall (90-10%)` | ≤ 3.0 (Typ 1.5) | **0.437** | ns | PASS |

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

 Reference value :  9.99540e-06
No. of Data Rows : 20033
trise               =  4.23128e-10 targ=  2.58298e-06 trig=  2.58256e-06
tfall               =  4.37065e-10 targ=  7.75615e-06 trig=  7.75572e-06
trise = 4.231279e-10
tfall = 4.370654e-10
ASCII raw file "8.raw"
Warning: Missing charsets in String to FontSet conversion

The file "../plots/8.svg" has the Scalable Vector Graphics format.
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
tran 50p 250n
meas tran trise TRIG v(vout) VAL=0.12 RISE=1 TARG v(vout) VAL=1.08 RISE=1
meas tran tfall TRIG v(vout) VAL=1.08 FALL=1 TARG v(vout) VAL=0.12 FALL=1
print trise tfall
write @name\\.raw v(vout)
plot v(vout) title "08_output_rise_fall_time"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg v(vout) title "08_output_rise_fall_time"
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
C {devices/code_shown.sym} -220 80 0 0 {name=08_output_rise_fall_time
only_toplevel=true
format="tcleval( @value )"
value="
Vin vin 0 pulse(0.29 0.31 50n 100p 100p 100n 200n)
.control
save all
tran 50p 250n
meas tran trise TRIG v(vout) VAL=0.12 RISE=1 TARG v(vout) VAL=1.08 RISE=1
meas tran tfall TRIG v(vout) VAL=1.08 FALL=1 TARG v(vout) VAL=0.12 FALL=1
print trise tfall
write @name\\.raw v(vout)
plot v(vout) title \"08_output_rise_fall_time\"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg v(vout) title \"08_output_rise_fall_time\"
.endc
"
place=end}
```

## 6. Result Figures

### Figure 1: 08_output_rise_fall_time — 8.svg

![08_output_rise_fall_time — 8.svg](pre_layout/figures/08_output_rise_fall_time.svg)
