v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {SPICE SIMULATION} -420 -300 0 0 0.4 0.4 {}
T {MONTE CARLO PYTHON} 790 -420 0 0 0.4 0.4 {}
C {code_shown.sym} -390 -190 0 0 {name=NETLIST only_toplevel=false value="
VSS VSS 0 0
VDD VDD 0 1.2
Vcm Vcm 0 \{vcm\}
Ibias VDD Ibias 1u
"}
C {code_shown.sym} -70 -20 0 0 {name=OP_SIM only_toplevel=false
schname="tcleval([file rootname [file tail [xschem get schname]]])"
format="tcleval( @value )" value="
.control
op
write @schname\\\\.raw
.endc
"
}
C {simulator_commands_shown.sym} -790 -470 0 0 {
name=Libs_Ngspice
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
C {devices/launcher.sym} -40 580 0 0 {name=h2
descr="OP annotate" 
tclcommand="xschem annotate_op"
}
C {code_shown.sym} -200 -190 0 0 {name=PARAMS only_toplevel=false value="
.option rshunt=1e9
.option method=gear
.param vcm=0.7 cl=0.1p
.save all
"}
C {code_shown.sym} 20 -200 0 0 {name=LOAD only_toplevel=false value="
CL1 Vout 0 \{cl\}
"
}
C {devices/code_shown.sym} -460 -490 0 0 {name=SAVE only_toplevel=true
schname="tcleval([file rootname [file tail [xschem get schname]]])"
format="tcleval( @value )"
value="
.include @schname\\\\.save
"}
C {code_shown.sym} -630 0 0 0 {name=TRAN_SIM only_toplevel=false value="
Vh vh vss \{vcm+0.3\}
Vl vl vss \{vcm-0.3\}
vin vin n0 \{vcm\}
vin1 n0 n1 pulse(0 0.305 100u 1n 1n 1u 500u)
vin2 n1 vss pulse(0 -0.305 300u 1n 1n 1u 500u)
.control
tran 100n 1m
plot vout vh vl vin
meas tran fall_time find time when vin=vh fall=1
meas tran delay find time when vout=\{vcm\} fall=1
let fall_error = delay-fall_time
echo results_save_begin
print fall_error
echo results_save_end
.endc
"
spice_ignore=true}
C {launcher.sym} -40 500 0 0 {name=h4
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
C {devices/code_shown.sym} -450 -390 0 0 {name=MODEL
only_toplevel=true
format="tcleval( @value )"
value="
.include $::PDK_ROOT/ihp-sg13g2/libs.ref/sg13g2_stdcell/spice/sg13g2_stdcell.spice

"
place=header}
C {code_shown.sym} 790 -350 0 0 {name=MC_SETTINGS
only_toplevel=false
value="
**nr_workers=1
**nr_mc_sims=100

**results_plot_begin
**fall_error
**results_plot_end
"
}
C {launcher.sym} 860 -75 0 0 {name=h1
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
C {simulator_commands_shown.sym} 1080 -380 0 0 {
name=Libs_Ngspice1
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
      spice_ignore=true}
C {lab_pin.sym} 1610 420 2 1 {name=p1 lab=vdd}
C {lab_pin.sym} 1610 280 2 1 {name=p2 lab=vh}
C {lab_pin.sym} 1610 300 2 1 {name=p3 lab=vout}
C {lab_pin.sym} 1610 -560 2 1 {name=p4 lab=vin}
C {lab_pin.sym} 1610 380 2 1 {name=p5 lab=vl}
C {lab_pin.sym} 1610 220 2 1 {name=p6 lab=ibias}
C {lab_pin.sym} 1610 400 2 1 {name=p7 lab=vss}
C {code_shown.sym} -1580 -10 0 0 {name=AC_SIM only_toplevel=false value="
.control
ac dec 50 100 100G
let op_mag=db(vout)
let op_ph = 180*cph(vout)/pi
plot op_mag op_ph
.endc
"
spice_ignore=true}
C {code_shown.sym} -780 390 0 0 {name=TRAN_SIM1 only_toplevel=false value="
Vh vh vss \{vcm+0.3\}
Vl vl vss \{vcm-0.3\}
vin vin vss sin(\{vcm\} 0.35 1000)
.control
tran 100n 1m
plot vout vh vl vin
meas tran fall_time find time when vin=vh fall=1
meas tran delay find time when vout=\{vcm\} fall=1
let fall_error = delay-fall_time
echo results_save_begin
print fall_error
echo results_save_end
.endc
"
spice_ignore=true}
C {code_shown.sym} -1130 0 0 0 {name=TRAN_SIM2 only_toplevel=false value="
Vh vh vss \{vcm+0.3\}
Vl vl vss \{vcm-0.3\}
vin vin vss sin(\{vcm\} 0.4 1000)
ven en vss 1.2
.control
tran 100n 1m
plot vout vh vl vin
meas tran fall_time find time when vin=vh fall=1
meas tran delay find time when vout=\{vcm\} fall=1
let fall_error = delay-fall_time
echo results_save_begin
print fall_error
echo results_save_end
.endc
"
}
C {lab_pin.sym} 1610 320 2 1 {name=p8 lab=en}
C {/foss/designs/ic_design/chipaloza/sg13cmos5l_Wind_Comp/pex/slot4_wrapper.sym} 1630 -570 0 0 {name=X2}
