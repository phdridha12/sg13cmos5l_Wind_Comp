v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {SPICE SIMULATION} -1770 -930 0 0 0.4 0.4 {}
T {MONTE CARLO PYTHON} 140 -770 0 0 0.4 0.4 {}
N -60 50 -60 80 {lab=ibias}
N -80 60 -80 90 {lab=vss}
N 20 0 150 0 {lab=vout}
N -220 -30 -160 -30 {lab=vh}
N -200 0 -140 0 {lab=vin}
N -220 30 -160 30 {lab=vl}
N -80 -130 -80 -60 {lab=vdd}
N -60 -90 -60 -50 {lab=en}
C {code_shown.sym} -1670 -820 0 0 {name=NETLIST only_toplevel=false value="
VSS VSS 0 0
VDD VDD 0 1.2
Vcm Vcm 0 \{vcm\}
Ibias VDD Ibias 1u
"}
C {code_shown.sym} -1920 -820 0 0 {name=OP_SIM only_toplevel=false
schname="tcleval([file rootname [file tail [xschem get schname]]])"
format="tcleval( @value )" value="
.control
op
write @schname\\\\.raw
.endc
"
}
C {simulator_commands_shown.sym} -1440 -820 0 0 {
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
C {devices/launcher.sym} 110 250 0 0 {name=h2
descr="OP annotate" 
tclcommand="xschem annotate_op"
}
C {code_shown.sym} -1920 -670 0 0 {name=PARAMS only_toplevel=false value="
.option rshunt=1e9
.option method=gear
.param vcm=0.7 cl=0.1p
.save all
"}
C {code_shown.sym} -1650 -640 0 0 {name=LOAD only_toplevel=false value="
CL1 Vout 0 \{cl\}
"
}
C {devices/code_shown.sym} -1110 -840 0 0 {name=SAVE only_toplevel=true
schname="tcleval([file rootname [file tail [xschem get schname]]])"
format="tcleval( @value )"
value="
.include @schname\\\\.save
"}
C {launcher.sym} 110 170 0 0 {name=h4
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
C {devices/code_shown.sym} -1100 -740 0 0 {name=MODEL
only_toplevel=true
format="tcleval( @value )"
value="
.include $::PDK_ROOT/ihp-sg13g2/libs.ref/sg13g2_stdcell/spice/sg13g2_stdcell.spice

"
place=header}
C {code_shown.sym} 140 -700 0 0 {name=MC_SETTINGS
only_toplevel=false
value="
**nr_workers=1
**nr_mc_sims=100

**results_plot_begin
**fall_error
**results_plot_end
"
}
C {launcher.sym} 210 -425 0 0 {name=h1
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
C {simulator_commands_shown.sym} 430 -730 0 0 {
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
C {/run/media/frhridha/disc/DISC C/IC_Projects/ic_design/chipaloza/sg13cmos5l_Wind_Comp/schematic/xschem/wind_comp/wind_comp.sym} -70 0 0 0 {name=x1}
C {lab_pin.sym} -80 -130 2 1 {name=p1 lab=vdd}
C {lab_pin.sym} -220 -30 2 1 {name=p2 lab=vh}
C {lab_pin.sym} 150 0 2 0 {name=p3 lab=vout}
C {lab_pin.sym} -200 0 2 1 {name=p4 lab=vin}
C {lab_pin.sym} -220 30 2 1 {name=p5 lab=vl}
C {lab_pin.sym} -60 80 2 0 {name=p6 lab=ibias}
C {lab_pin.sym} -80 90 2 1 {name=p7 lab=vss}
C {code_shown.sym} -1090 -460 0 0 {name=TRAN_SIM2 only_toplevel=false value="
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
C {lab_pin.sym} -60 -90 2 0 {name=p8 lab=en}
