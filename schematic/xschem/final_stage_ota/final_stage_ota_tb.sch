v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {SPICE SIMULATION} -1200 -650 0 0 0.4 0.4 {}
N 70 50 70 80 {lab=ibias}
N 50 60 50 90 {lab=vss}
N -70 30 -30 30 {lab=vn}
N -70 -30 -30 -30 {lab=vp}
N 20 -200 50 -200 {lab=vout}
N -60 -200 -20 -200 {lab=vn}
N 50 -90 50 -60 {lab=vdd}
N 150 0 190 0 {lab=vout}
N -120 220 -120 300 {lab=vss}
N -80 220 -50 220 {lab=ibias}
N -120 170 -120 190 {lab=ibias}
N -50 170 -50 220 {lab=ibias}
N -120 170 -50 170 {lab=ibias}
N -120 140 -120 170 {lab=ibias}
C {code_shown.sym} -1210 -310 0 0 {name=NETLIST only_toplevel=false value="
VSS VSS 0 0
VDD VDD VSS 1.2
VEN EN VSS 0
Vcm Vcm VSS \{vcm\}
Ibias VDD Ibias 1u
"}
C {code_shown.sym} -770 410 0 0 {name=OP_SIM only_toplevel=false
schname="tcleval([file rootname [file tail [xschem get schname]]])"
format="tcleval( @value )" value="
.control
op
let ro_n = voutn/i(vmeas2)
let ro_p = voutp/i(vmeas3)
print ro_n ro_p
write @schname\\\\.raw
.endc
"
}
C {simulator_commands_shown.sym} -1210 -480 0 0 {
name=Libs_Ngspice
simulator=ngspice
only_toplevel=false
value="
.lib cornerMOSlv.lib mos_ff
.lib cornerMOShv.lib mos_tt
.lib cornerMOSCAP.lib moscap_tt
.lib cornerCAP.lib cap_typ
.lib cornerRES.lib res_typ
.lib cornerDIO.lib dio_tt
"
      }
C {devices/launcher.sym} -1580 400 0 0 {name=h2
descr="OP annotate" 
tclcommand="xschem annotate_op"
}
C {code_shown.sym} -950 -330 0 0 {name=AC_SIM only_toplevel=false value="
vp vp 0 \{vcm\}
.control
ac dec 50 100 100G
let op_mag=db(vout)
let op_ph = 180*cph(vout)/pi + 180

echo results_save_begin
meas ac dc_gain find op_mag when frequency=1000
meas ac gain_margin find op_mag when op_ph=0
meas ac phase_margin find op_ph when op_mag=0
meas ac bw_3db find frequency when op_mag=dc_gain-3
meas ac Gain_BW find frequency when op_mag=0
echo results_save_end
plot op_mag op_ph
.endc
"
}
C {code_shown.sym} -850 -590 0 0 {name=PARAMS only_toplevel=false value="
.option rshunt=1e9
.param vcm=0.75 vcm_in=0.6 cl=0.1p
.save all
"}
C {code_shown.sym} -820 -450 0 0 {name=LOAD only_toplevel=false value="
CL1 Voutp 0 \{cl\}
CL2 Voutn 0 \{cl\}
"
}
C {devices/code_shown.sym} -1200 -580 0 0 {name=SAVE only_toplevel=true
schname="tcleval([file rootname [file tail [xschem get schname]]])"
format="tcleval( @value )"
value="
.include @schname\\\\.save
"}
C {code_shown.sym} -790 150 0 0 {name=TRAN_SIM only_toplevel=false value="
Vinp Vinp 0 sin(\{vcm_in\} 100u 1k)
Vinn Vinn 0 sin(\{vcm_in\} -100u 1k)
.control
tran 100u 100m
plot Vinp Vinn Voutp Voutn
plot Vinp-Vinn Voutp-Voutn
.endc
"
spice_ignore=true}
C {launcher.sym} -1580 320 0 0 {name=h4
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
C {code_shown.sym} -1460 70 0 0 {name=AC_LOOP only_toplevel=false value="
.control
set gain_pcmd = \\"\\"
set ph_pcmd = \\"\\"
set ph_mrg = \\"\\"
set vcm_param = vcm_in
set curplot = new
compose vcm_vec start=0 stop=1.5 step=0.1
foreach vcm_val $&vcm_vec
	reset
	alterparam $vcm_param =$vcm_val
	ac dec 50 100 100G
	let cur_vcm=$vcm_val
	let vout_diff = voutp-voutn
	let vin_diff = vinp-vinn
	let diff_gain=vout_diff/vin_diff
	let op_mag=db(diff_gain)
	let op_ph = 180*cph(-diff_gain)/pi
        set gain_pcmd = \\" $gain_pcmd \{$curplot\}.op_mag \\"
	set ph_pcmd = \\" $ph_pcmd \{$curplot\}.op_ph \\"
	meas ac phase_margin find op_ph when op_mag=0
	if $&phase_margin
		set ph_mrg = \\" $ph_mrg \{$curplot\}.phase_margin \\"
	end
	set ph_mrg = \\" $ph_mrg  \{$curplot\}.cur_vcm \\"
end
//set nolegend
plot $gain_pcmd
plot $ph_pcmd
print $ph_mrg
.endc
"
spice_ignore=true}
C {code_shown.sym} -1630 -340 0 0 {name=DC_LOOP_SIM only_toplevel=false value="
Vt_p Vt_p 0 0
Vt_n Vt_n 0 0
.control
set curplot = new
set plt_voutp = \\"\\"
set plt_voutn = \\"\\"
set plt_vt_p = \\"\\"
set plt_vdiff = \\"\\"
set plt_voutpn = \\"\\"
compose vcm_vec start=0 stop=1.5 step=0.1
foreach vcm_val $&vcm_vec
	alterparam vcm = $vcm_val
	reset
	dc Vt_p 0 1.5 0.01
	let Vout = v(Voutp) - v(Voutn)
	set plt_voutp = \\" \{$plt_voutp\} \{$curplot\}.voutp \\"
	set plt_voutn = \\" \{$plt_voutn\} \{$curplot\}.voutn \\"
	set plt_vdiff = \\" \{$plt_vdiff\} \{$curplot\}.vout \\"
	set plt_voutpn = \\" \{$plt_voutpn\} \{$curplot\}.voutp \{$curplot\}.voutn \\"
end
plot $plt_voutpn
plot $plt_vdiff
.endc
"
spice_ignore=true}
C {code_shown.sym} -1630 -630 0 0 {name=DC_SIM only_toplevel=false value="
Vp Vp 0 0
Vn Vn 0 0.6

.control
dc Vp 0 1.2 0.01 

plot vop vom


.endc
"
spice_ignore=true}
C {lab_pin.sym} 50 -90 0 1 {name=p1 lab=vdd}
C {lab_pin.sym} -70 30 0 0 {name=p3 lab=vn}
C {lab_pin.sym} -70 -30 0 0 {name=p4 lab=vp}
C {lab_pin.sym} -120 140 0 1 {name=p5 lab=ibias}
C {lab_pin.sym} 50 90 0 1 {name=p6 lab=vss}
C {ac_probe/ac_probe.sym} 0 -220 0 0 {name=xprobe1 vcm=\{vcm\} vac=1
}
C {lab_pin.sym} -60 -200 0 0 {name=p8 lab=vn}
C {lab_pin.sym} 190 0 0 1 {name=p9 lab=vout}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 300 -110 0 0 {name=x3 VDD=VDD VSS=VSS prefix=sg13g2_ spice_ignore=true}
C {devices/code_shown.sym} -1230 -740 0 0 {name=MODEL
only_toplevel=true
format="tcleval( @value )"
value="
.include $::PDK_ROOT/ihp-sg13g2/libs.ref/sg13g2_stdcell/spice/sg13g2_stdcell.spice

"
place=header}
C {final_stage_ota/final_stage_ota.sym} 340 0 0 0 {name=x1}
C {lab_pin.sym} 50 -200 0 1 {name=p2 lab=vout}
C {lab_pin.sym} 70 80 0 1 {name=p10 lab=ibias}
C {sg13g2_pr/sg13_lv_nmos.sym} -100 220 0 1 {name=M12
l=5u
w=2u
ng=1
m=1
annot_side=2
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} -120 300 2 0 {name=p11 lab=vss}
