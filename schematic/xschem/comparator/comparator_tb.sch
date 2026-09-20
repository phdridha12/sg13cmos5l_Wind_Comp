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
N 280 0 320 0 {lab=vout}
N 60 30 100 30 {lab=vn}
N 60 -30 100 -30 {lab=vp}
N 180 -90 180 -60 {lab=vdd}
C {code_shown.sym} -1080 -310 0 0 {name=NETLIST only_toplevel=false value="
VSS VSS 0 0
VDD VDD VSS 1.2
VEN EN VSS 0
Vcm Vcm VSS \{vcm\}
Ibias VDD Ibias 1u
"}
C {code_shown.sym} -760 -50 0 0 {name=OP_SIM only_toplevel=false
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
C {code_shown.sym} -720 -590 0 0 {name=PARAMS only_toplevel=false value="
.option rshunt=1e9
.param vcm=0.75 cl=0.1p
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
C {code_shown.sym} -1490 -240 0 0 {name=TRAN_SIM only_toplevel=false value="
Vp Vp 0 sin(\{vcm\} 50u 100)
Vn Vn 0 sin(\{vcm\} -50u 100)
.control
tran 100u 100m
plot vout vp vn
let vdiff=vp-vn
meas tran vth find vdiff when vout=0.6 rise=4
.endc
"
}
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
C {code_shown.sym} -1500 -630 0 0 {name=DC_SIM only_toplevel=false value="
Vp Vp 0 0
Vn Vn 0 0.6

.control
dc Vp 0 1.2 0.001

plot vout


.endc
"
spice_ignore=true}
C {/foss/designs/ic_design/chipaloza/schema/comparator/comparator.sym} 180 0 0 0 {name=x1}
C {lab_pin.sym} 180 -90 0 1 {name=p1 lab=vdd}
C {lab_pin.sym} 320 0 0 1 {name=p2 lab=vout}
C {lab_pin.sym} 60 30 0 0 {name=p3 lab=vn}
C {lab_pin.sym} 60 -30 0 0 {name=p4 lab=vp}
C {lab_pin.sym} 200 80 0 1 {name=p5 lab=ibias}
C {lab_pin.sym} 180 90 0 1 {name=p6 lab=vss}
C {devices/code_shown.sym} -1100 -740 0 0 {name=MODEL
only_toplevel=true
format="tcleval( @value )"
value="
.include $::PDK_ROOT/ihp-sg13g2/libs.ref/sg13g2_stdcell/spice/sg13g2_stdcell.spice

"
place=header}
