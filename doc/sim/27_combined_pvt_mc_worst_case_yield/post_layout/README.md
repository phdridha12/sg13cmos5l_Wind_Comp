# 27_combined_pvt_mc_worst_case_yield

**Combined PVT + Monte Carlo Worst-Case Yield**

| Field | Value |
| :--- | :--- |
| **Project** | `WINCOMP_Verification_Suite` |
| **Target Block** | `wind_comp` (TOP) |
| **Suite** | General |
| **PDK Corner / Conditions** | `mos_tt` |
| **Hardcopy Target** | `../plots/@name\\.svg` |
| **Data Export** | `write` |
| **Overall Status** | `PENDING` |

## 1. Measured Results Metrics

| Parameter | Target Spec | Measured Value | Unit | Status |
| :--- | :--- | :--- | :-: | :-: |
| `Worst-Case 3σ VOS` | ≤ ±20 | **—** | mV | PENDING |
| `Estimated Yield` | ≥ 99.7 | **—** | % | PENDING |

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
alterparam tnom=125
set run = 1
let runs = 200
dowhile $run <= runs
  reset
  save all
  dc Vin 0 1.08 1m
  meas dc vth_l WHEN v(vout)=0.54 RISE=1
  meas dc vth_h WHEN v(vout)=0.54 FALL=1
  let vos_l = vth_l - 0.3
  let vos_h = vth_h - 0.9
  echo $run $&vos_l $&vos_h >> pvt_mc_yield.txt
  let run = $run + 1
end
wrdata pvt_mc_vtc.txt v(vin) v(vout) v(vl) v(vh)
plot v(vin) v(vout) v(vl) v(vh) title "@name\\"
set hcopydevtype=svg
hardcopy @name\\.svg v(vin) v(vout) v(vl) v(vh) title "@name\\"
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
C {devices/code_shown.sym} -220 80 0 0 {name=27_combined_pvt_mc_worst_case_yield
only_toplevel=true
format="tcleval( @value )"
value="
Vin vin 0 dc {vcm}
.control
save all
alterparam vdd=1.08
alterparam tnom=125
set run = 1
let runs = 200
dowhile $run <= runs
  reset
  save all
  dc Vin 0 1.08 1m
  meas dc vth_l WHEN v(vout)=0.54 RISE=1
  meas dc vth_h WHEN v(vout)=0.54 FALL=1
  let vos_l = vth_l - 0.3
  let vos_h = vth_h - 0.9
  echo $run $&vos_l $&vos_h >> pvt_mc_yield.txt
  let run = $run + 1
end
wrdata pvt_mc_vtc.txt v(vin) v(vout) v(vl) v(vh)
plot v(vin) v(vout) v(vl) v(vh) title \"@name\\\"
set hcopydevtype=svg
hardcopy @name\\.svg v(vin) v(vout) v(vl) v(vh) title \"@name\\\"
.endc
"
place=end}
```

## 6. Result Figures

*No result figures attached yet.*
