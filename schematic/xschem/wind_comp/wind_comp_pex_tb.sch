v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
L 4 10 -860 150 -860 {}
L 4 150 -860 290 -860 {}
L 4 290 -860 430 -860 {}
L 4 10 -780 490 -780 {}
L 4 10 -700 490 -700 {}
L 4 10 -620 490 -620 {}
L 4 10 -540 490 -540 {}
L 4 10 -860 10 -540 {}
L 4 70 -860 70 -540 {}
L 4 130 -860 130 -540 {}
L 4 190 -860 190 -540 {}
L 4 250 -860 250 -540 {}
L 4 310 -860 310 -540 {}
L 4 370 -860 370 -540 {}
L 4 430 -860 430 -540 {}
L 4 490 -860 490 -540 {}
L 4 10 -940 10 -860 {}
L 4 10 -940 490 -940 {}
L 4 490 -940 490 -860 {}
L 4 430 -860 490 -860 {}
L 4 760 -240 760 -100 {}
L 4 760 -100 1170 -100 {}
L 4 840 -750 840 -510 {}
L 4 560 -790 560 -750 {}
L 4 560 -790 820 -790 {}
L 4 820 -790 820 -750 {}
L 4 840 -720 1100 -720 {}
L 4 1100 -670 1100 -530 {}
L 4 1100 -720 1100 -670 {}
L 4 540 -750 540 -510 {}
L 4 540 -510 840 -510 {}
L 4 540 -750 840 -750 {}
L 4 840 -530 1100 -530 {}
L 7 610 -170 660 -220 {}
L 7 610 -170 670 -140 {}
L 7 770 -240 770 -120 {}
L 7 760 -240 770 -240 {}
L 7 830 -240 830 -100 {}
L 7 830 -240 850 -240 {}
L 7 850 -240 850 -100 {}
L 7 880 -240 880 -100 {}
L 7 880 -240 900 -240 {}
L 7 900 -240 900 -100 {}
L 7 940 -240 940 -100 {}
L 7 940 -240 960 -240 {}
L 7 960 -240 960 -100 {}
L 7 980 -240 980 -100 {}
L 7 980 -240 1000 -240 {}
L 7 1000 -240 1000 -100 {}
L 7 1040 -240 1040 -100 {}
L 7 1040 -240 1060 -240 {}
L 7 1060 -240 1060 -100 {}
L 7 1090 -240 1090 -100 {}
L 7 1090 -240 1110 -240 {}
L 7 770 -100 830 -100 {}
L 7 850 -100 880 -100 {}
L 7 900 -100 940 -100 {}
L 7 960 -100 980 -100 {}
L 7 1000 -100 1030 -100 {}
L 7 1030 -100 1040 -100 {}
L 7 1060 -100 1090 -100 {}
L 7 770 -120 770 -100 {}
L 8 760 -200 1160 -200 {}
L 10 760 -100 840 -220 {}
L 10 840 -220 890 -100 {}
L 10 890 -100 950 -220 {}
L 10 950 -220 990 -100 {}
L 10 990 -100 1050 -220 {}
L 10 1050 -220 1100 -100 {}
L 12 760 -120 1160 -120 {}
A 7 615.2702702702703 -173.7837837837838 64.31708453466086 45.93640038566023 282.3772319264831 {}
A 7 665 -175 7.071067811865476 315 360 {}
A 7 695 -175 7.071067811865476 315 360 {}
A 7 725 -175 7.071067811865476 315 360 {}
A 7 615 -215 7.071067811865476 315 360 {}
T {01_dc_transfer_vos_sweep

02_op_and_prebuffer_ac_gain

03_input_common_mode_range

04_dc_cmrr_sweep

05_dc_psrr_sweep

06_output_logic_voh_vol

07_propagation_delay_overdrive

08_output_rise_fall_time

09_hysteresis_ramp_sweep

10_static_power_quiescent_current

11_dynamic_switching_energy

12_pvt_corner_analysis

13_monte_carlo_mismatch_process

14_post_layout_pex_verification

} 10 -530 0 0 0.25 0.25 {}
T {15_transistor_intrinsic_speed_ft_gmid

16_prebuffer_ac_bandwidth_slew_rate

17_max_toggle_freq_cl_sweep

18_input_referred_noise

19_transient_kickback_noise

20_ac_frequency_psrr_cmrr

21_overdrive_recovery_time

22_min_window_width_boundary_glitch

23_power_up_supply_ramp_startup

24_enable_disable_wakeup_leakage

25_bias_current_sensitivity_sweep

26_input_leakage_and_cin

27_combined_pvt_mc_worst_case_yield} 250 -530 0 0 0.25 0.25 {}
T {post_layout} 630 -780 0 0 0.4 0.4 {}
N 700 -570 700 -540 {lab=ibias
}
N 580 -650 600 -650 {lab=vh
}
N 600 -620 620 -620 {lab=vin
}
N 580 -590 600 -590 {lab=vl
}
N 680 -710 680 -680 {lab=vdd
}
N 700 -700 700 -670 {lab=en
}
N 780 -620 790 -620 {lab=vout
}
N 680 -560 680 -530 {lab=vss
}
C {code.sym} 10 -830 0 0 {name=1 name=01_DC_Transfer_Characteristic_(VTC_Thresholds) only_toplevel=false value="
Vin vin 0 dc \{vcm\}
.control
save all
dc Vin 0 1.2 1m
meas dc vth_l WHEN v(vout)=0.6 RISE=1
meas dc vth_h WHEN v(vout)=0.6 FALL=1
let win_w = vth_h - vth_l
print vth_l vth_h win_w
write @name\\\\.raw v(vin) v(vout)
plot v(vin) v(vout) v(vh) v(vl) title "01_dc_transfer_vos_sweep"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vin) v(vout) v(vh) v(vl) title "01_dc_transfer_vos_sweep"
.endc
"
}
C {code.sym} 220 -910 0 0 {name=params only_toplevel=false value="
.param vdd=1.2 vss=0 vcm=0.6 vrise=0.3
.param vh=\{vcm+vrise\} vl=\{vcm-vrise\}
.param ibias=1u en=1.2 cload=100f rload=1G
.param fin=10k vamp=0.6 tnom=27
.param ac_vdd=0 ac_vss=0
.temp \{tnom\}
.option method=gear
.option savecurrents
.option filetype=ascii
.option color0=white
.option color1=black
.option hcopydevtype=svg
Vdd vdd 0 dc \{vdd\} ac \{ac_vdd\}
Vvh vh 0 dc \{vh\}
Cload vout 0 \{cload\}
Rload vout vss \{rload\}
Vvl vl 0 dc \{vl\}
Ibias vdd ibias dc \{ibias\}
Vss vss 0 dc \{vss\} ac \{ac_vss\}
Ven en 0 dc \{en\}
"

}
C {code.sym} 70 -830 0 0 {name=2 only_toplevel=false value="
Vin vin 0 dc \{vl\} ac 1
.control
save all
op
ac dec 50 1 1G
let av_db = db(v(x1.wind_comp_0.comparator_1.sg13cmos5l_inv_16_0.a))
meas ac avdc_db FIND av_db AT=10
let av_3db = avdc_db - 3
meas ac f3db WHEN av_db=$&av_3db FALL=1
print avdc_db f3db
write @name\\\\.raw av_db
plot av_db title "02_op_and_prebuffer_ac_gain"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg av_db title "02_op_and_prebuffer_ac_gain"
.endc
"
}
C {code.sym} 130 -830 0 0 {name=3 only_toplevel=false value="
Vin vin 0 dc \{vcm\}
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
    echo $vv $vcm_val $&vth_l $&vth_h >> @name\\\\.txt
  end
end
write @name\\\\.raw v(vin) v(vout) v(vl) v(vh)
plot v(vin) v(vout) v(vl) v(vh) title "03_input_common_mode_range"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vin) v(vout) v(vl) v(vh) title "03_input_common_mode_range"
.endc
"
}
C {code.sym} 190 -830 0 0 {name=4 only_toplevel=false value="
Vin vin 0 dc \{vcm\}
.control
save all
alterparam vrise=0.05
alterparam vcm=0.35
reset
save all
dc Vin 0.25 0.35 100u
meas dc vt1 WHEN v(vout)=0.6 RISE=1
let vos1 = vt1 - 0.3
set vos1_val = $&vos1
alterparam vcm=0.85
reset
save all
dc Vin 0.75 0.85 100u
meas dc vt2 WHEN v(vout)=0.6 RISE=1
let vos1 = $vos1_val
let vos2 = vt2 - 0.8
let cmrr_db = 20 * log10(abs(0.5 / (vos2 - vos1 + 1e-15)))
print vos1 vos2 cmrr_db
write @name\\\\.raw v(vin) v(vout)
plot v(vin) v(vout) v(vl) title "04_dc_cmrr_sweep"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vin) v(vout) v(vl) title "04_dc_cmrr_sweep"
.endc

