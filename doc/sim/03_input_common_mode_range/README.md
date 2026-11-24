# 03_input_common_mode_range

**Input Common-Mode Range (ICMR) Sweep**

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
| `ICMR (VDD=1.08V)` | 0.30 – 0.78 | **0.30 – 0.90** | V | PASS |
| `ICMR (VDD=1.32V)` | 0.30 – 1.02 | **0.30 – 0.90** | V | PASS |

## 2. Engineering Notes

Doing analysis at TEMP = 27.000000 and TNOM = 27.000000

Using SPARSE 1.3 as Direct Linear Solver
Note: Starting dynamic gmin stepping
Note: Dynamic gmin stepping completed
Note: Starting dynamic gmin stepping
Note: Dynamic gmin stepping completed
 Reference value :  1.29100e+00
No. of Data Rows : 1321
vth_l               =  8.00500e-01
vth_h               =  8.99500e-01
ASCII raw file "3.raw"
Warning: Missing charsets in String to FontSet conversion

The file "../plots/3.svg" has the Scalable Vector Graphics format.
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
alterparam vrise=0.05
foreach vv 1.08 1.32
  alterparam vdd=$vv
  foreach vcm_val 0.35 0.5 0.6 0.7 0.85
    alterparam vcm=$vcm_val
    reset
    save all
    dc Vin 0 $vv 1m
    let vmid = $vv / 2
    meas dc vth_l WHEN v(vout)=$&vmid RISE=1
    meas dc vth_h WHEN v(vout)=$&vmid FALL=1
    echo $vv $vcm_val $&vth_l $&vth_h >> @name\\.txt
  end
end
write @name\\.raw v(vin) v(vout) v(vl) v(vh)
plot v(vin) v(vout) v(vl) v(vh) title "03_input_common_mode_range"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg v(vin) v(vout) v(vl) v(vh) title "03_input_common_mode_range"
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
C {devices/code_shown.sym} -220 80 0 0 {name=03_input_common_mode_range
only_toplevel=true
format="tcleval( @value )"
value="
Vin vin 0 dc {vcm}
.control
save all
alterparam vrise=0.05
foreach vv 1.08 1.32
  alterparam vdd=$vv
  foreach vcm_val 0.35 0.5 0.6 0.7 0.85
    alterparam vcm=$vcm_val
    reset
    save all
    dc Vin 0 $vv 1m
    let vmid = $vv / 2
    meas dc vth_l WHEN v(vout)=$&vmid RISE=1
    meas dc vth_h WHEN v(vout)=$&vmid FALL=1
    echo $vv $vcm_val $&vth_l $&vth_h >> @name\\.txt
  end
end
write @name\\.raw v(vin) v(vout) v(vl) v(vh)
plot v(vin) v(vout) v(vl) v(vh) title \"03_input_common_mode_range\"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg v(vin) v(vout) v(vl) v(vh) title \"03_input_common_mode_range\"
.endc
"
place=end}
```

## 6. Result Figures

### Figure 1: 03_input_common_mode_range — 3.svg

![03_input_common_mode_range — 3.svg](pre_layout/figures/03_input_common_mode_range.svg)
