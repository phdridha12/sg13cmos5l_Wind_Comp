# 20_ac_frequency_psrr_cmrr

**AC Frequency-Dependent PSRR & CMRR**

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
| `PSRR(1kHz / 1MHz)` | ≥ 35 low-freq | **—** | dB | PENDING |
| `CMRR(1kHz / 1MHz)` | ≥ 45 low-freq | **—** | dB | PENDING |

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
Vin vin 0 dc {vl} ac 1
.control
save all
ac dec 50 1 100Meg
let adm = mag(v(xcomp1.x2.vop))
set p_dm = $curplot
alter @vin[acmag] = 0
alterparam ac_vdd=1
reset
save all
ac dec 50 1 100Meg
let avdd = mag(v(xcomp1.x2.vop))
let psrr_f = 20 * log10({$p_dm}.adm / avdd)
set p_dd = $curplot
alterparam ac_vdd=0
reset
save all
alter @vin[acmag] = 1
alter @vvl[acmag] = 1
ac dec 50 1 100Meg
let acm = mag(v(xcomp1.x2.vop))
let cmrr_f = 20 * log10({$p_dm}.adm / acm)
let psrr_db = {$p_dd}.psrr_f
write @name\\.raw psrr_db cmrr_f
plot psrr_db cmrr_f title "20_ac_frequency_psrr_cmrr"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg psrr_db cmrr_f title "20_ac_frequency_psrr_cmrr"
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
C {devices/code_shown.sym} -220 80 0 0 {name=20_ac_frequency_psrr_cmrr
only_toplevel=true
format="tcleval( @value )"
value="
Vin vin 0 dc {vl} ac 1
.control
save all
ac dec 50 1 100Meg
let adm = mag(v(xcomp1.x2.vop))
set p_dm = $curplot
alter @vin[acmag] = 0
alterparam ac_vdd=1
reset
save all
ac dec 50 1 100Meg
let avdd = mag(v(xcomp1.x2.vop))
let psrr_f = 20 * log10({$p_dm}.adm / avdd)
set p_dd = $curplot
alterparam ac_vdd=0
reset
save all
alter @vin[acmag] = 1
alter @vvl[acmag] = 1
ac dec 50 1 100Meg
let acm = mag(v(xcomp1.x2.vop))
let cmrr_f = 20 * log10({$p_dm}.adm / acm)
let psrr_db = {$p_dd}.psrr_f
write @name\\.raw psrr_db cmrr_f
plot psrr_db cmrr_f title \"20_ac_frequency_psrr_cmrr\"
set hcopydevtype=svg
hardcopy ../plots/@name\\.svg psrr_db cmrr_f title \"20_ac_frequency_psrr_cmrr\"
.endc
"
place=end}
```

## 6. Result Figures

*No result figures attached yet.*
