# 06_output_logic_voh_vol

**Output Logic High / Low (VOH, VOL)**

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
| `voh` | ≥ 1.10 | **1.200** | V | PASS |
| `vol` | ≤ 0.10 | **0.000 (~−28.5 nV)** | V | PASS |

## 2. Engineering Notes

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
Note: Starting dynamic gmin stepping
Note: Dynamic gmin stepping completed
 Reference value :  1.19600e+00
No. of Data Rows : 601
voh                 =  1.20000e+00 at=  8.94000e-01
vol                 =  -2.85448e-08 at=  9.00000e-01
voh = 1.199999e+00
vol = -2.85447e-08
ASCII raw file "6.raw"
Warning: Missing charsets in String to FontSet conversion

The file "../plots/6.svg" has the Scalable Vector Graphics format.
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
dc Vin 0 1.2 2m
meas dc voh MAX v(vout)
meas dc vol MIN v(vout)
print voh vol
write @name\\.raw v(vin) v(vout)
plot v(vin) v(vout) title "06_output_logic_voh_vol"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg v(vin) v(vout) title "06_output_logic_voh_vol"
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
C {devices/code_shown.sym} -220 80 0 0 {name=06_output_logic_voh_vol
only_toplevel=true
format="tcleval( @value )"
value="
Vin vin 0 dc {vcm}
.control
save all
dc Vin 0 1.2 2m
meas dc voh MAX v(vout)
meas dc vol MIN v(vout)
print voh vol
write @name\\.raw v(vin) v(vout)
plot v(vin) v(vout) title \"06_output_logic_voh_vol\"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg v(vin) v(vout) title \"06_output_logic_voh_vol\"
.endc
"
place=end}
```

## 6. Result Figures

### Figure 1: 06_output_logic_voh_vol — 6.svg

![06_output_logic_voh_vol — 6.svg](pre_layout/figures/06_output_logic_voh_vol.svg)
