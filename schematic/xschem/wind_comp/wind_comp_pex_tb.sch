v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {MONTE CARLO PYTHON} 640 -370 0 0 0.4 0.4 {}
T {SPICE SIMULATION} -1410 -450 0 0 0.4 0.4 {}
N 60 180 110 180 {lab=vdd}
N 60 40 110 40 {lab=vl}
N 60 60 110 60 {lab=vout}
N 60 140 110 140 {lab=vin}
N 60 80 110 80 {lab=vh}
N 60 100 110 100 {lab=ibias}
N 60 160 110 160 {lab=vss}
N 60 120 110 120 {lab=en}
C {devices/launcher.sym} 90 370 0 0 {name=h2
descr="OP annotate" 
tclcommand="xschem annotate_op"
}
C {launcher.sym} 90 290 0 0 {name=h4
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
C {devices/code_shown.sym} -740 -260 0 0 {name=MODEL
only_toplevel=true
format="tcleval( @value )"
value="
.include $::PDK_ROOT/ihp-sg13g2/libs.ref/sg13g2_stdcell/spice/sg13g2_stdcell.spice
.include ../../../pex/slot_4.pex.spice
"
place=header}
C {code_shown.sym} 640 -300 0 0 {name=MC_SETTINGS
only_toplevel=false
value="
**nr_workers=1
**nr_mc_sims=100

**results_plot_begin
**fall_error
**results_plot_end
"
}
C {launcher.sym} 710 -25 0 0 {name=h1
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
C {simulator_commands_shown.sym} 930 -330 0 0 {
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
C {lab_pin.sym} 60 180 2 1 {name=p1 lab=vdd}
C {lab_pin.sym} 60 80 2 1 {name=p2 lab=vh}
C {lab_pin.sym} 60 60 2 1 {name=p3 lab=vout}
C {lab_pin.sym} 60 140 2 1 {name=p4 lab=vin}
C {lab_pin.sym} 60 40 2 1 {name=p5 lab=vl}
C {lab_pin.sym} 60 100 2 1 {name=p6 lab=ibias}
C {lab_pin.sym} 60 160 2 1 {name=p7 lab=vss}
C {lab_pin.sym} 60 120 2 1 {name=p8 lab=en}
C {wind_comp/slot_4.sym} 130 30 0 0 {name=X1}
C {code_shown.sym} -1310 -340 0 0 {name=NETLIST1 only_toplevel=false value="
VSS VSS 0 0
VDD VDD 0 1.2
Vcm Vcm 0 \{vcm\}
Ibias VDD Ibias 1u
"}
C {code_shown.sym} -1560 -340 0 0 {name=OP_SIM1 only_toplevel=false
schname="tcleval([file rootname [file tail [xschem get schname]]])"
format="tcleval( @value )" value="
.control
op
write @schname\\\\.raw
.endc
"
}
C {simulator_commands_shown.sym} -1080 -340 0 0 {
name=Libs_Ngspice2
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
C {code_shown.sym} -1560 -190 0 0 {name=PARAMS1 only_toplevel=false value="
.option rshunt=1e9
.option method=gear
.param vcm=0.7 cl=0.1p
.save all
"}
C {code_shown.sym} -1290 -160 0 0 {name=LOAD1 only_toplevel=false value="
CL1 Vout 0 \{cl\}
"
}
C {devices/code_shown.sym} -750 -360 0 0 {name=SAVE1 only_toplevel=true
schname="tcleval([file rootname [file tail [xschem get schname]]])"
format="tcleval( @value )"
value="
.include @schname\\\\.save
"}
C {code_shown.sym} -700 110 0 0 {name=TRAN_SIM1 only_toplevel=false value="
Vh vh vss \{vcm+0.3\}
Vl vl vss \{vcm-0.3\}
vin vin vss sin(\{vcm\} 0.4 1000)
ven en vss 1.2
.control
tran 100n 1m
*plot vout vh vl vin vout1 
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