"
}
C {code.sym} 250 -830 0 0 {name=5 only_toplevel=false value="

Vin vin 0 dc \{vcm\}
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
let vout_min = \{$p_min\}.vout
print vt_min vt_max psrr_db
write @name\\\\.raw vout_min v(vout)
plot vout_min v(vout) title "05_dc_psrr_sweep"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg vout_min v(vout) title "05_dc_psrr_sweep"
.endc

"
}
C {code.sym} 310 -830 0 0 {name=6 only_toplevel=false value="
Vin vin 0 dc \{vcm\}
.control
save all
dc Vin 0 1.2 2m
meas dc voh MAX v(vout)
meas dc vol MIN v(vout)
print voh vol
write @name\\\\.raw v(vin) v(vout)
plot v(vin) v(vout) title "06_output_logic_voh_vol"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vin) v(vout) title "06_output_logic_voh_vol"
.endc

"
}
C {code.sym} 370 -830 0 0 {name=7 only_toplevel=false value="
Vin vin 0 pulse(0.29 0.31 2u 1n 1n 20u 40u)
.control
save all
tran 10n 50u
meas tran tplh TRIG v(vin) VAL=0.3 RISE=1 TARG v(vout) VAL=0.6 RISE=1
meas tran tphl TRIG v(vin) VAL=0.3 FALL=1 TARG v(vout) VAL=0.6 FALL=1
print tplh tphl
write @name\\\\.raw v(vin) v(vout)
plot v(vin) v(vout) title "07_propagation_delay_overdrive"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vin) v(vout) title "07_propagation_delay_overdrive"
.endc

