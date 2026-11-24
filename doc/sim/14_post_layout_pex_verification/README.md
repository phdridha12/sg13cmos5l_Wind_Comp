# 14_post_layout_pex_verification

**Post-Layout PEX Full Re-Simulation**

| Field | Value |
| :--- | :--- |
| **Project** | `WINCOMP_Verification_Suite` |
| **Target Block** | `wind_comp` (TOP) |
| **Suite** | Proposal |
| **PDK Corner / Conditions** | `mos_tt` |
| **Hardcopy Target** | `../plots/@name\\.svg` |
| **Data Export** | `write` |
| **Overall Status** | `PENDING` |

## 1. Measured Results Metrics

| Parameter | Target Spec | Measured Value | Unit | Status |
| :--- | :--- | :--- | :-: | :-: |
| `tplh_pex / tphl_pex` | ≤ 20 | **—** | ns | PENDING |
| `tr_pex / tf_pex` | ≤ 3.0 | **—** | ns | PENDING |
| `pstat_pex` | ≤ 30 | **—** | µW | PENDING |

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
op
let pstat_pex = -i(Vdd) * v(vdd)
set p_op = $curplot
dc Vin 0 1.2 1m
meas dc vth_l_pex WHEN v(vout)=0.6 RISE=1
meas dc vth_h_pex WHEN v(vout)=0.6 FALL=1
set p_dc = $curplot
tran 100p 250n
meas tran tplh_pex TRIG v(vin) VAL=0.3 RISE=1 TARG v(vout) VAL=0.6 RISE=1
meas tran tphl_pex TRIG v(vin) VAL=0.3 FALL=1 TARG v(vout) VAL=0.6 FALL=1
meas tran tr_pex TRIG v(vout) VAL=0.12 RISE=1 TARG v(vout) VAL=1.08 RISE=1
meas tran tf_pex TRIG v(vout) VAL=1.08 FALL=1 TARG v(vout) VAL=0.12 FALL=1
print {$p_op}.pstat_pex {$p_dc}.vth_l_pex {$p_dc}.vth_h_pex tplh_pex tphl_pex tr_pex tf_pex
write @name\\.raw v(vin) v(vout)
plot v(vin) v(vout) title "14_post_layout_pex_verification"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg v(vin) v(vout) title "14_post_layout_pex_verification"
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
C {devices/code_shown.sym} -220 80 0 0 {name=14_post_layout_pex_verification
only_toplevel=true
format="tcleval( @value )"
value="
Vin vin 0 pulse(0.29 0.31 50n 100p 100p 100n 200n)
.control
save all
op
let pstat_pex = -i(Vdd) * v(vdd)
set p_op = $curplot
dc Vin 0 1.2 1m
meas dc vth_l_pex WHEN v(vout)=0.6 RISE=1
meas dc vth_h_pex WHEN v(vout)=0.6 FALL=1
set p_dc = $curplot
tran 100p 250n
meas tran tplh_pex TRIG v(vin) VAL=0.3 RISE=1 TARG v(vout) VAL=0.6 RISE=1
meas tran tphl_pex TRIG v(vin) VAL=0.3 FALL=1 TARG v(vout) VAL=0.6 FALL=1
meas tran tr_pex TRIG v(vout) VAL=0.12 RISE=1 TARG v(vout) VAL=1.08 RISE=1
meas tran tf_pex TRIG v(vout) VAL=1.08 FALL=1 TARG v(vout) VAL=0.12 FALL=1
print {$p_op}.pstat_pex {$p_dc}.vth_l_pex {$p_dc}.vth_h_pex tplh_pex tphl_pex tr_pex tf_pex
write @name\\.raw v(vin) v(vout)
plot v(vin) v(vout) title \"14_post_layout_pex_verification\"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg v(vin) v(vout) title \"14_post_layout_pex_verification\"
.endc
"
place=end}
```

## 6. Result Figures

*No result figures attached yet.*
