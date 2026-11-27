# 05_dc_psrr_sweep

**DC Power-Supply Rejection Ratio (PSRR)**

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
| `psrr_db` | ≥ 35 (Typ 45) | **> 67.6 (step-limited @ 100µV)** | dB | PASS |
| `vt_max - vt_min` | Minimize VDD shift | **< 0.1** | mV | PASS |

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
Warning: singular matrix:  check node x1.slot4_wrapper_0.dig_in[5]

Note: Starting dynamic gmin stepping
Warning: singular matrix:  check node x1.slot4_wrapper_0.ibias1

Warning: Dynamic gmin stepping failed
Note: Starting true gmin stepping
Warning: singular matrix:  check node x1.slot4_wrapper_0.ibias1

Warning: singular matrix:  check node x1.slot4_wrapper_0.ibias1

Warning: singular matrix:  check node x1.slot4_wrapper_0.ibias1

Warning: singular matrix:  check node x1.slot4_wrapper_0.ibias1

Warning: True gmin stepping failed
Note: Starting source stepping
Warning: source stepping failed
Note: Transient op started
Note: Transient op finished successfully
 Reference value :  0.00000e+00
No. of Data Rows : 1
ASCII raw file "wind_comp_tb.raw"
Reset re-loads circuit ** sch_path: /foss/designs/skills/sg13cmos5l_wind_comp/schematic/xschem/wind_comp/wind_comp_tb.sch

Circuit: ** sch_path: /foss/designs/skills/sg13cmos5l_wind_comp/schematic/xschem/wind_comp/wind_comp_tb.sch

Doing analysis at TEMP = 27.000000 and TNOM = 27.000000

Using SPARSE 1.3 as Direct Linear Solver
Warning: singular matrix:  check node x1.slot4_wrapper_0.dig_in[5]

Warning: singular matrix:  check node x1.slot4_wrapper_0.dig_in[5]

Note: Starting dynamic gmin stepping
Warning: singular matrix:  check node x1.slot4_wrapper_0.ibias1

Warning: Dynamic gmin stepping failed
Note: Starting true gmin stepping
Warning: singular matrix:  check node x1.slot4_wrapper_0.ibias1

Warning: singular matrix:  check node x1.slot4_wrapper_0.ibias1

Warning: singular matrix:  check node x1.slot4_wrapper_0.ibias1

Warning: True gmin stepping failed
Note: Starting source stepping
Warning: source stepping failed
Note: Transient op started
Note: Transient op finished successfully
 Reference value :  3.49200e-01
No. of Data Rows : 1001
vt_min              =  3.00050e-01
Reset re-loads circuit ** sch_path: /foss/designs/skills/sg13cmos5l_wind_comp/schematic/xschem/wind_comp/wind_comp_tb.sch

Circuit: ** sch_path: /foss/designs/skills/sg13cmos5l_wind_comp/schematic/xschem/wind_comp/wind_comp_tb.sch

Doing analysis at TEMP = 27.000000 and TNOM = 27.000000

Using SPARSE 1.3 as Direct Linear Solver
Warning: singular matrix:  check node x1.slot4_wrapper_0.dig_in[5]

Warning: singular matrix:  check node x1.slot4_wrapper_0.dig_in[5]

Note: Starting dynamic gmin stepping
Warning: singular matrix:  check node x1.slot4_wrapper_0.ibias1

Warning: Dynamic gmin stepping failed
Note: Starting true gmin stepping
Warning: singular matrix:  check node x1.slot4_wrapper_0.ibias1

Warning: singular matrix:  check node x1.slot4_wrapper_0.ibias1

Warning: singular matrix:  check node x1.slot4_wrapper_0.ibias1

Warning: True gmin stepping failed
Note: Starting source stepping
Warning: source stepping failed
Note: Transient op started
Note: Transient op finished successfully
 Reference value :  3.49700e-01
No. of Data Rows : 1001
vt_max              =  3.00050e-01
vt_min = 3.000500e-01
vt_max = 3.000500e-01
psrr_db = 2.876042e+02
ASCII raw file "5.raw"
Warning: Missing charsets in String to FontSet conversion

The file "../plots/5.svg" has the Scalable Vector Graphics format.
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
Vin vin 0 dc {vcm}
.control
save all
alterparam vdd=1.08
reset
save all
dc Vin 0.25 0.35 100u
meas dc vt_min WHEN v(vout)=0.54 RISE=1
set vt_min_val = $&vt_min
set p_min = $curplot
alterparam vdd=1.32
reset
save all
dc Vin 0.25 0.35 100u
meas dc vt_max WHEN v(vout)=0.66 RISE=1
let vt_min = $vt_min_val
let psrr_db = 20 * log10(abs(0.24 / (vt_max - vt_min + 1e-15)))
let vout_min = {$p_min}.vout
print vt_min vt_max psrr_db
write @name\\.raw vout_min v(vout)
plot vout_min v(vout) title "05_dc_psrr_sweep"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg vout_min v(vout) title "05_dc_psrr_sweep"
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
C {devices/code_shown.sym} -220 80 0 0 {name=05_dc_psrr_sweep
only_toplevel=true
format="tcleval( @value )"
value="
Vin vin 0 dc {vcm}
.control
save all
alterparam vdd=1.08
reset
save all
dc Vin 0.25 0.35 100u
meas dc vt_min WHEN v(vout)=0.54 RISE=1
set vt_min_val = $&vt_min
set p_min = $curplot
alterparam vdd=1.32
reset
save all
dc Vin 0.25 0.35 100u
meas dc vt_max WHEN v(vout)=0.66 RISE=1
let vt_min = $vt_min_val
let psrr_db = 20 * log10(abs(0.24 / (vt_max - vt_min + 1e-15)))
let vout_min = {$p_min}.vout
print vt_min vt_max psrr_db
write @name\\.raw vout_min v(vout)
plot vout_min v(vout) title \"05_dc_psrr_sweep\"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg vout_min v(vout) title \"05_dc_psrr_sweep\"
.endc
"
place=end}
```

## 6. Result Figures

### Figure 1: 05_dc_psrr_sweep — 05_dc_psrr_sweep.svg

![05_dc_psrr_sweep — 05_dc_psrr_sweep.svg](figures/05_dc_psrr_sweep.svg)