"
}
C {code.sym} 430 -830 0 0 {name=8 only_toplevel=false value="

Vin vin 0 pulse(0.29 0.31 2u 1n 1n 5u 10u)
.control
save all
tran 500p 10u
meas tran trise TRIG v(vout) VAL=0.12 RISE=1 TARG v(vout) VAL=1.08 RISE=1
meas tran tfall TRIG v(vout) VAL=1.08 FALL=1 TARG v(vout) VAL=0.12 FALL=1
print trise tfall
write @name\\\\.raw v(vout)
plot v(vout) title "08_output_rise_fall_time"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vout) title "08_output_rise_fall_time"
.endc

"
}
C {code.sym} 10 -750 0 0 {name=9 only_toplevel=false value="

Vin vin 0 pwl(0 0.2 50u 0.4 100u 0.2)
.control
save all
tran 100n 100u
meas tran t_r WHEN v(vout)=0.6 RISE=1
meas tran t_f WHEN v(vout)=0.6 FALL=1
meas tran v_r FIND v(vin) AT=$&t_r
meas tran v_f FIND v(vin) AT=$&t_f
let vhys = v_r - v_f
print v_r v_f vhys
write @name\\\\.raw v(vin) v(vout)
plot v(vout) vs v(vin) title "09_hysteresis_ramp_sweep"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vout) vs v(vin) title "09_hysteresis_ramp_sweep"
.endc

