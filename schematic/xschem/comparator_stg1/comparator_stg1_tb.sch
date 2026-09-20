v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {SPICE SIMULATION} -1070 -650 0 0 0.4 0.4 {}
N 200 50 200 80 {lab=ibias}
N 180 60 180 90 {lab=vss}
N 280 -10 320 -10 {lab=vop}
N 60 30 100 30 {lab=vn}
N 60 -30 100 -30 {lab=vp}
N 150 -200 180 -200 {lab=vop}
N 70 -200 110 -200 {lab=vn}
N 180 -90 180 -60 {lab=vdd}
N 280 10 320 10 {lab=vom}
N 490 -20 540 -20 {lab=vop}
N 490 40 540 40 {lab=vom}
N 620 -90 620 -50 {lab=vdd}
N 640 60 640 100 {lab=ibias}
N 620 70 620 110 {lab=vss}
N 720 10 810 10 {lab=#net1}
N 890 10 930 10 {lab=vout}
C {code_shown.sym} -1080 -310 0 0 {name=NETLIST only_toplevel=false value="
VSS VSS 0 0
VDD VDD VSS 1.2
VEN EN VSS 0
Vcm Vcm VSS \{vcm\}
Ibias VDD Ibias 1u
"}
C {code_shown.sym} -640 410 0 0 {name=OP_SIM only_toplevel=false
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
C {simulator_commands_shown.sym} -1080 -480 0 0 {
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
C {devices/launcher.sym} -1450 400 0 0 {name=h2
descr="OP annotate" 
tclcommand="xschem annotate_op"
}
C {code_shown.sym} -820 -330 0 0 {name=AC_SIM only_toplevel=false value="
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
spice_ignore=true}
C {code_shown.sym} -720 -590 0 0 {name=PARAMS only_toplevel=false value="
.option rshunt=1e9
.param vcm=0.75 vcm_in=0.75 cl=0.1p
.save all
"}
C {code_shown.sym} -690 -450 0 0 {name=LOAD only_toplevel=false value="
CL1 Voutp 0 \{cl\}
CL2 Voutn 0 \{cl\}
"
}
C {devices/code_shown.sym} -1070 -580 0 0 {name=SAVE only_toplevel=true
schname="tcleval([file rootname [file tail [xschem get schname]]])"
format="tcleval( @value )"
value="
.include @schname\\\\.save
"}
C {code_shown.sym} -660 150 0 0 {name=TRAN_SIM only_toplevel=false value="
Vinp Vinp 0 sin(\{vcm_in\} 100u 1k)
Vinn Vinn 0 sin(\{vcm_in\} -100u 1k)
.control
tran 100u 100m
plot Vinp Vinn Voutp Voutn
plot Vinp-Vinn Voutp-Voutn
.endc
"
spice_ignore=true}
C {launcher.sym} -1450 320 0 0 {name=h4
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
C {code_shown.sym} -1330 70 0 0 {name=AC_LOOP only_toplevel=false value="
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
C {code_shown.sym} -1500 -340 0 0 {name=DC_LOOP_SIM only_toplevel=false value="
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
C {code_shown.sym} -1500 -630 0 0 {name=DC_SIM only_toplevel=false value="
Vp Vp 0 0
Vn Vn 0 0.6

.control
dc Vp 0 1.2 0.01 vn 0 1.2 0.1

plot vout


.endc
"
}
C {/foss/designs/ic_design/chipaloza/schema/comparator/comparator.sym} 180 0 0 0 {name=x1}
C {lab_pin.sym} 180 -90 0 1 {name=p1 lab=vdd}
C {lab_pin.sym} 320 -10 0 1 {name=p2 lab=vop}
C {lab_pin.sym} 60 30 0 0 {name=p3 lab=vn}
C {lab_pin.sym} 60 -30 0 0 {name=p4 lab=vp}
C {lab_pin.sym} 200 80 0 1 {name=p5 lab=ibias}
C {lab_pin.sym} 180 90 0 1 {name=p6 lab=vss}
C {/foss/designs/ic_design/chipaloza/schema/ac_probe/ac_probe.sym} 130 -220 0 0 {name=xprobe1 vcm=\{vcm\} vac=1
spice_ignore=true}
C {lab_pin.sym} 180 -200 0 1 {name=p7 lab=vop}
C {lab_pin.sym} 70 -200 0 0 {name=p8 lab=vn}
C {lab_pin.sym} 320 10 0 1 {name=p9 lab=vom}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 850 10 0 0 {name=x3 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {devices/code_shown.sym} -1100 -740 0 0 {name=MODEL
only_toplevel=true
format="tcleval( @value )"
value="
.include $::PDK_ROOT/ihp-sg13g2/libs.ref/sg13g2_stdcell/spice/sg13g2_stdcell.spice

"
place=header}
C {/foss/designs/ic_design/chipaloza/schema/final_stage_ota/final_stage_ota.sym} 910 10 0 0 {name=x2}
C {lab_pin.sym} 620 -90 0 0 {name=p10 lab=vdd}
C {lab_pin.sym} 490 -20 0 0 {name=p12 lab=vop}
C {lab_pin.sym} 490 40 0 0 {name=p13 lab=vom}
C {lab_pin.sym} 930 10 0 1 {name=p14 lab=vout}
C {lab_pin.sym} 620 110 0 0 {name=p15 lab=vss}
C {lab_pin.sym} 640 100 0 1 {name=p11 lab=ibias}