"
}
C {code.sym} 70 -750 0 0 {name=10 only_toplevel=false value="

Vin vin 0 dc \{vcm\}
.control
save all
op
let iq_tot = -i(Vdd)
let pstat = iq_tot * v(vdd)
set p_op = $curplot
dc Vin 0 1.2 5m
let pstat_vin = -i(Vdd) * v(vdd)
print \{$p_op\}.iq_tot \{$p_op\}.pstat
write @name\\\\.raw v(vin) pstat_vin
plot pstat_vin title "10_static_power_quiescent_current"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg pstat_vin title "10_static_power_quiescent_current"
.endc
"
}
C {code.sym} 130 -750 0 0 {name=11 only_toplevel=false value="

Vin vin 0 pulse(0.25 0.35 1u 1n 1n 4u 8u)
.control
save all
tran 500p 10u
let pinst = -i(Vdd) * v(vdd)
meas tran esw_rise INTEG pinst FROM=950n TO=2.5u
meas tran esw_fall INTEG pinst FROM=4.95u TO=6.5u
print esw_rise esw_fall
write @name\\\\.raw pinst v(vout)
plot pinst v(vout) title "11_dynamic_switching_energy"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg pinst v(vout) title "11_dynamic_switching_energy"
.endc
"
}
C {code.sym} 190 -750 0 0 {name=12 only_toplevel=false value="
Vin vin 0 dc \{vcm\}
.control
save all
foreach vv 1.08 1.2 1.32
  foreach tt -40 27 125
    alterparam vdd=$vv
    alterparam tnom=$tt
    reset
    save all
    op
    let pstat = -i(Vdd) * v(vdd)
    set pstat_val = $&pstat
    dc Vin 0 $vv 2m
    let vmid = $vv / 2
    meas dc vth_l WHEN v(vout)=$&vmid RISE=1
    meas dc vth_h WHEN v(vout)=$&vmid FALL=1
    let vos_l = vth_l - 0.3
    let vos_h = vth_h - 0.9
    echo $vv $tt $&vos_l $&vos_h $pstat_val >> @name\\\\.txt
  end
end
write @name\\\\.raw v(vin) v(vout) v(vl) v(vh)
plot v(vin) v(vout) v(vl) v(vh) title "12_pvt_corner_analysis"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vin) v(vout) v(vl) v(vh) title "12_pvt_corner_analysis"
.endc

"
}
C {code.sym} 250 -750 0 0 {name=13 only_toplevel=false value="
Vin vin 0 dc \{vcm\}
.control
save all
let run = run + 1
let runs = 200
dowhile run <= runs
  reset
  save all
  dc Vin 0 1.2 1m
  meas dc vth_l WHEN v(vout)=0.6 RISE=1
  meas dc vth_h WHEN v(vout)=0.6 FALL=1
  let vos_l = vth_l - 0.3
  let vos_h = vth_h - 0.9
  echo $&run $&vos_l $&vos_h >> @name\\\\.txt
  let run = run + 1
end
write @name\\\\.raw v(vin) v(vout) v(vl) v(vh)
plot v(vin) v(vout) v(vl) v(vh) title "13_monte_carlo_mismatch_process"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vin) v(vout) v(vl) v(vh) title "13_monte_carlo_mismatch_process"
.endc

"
}
C {code.sym} 310 -750 0 0 {name=14 only_toplevel=false value="

Vin vin 0 pulse(0.29 0.31 1u 1n 1n 5u 10u)
.control
save all
tran 2n 10u
meas tran tplh_pex TRIG v(vin) VAL=0.3 RISE=1 TARG v(vout) VAL=0.6 RISE=1
meas tran tphl_pex TRIG v(vin) VAL=0.3 FALL=1 TARG v(vout) VAL=0.6 FALL=1
meas tran tr_pex TRIG v(vout) VAL=0.12 RISE=1 TARG v(vout) VAL=1.08 RISE=1
meas tran tf_pex TRIG v(vout) VAL=1.08 FALL=1 TARG v(vout) VAL=0.12 FALL=1
set p_tr = $curplot
set filetype=ascii
write @name\\\\.raw v(vin) v(vout)
plot v(vin) v(vout) title "14_post_layout_pex_verification"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vin) v(vout) title "14_post_layout_pex_verification"
dc Vin 0 1.2 2m
let pstat_vec = -i(Vdd) * v(vdd)
meas dc pstat_pex FIND pstat_vec AT=0.6
meas dc vth_l_pex WHEN v(vout)=0.6 RISE=1
meas dc vth_h_pex WHEN v(vout)=0.6 FALL=1
print pstat_pex vth_l_pex vth_h_pex \{$p_tr\}.tplh_pex \{$p_tr\}.tphl_pex \{$p_tr\}.tr_pex \{$p_tr\}.tf_pex
.endc

"
}
C {code.sym} 370 -750 0 0 {name=15 only_toplevel=false value="
Vin vin 0 dc \{vl\}
.control
save all @n.x1.x58.nsg13_lv_nmos[gm] @n.x1.x58.nsg13_lv_nmos[ids] @n.x1.x58.nsg13_lv_nmos[cgg] @n.x1.x58.nsg13_lv_nmos[vds] @n.x1.x58.nsg13_lv_nmos[vth] @n.x1.x58.nsg13_lv_nmos[gds]
op
let gm_m1 = @n.x1.x58.nsg13_lv_nmos[gm]
let id_m1 = @n.x1.x58.nsg13_lv_nmos[ids]
let cgg_m1 = @n.x1.x58.nsg13_lv_nmos[cgg]
let gds_m1 = @n.x1.x58.nsg13_lv_nmos[gds]
let gmid_m1 = gm_m1 / id_m1
let ft_m1 = gm_m1 / (2 * pi * cgg_m1)
let av0_m1 = gm_m1 / gds_m1
set p_op = $curplot
dc Vin 0.2 1.0 10m
let gm_sw = @n.x1.x58.nsg13_lv_nmos[gm]
let id_sw = @n.x1.x58.nsg13_lv_nmos[ids]
let cgg_sw = @n.x1.x58.nsg13_lv_nmos[cgg]
let gmid_sw = gm_sw / id_sw
let ft_sw = gm_sw / (2 * pi * cgg_sw)
print \{$p_op\}.gm_m1 \{$p_op\}.id_m1 \{$p_op\}.gmid_m1 \{$p_op\}.ft_m1 \{$p_op\}.av0_m1
set filetype=ascii
write 15.raw v(vin) ft_sw gmid_sw
plot ft_sw title "15_transistor_intrinsic_speed_ft_gmid"
set hcopydevtype=svg
hardcopy ../plots/15.svg ft_sw title "15_transistor_intrinsic_speed_ft_gmid"
.endc
"
}
C {code.sym} 430 -750 0 0 {name=16 only_toplevel=false value="

*Vin vin 0 dc \{vl\} ac 1 pulse(0.25 0.35 20n 100p 100p 100n 200n)
Vin vin 0 dc \{vl\} ac 1 pulse(0.25 0.35 1u 1n 1n 5u 10u)
.control
save all
ac dec 50 1 1G
*let av_db = db(v(xcomp1.x2.vop))
let av_db = db(v(x1.wind_comp_0.comparator_1.sg13cmos5l_inv_16_0.a))
meas ac ugbw WHEN av_db=0 FALL=1
set p_ac = $curplot
*tran 100p 200n
tran 1n 10u
*let sr_vec = deriv(v(xcomp1.x2.vop))
let sr_vec = deriv(v(x1.wind_comp_0.comparator_1.sg13cmos5l_inv_16_0.a))
*meas tran sr_pos MAX sr_vec FROM=15n TO=60n
meas tran sr_pos MAX sr_vec FROM=0.9u TO=4u
*meas tran sr_neg MIN sr_vec FROM=115n TO=160n
meas tran sr_neg MIN sr_vec FROM=5.9u TO=9u
print \{$p_ac\}.ugbw sr_pos sr_neg
*write @name\\\\.raw v(vin) v(xcomp1.x2.vop)
write @name\\\\.raw v(vin) v(x1.wind_comp_0.comparator_1.sg13cmos5l_inv_16_0.a)
*plot v(xcomp1.x2.vop) v(vin) title "16_prebuffer_ac_bandwidth_slew_rate"
plot v(x1.wind_comp_0.comparator_1.sg13cmos5l_inv_16_0.a) v(vin) title "16_prebuffer_ac_bandwidth_slew_rate"
set hcopydevtype=svg
*hardcopy ../plots/@name\\\\.svg v(xcomp1.x2.vop) v(vin) title "16_prebuffer_ac_bandwidth_slew_rate"
hardcopy ../plots/@name\\\\.svg v(x1.wind_comp_0.comparator_1.sg13cmos5l_inv_16_0.a) v(vin) title "16_prebuffer_ac_bandwidth_slew_rate"
.endc
"
}
C {code.sym} 10 -670 0 0 {name=17 only_toplevel=false value="
Vin vin 0 sin(\{vl\} 0.05 \{fin\})
.control
save all
foreach cl 50f 100f 500f 1p
*  foreach fr 100k 500k 1Meg 5Meg 10Meg
  foreach fr 100k 250k 500k 1Meg
    alterparam cload=$cl
    alterparam fin=$fr
    reset
    save all
    let tstop = 4 / $fr
    let tstep = tstop / 400
    tran $&tstep $&tstop
    meas tran vmax_o MAX v(vout)
    meas tran vmin_o MIN v(vout)
    let vpp_o = vmax_o - vmin_o
    echo $cl $fr $&vpp_o >> @name\\\\.txt
  end
end
write @name\\\\.raw v(vin) v(vout)
plot v(vin) v(vout) title "17_max_toggle_freq_cl_sweep"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vin) v(vout) title "17_max_toggle_freq_cl_sweep"
.endc

"
}
C {code.sym} 70 -670 0 0 {name=18 only_toplevel=false value="

Vin vin 0 dc \{vl\} ac 1
.control
save all
*noise v(xcomp1.x2.vop) Vin dec 50 1 100Meg
noise v(x1.wind_comp_0.comparator_1.sg13cmos5l_inv_16_0.a) Vin dec 50 1 100Meg
setplot noise2
print inoise_total onoise_total
setplot noise1
write @name\\\\.raw inoise_spectrum
plot inoise_spectrum title "18_input_referred_noise"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg inoise_spectrum title "18_input_referred_noise"
.endc
"
}
C {code.sym} 130 -670 0 0 {name=19 only_toplevel=false value="

Vin vin_src 0 pulse(0.25 0.35 1u 1n 1n 5u 10u)
Rsrc vin_src vin 10k
.control
save all
tran 1n 10u
let vkick = v(vin) - v(vin_src)
meas tran vkick_pos MAX vkick FROM=0.9u TO=4u
meas tran vkick_neg MIN vkick FROM=5.9u TO=9u
print vkick_pos vkick_neg
write @name\\\\.raw vkick v(vout)
plot vkick v(vout) title "19_transient_kickback_noise"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg vkick v(vout) title "19_transient_kickback_noise"
.endc
"
}
C {code.sym} 190 -670 0 0 {name=20 only_toplevel=false value="
Vin vin 0 dc \{vl\} ac 1
.control
save all
ac dec 50 1 100Meg
let adm = mag(v(x1.wind_comp_0.comparator_1.sg13cmos5l_inv_16_0.a))
set p_dm = $curplot
alter @vin[acmag] = 0
alter @vvl[acmag] = 0
alter @vdd[acmag] = 1
ac dec 50 1 100Meg
let avdd = mag(v(x1.wind_comp_0.comparator_1.sg13cmos5l_inv_16_0.a))
let psrr_f = 20 * log10(\{$p_dm\}.adm / avdd)
set p_dd = $curplot
alter @vdd[acmag] = 0
alter @vin[acmag] = 1
alter @vvl[acmag] = 1
ac dec 50 1 100Meg
let acm = mag(v(x1.wind_comp_0.comparator_1.sg13cmos5l_inv_16_0.a))
let cmrr_f = 20 * log10(\{$p_dm\}.adm / acm)
let psrr_db = \{$p_dd\}.psrr_f
meas ac psrr_1k FIND psrr_db AT=1k
meas ac psrr_1m FIND psrr_db AT=1Meg
meas ac cmrr_1k FIND cmrr_f AT=1k
meas ac cmrr_1m FIND cmrr_f AT=1Meg
print psrr_1k psrr_1m cmrr_1k cmrr_1m
write @name\\\\.raw psrr_db cmrr_f
plot psrr_db cmrr_f title "20_ac_frequency_psrr_cmrr"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg psrr_db cmrr_f title "20_ac_frequency_psrr_cmrr"
.endc
"
}
C {code.sym} 250 -670 0 0 {name=21 only_toplevel=false value="
Vin vin 0 pulse(0 0.31 1u 1n 1n 8u 16u)
.control
save all
tran 2n 10u
meas tran trec_l TRIG v(vin) VAL=0.3 RISE=1 TARG v(vout) VAL=0.6 RISE=1
print trec_l
write @name\\\\.raw v(vin) v(vout)
plot v(vin) v(vout) title "21_overdrive_recovery_time"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vin) v(vout) title "21_overdrive_recovery_time"
.endc
"
}
C {code.sym} 310 -670 0 0 {name=22 only_toplevel=false value="

Vin vin 0 pwl(0 0.4 50u 0.8)
.control
save all
foreach vr 50m 25m 10m 5m
  alterparam vrise=$vr
  reset
  save all
  tran 50n 50u
  meas tran vout_pk MAX v(vout)
  meas tran pw TRIG v(vout) VAL=0.6 RISE=1 TARG v(vout) VAL=0.6 FALL=1
  echo $vr $&vout_pk $&pw >> @name\\\\.txt
end
write @name\\\\.raw v(vin) v(vout) v(vl) v(vh)
plot v(vin) v(vout) v(vl) v(vh) title "22_min_window_width_boundary_glitch"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vin) v(vout) v(vl) v(vh) title "22_min_window_width_boundary_glitch"
.endc
"
}
C {code.sym} 370 -670 0 0 {name=23 only_toplevel=false value="

Vin vin 0 dc \{vcm\}
.control
save all
alter @vdd[pulse] = [ 0 1.2 1u 1n 1n 5u 10u ]
alter @ven[pulse] = [ 0 1.2 1u 1n 1n 5u 10u ]
tran 2n 10u
meas tran t_startup TRIG v(vdd) VAL=0.6 RISE=1 TARG v(vout) VAL=1.08 RISE=1
print t_startup
write @name\\\\.raw v(vdd) v(vout)
plot v(vdd) v(vout) title "23_power_up_supply_ramp_startup"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vdd) v(vout) title "23_power_up_supply_ramp_startup"
.endc
"
}
C {code.sym} 430 -670 0 0 {name=24 only_toplevel=false value="
Vin vin 0 dc \{vcm\}
.control
save all
option reltol=1e-3 abstol=1e-11 chgtol=1e-13
alter @ven[pulse] = [ 0 1.2 1u 20n 20n 5u 10u ]
tran 5n 10u
let idd = -i(Vdd)
meas tran istby FIND idd AT=800n
meas tran twake TRIG v(en) VAL=0.6 RISE=1 TARG v(vout) VAL=0.6 RISE=1
meas tran tdis TRIG v(en) VAL=0.6 FALL=1 TARG v(vout) VAL=0.6 FALL=1
print istby twake tdis
set filetype=ascii
write 24.raw v(en) v(vout) idd
plot v(en) v(vout) title "24_enable_disable_wakeup_leakage"
set hcopydevtype=svg
hardcopy ../plots/24.svg v(en) v(vout) title "24_enable_disable_wakeup_leakage"
.endc
"
}
C {code.sym} 10 -590 0 0 {name=25 only_toplevel=false value="

Vin vin 0 pulse(0.29 0.31 1u 1n 1n 4u 8u)
.control
save all
foreach ib 0.5u 1u 2u 5u
  alterparam ibias=$ib
  reset
  save all
  op
  let pstat = -i(Vdd) * v(vdd)
  set pstat_val = $&pstat
  tran 5n 10u
  meas tran tplh TRIG v(vin) VAL=0.3 RISE=1 TARG v(vout) VAL=0.6 RISE=1
  meas tran tphl TRIG v(vin) VAL=0.3 FALL=1 TARG v(vout) VAL=0.6 FALL=1
  echo $ib $pstat_val $&tplh $&tphl >> @name\\\\.txt
end
write @name\\\\.raw v(vin) v(vout)
plot v(vin) v(vout) title "25_bias_current_sensitivity_sweep"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg v(vin) v(vout) title "25_bias_current_sensitivity_sweep"
.endc
"
}
C {code.sym} 70 -590 0 0 {name=26 only_toplevel=false value="

Vin vin 0 dc \{vcm\} ac 1
.control
save all
op
let ileak = abs(i(Vin))
set p_op = $curplot
ac dec 20 1k 10Meg
let cin = -imag(i(Vin)) / (2 * pi * frequency)
meas ac cin_1meg FIND cin AT=1Meg
print \{$p_op\}.ileak cin_1meg
write @name\\\\.raw cin
plot cin title "26_input_leakage_and_cin"
set hcopydevtype=svg
hardcopy ../plots/@name\\\\.svg cin title "26_input_leakage_and_cin"
.endc
"
}
C {code.sym} 130 -590 0 0 {name=27 only_toplevel=false value="
Vin vin 0 dc \{vcm\}
.control
save all
alterparam vdd=1.08
alterparam tnom=125
set run = 1
set runs = 200
dowhile $run <=$runs
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
"
}
C {devices/title.sym} 160 -30 0 0 {name=l1 author="Copyright 2025 IHP PDK Authors"}
C {devices/launcher.sym} 920 -360 0 0 {name=h3
descr="OP annotate" 
tclcommand="xschem annotate_op"
}
C {launcher.sym} 620 -360 0 0 {name=h5
descr=SimulateNGSPICE
tclcommand="
# Setup the default simulation commands if not already set up
# for example by already launched simulations.
save_params
set_sim_defaults
puts $sim(spice,1,cmd) 

# Change the Xyce command. In the spice category there are currently
# 5 commands (0, 1, 2, 3, 4). Command 3 is the Xyce batch
# you can get the number by querying $sim(spice,n)
set sim(spice,1,cmd) \{ngspice  \\"$N\\" -a\}

# change the simulator to be used (Xyce)
set sim(spice,default) 0

# Create FET .save file
exec mkdir -p $netlist_dir
write_data [save_params] $netlist_dir/[file rootname [file tail [xschem get current_name]]].save

# run netlist and simulation
xschem netlist
simulate
"}
C {launcher.sym} 920 -315 0 0 {name=h6
descr=SimulatePARALLEL
tclcommand="
# Setup the default simulation commands if not already set up
# for example by already launched simulations.
set_sim_defaults
puts $sim(spice,1,cmd) 

# Change the Xyce command. In the spice category there are currently
# 5 commands (0, 1, 2, 3, 4). Command 3 is the Xyce batch
# you can get the number by querying $sim(spice,n)
set sim(spice,1,cmd) \{ngspice  \\"$N\\" -a\}

# change the simulator to be used (Xyce)
set sim(spice,default) 0

# Create FET and BIP .save file
exec mkdir -p $netlist_dir
write_data [save_params] $netlist_dir/[file rootname [file tail [xschem get current_name]]].save

# run netlist and simulation
xschem netlist
exec python3 $\{PDK_ROOT\}/$\{PDK\}/libs.tech/xschem/sg13g2_tests/ngspice_parallel_mc.py [file tail [xschem get current_name]]
"
spice_ignore=true}
C {simulator_commands.sym} 840 -660 0 0 {
name=Libs_Ngspice_pre_layout
simulator=ngspice
only_toplevel=false
value="
.lib cornerMOSlv.lib mos_tt
.lib cornerMOShv.lib mos_tt
.lib cornerMOSCAP.lib moscap_tt
.lib cornerCAP.lib cap_typ
.lib cornerRES.lib res_typ
.lib cornerDIO.lib dio_tt
"
      }
C {lab_wire.sym} 680 -710 0 0 {name=p1 lab=vdd
}
C {lab_wire.sym} 580 -650 0 0 {name=p2 lab=vh
}
C {lab_wire.sym} 790 -620 0 1 {name=p3 lab=vout
}
C {lab_wire.sym} 600 -620 0 0 {name=p4 lab=vin
}
C {lab_wire.sym} 580 -590 0 0 {name=p5 lab=vl
}
C {lab_wire.sym} 700 -540 0 1 {name=p6 lab=ibias
}
C {lab_wire.sym} 700 -700 0 1 {name=p8 lab=en
}
C {devices/code.sym} 950 -590 0 0 {name=MODEL_post_layout
only_toplevel=false
schname="tcleval([file rootname [file tail [xschem get schname]]])"
format="tcleval( @value )"
value="
.include $::PDK_ROOT/ihp-sg13g2/libs.ref/sg13g2_stdcell/spice/sg13g2_stdcell.spice
.include ../../../pex/slot_4.pex.spice
.include @schname\\\\.save
.control
op
write @schname\\\\.raw
.endc
"

place=header
}
C {simulator_commands.sym} 1120 -660 0 0 {name=Libs_Ngspice_post_layout
simulator=ngspice
only_toplevel=false
value="
.lib cornerMOSlv.lib mos_tt_mismatch
.lib cornerMOShv.lib mos_tt_mismatch
.lib cornerMOSCAP.lib moscap_tt
.lib cornerCAP.lib cap_typ
.lib cornerRES.lib res_typ
.lib cornerDIO.lib dio_tt
"
      }
C {wind_comp/slot_4.sym} 680 -620 0 0 {name=X1
}
C {lab_wire.sym} 680 -530 0 0 {name=p7 lab=vss
}
