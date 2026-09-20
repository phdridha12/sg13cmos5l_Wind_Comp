v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -110 -50 -110 0 {lab=#net1}
N -10 0 100 0 {lab=#net1}
N 100 -50 100 0 {lab=#net1}
N -10 0 -10 70 {lab=#net1}
N -110 0 -10 0 {lab=#net1}
N -10 130 -10 150 {lab=vss}
N -110 -300 -110 -250 {lab=vdd}
N -110 -170 -110 -110 {lab=votap}
N 100 -170 100 -110 {lab=votan}
N -200 -80 -150 -80 {lab=v+}
N 100 -300 100 -250 {lab=vdd}
N 20 -300 100 -300 {lab=vdd}
N 20 -350 20 -300 {lab=vdd}
N -110 -300 20 -300 {lab=vdd}
N 80 150 80 180 {lab=vss}
N 30 150 80 150 {lab=vss}
N 30 -80 100 -80 {lab=vss}
N -110 -80 30 -80 {lab=vss}
N -10 150 30 150 {lab=vss}
N 30 100 30 150 {lab=vss}
N -10 100 30 100 {lab=vss}
N 30 -80 30 100 {lab=vss}
N 140 -80 210 -80 {lab=v-}
N 100 -170 170 -170 {lab=votan}
N 100 -220 100 -170 {lab=votan}
N 140 -250 170 -250 {lab=votan}
N 170 -250 170 -170 {lab=votan}
N -180 -250 -150 -250 {lab=votap}
N -180 -170 -110 -170 {lab=votap}
N -110 -220 -110 -170 {lab=votap}
N -180 -250 -180 -170 {lab=votap}
N -190 -250 -180 -250 {lab=votap}
N 170 -250 180 -250 {lab=votan}
N 560 -290 560 -260 {lab=vdd}
N 630 -190 670 -190 {lab=vom}
N 460 -210 490 -210 {lab=votan}
N 460 -160 490 -160 {lab=vop}
N 580 -120 580 -90 {lab=vss}
N 540 -120 540 -90 {lab=vss}
N 540 -90 580 -90 {lab=vss}
N -500 -290 -500 -260 {lab=vdd}
N -610 -190 -570 -190 {lab=vop}
N -430 -210 -400 -210 {lab=votap}
N -430 -160 -400 -160 {lab=vom}
N -520 -120 -520 -90 {lab=vss}
N -480 -120 -480 -90 {lab=vss}
N -520 -90 -480 -90 {lab=vss}
N 850 -140 900 -140 {lab=vop}
N 850 -80 900 -80 {lab=vom}
N 980 -210 980 -170 {lab=vdd}
N 1000 -60 1000 -20 {lab=iout}
N 980 -50 980 -10 {lab=vss}
N 1080 -110 1170 -110 {lab=#net2}
N 1250 -110 1290 -110 {lab=#net3}
N 1370 -110 1400 -110 {lab=vout}
N -180 100 -50 100 {lab=iout}
C {sg13g2_pr/sg13_lv_nmos.sym} -130 -80 0 0 {name=M6
l=3u
w=0.26u
ng=1
m=2
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_pmos.sym} -130 -250 2 1 {name=M8
l=1u
w=0.35u
ng=1
m=2
model=sg13_lv_pmos
spiceprefix=X
annot_side=1}
C {sg13g2_pr/sg13_lv_nmos.sym} 120 -80 0 1 {name=M9
l=3u
w=0.26u
ng=1
m=2
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_pmos.sym} 120 -250 2 0 {name=M10
l=1u
w=0.35u
ng=1
m=2
model=sg13_lv_pmos
spiceprefix=X
annot_side=1}
C {sg13g2_pr/sg13_lv_nmos.sym} -30 100 0 0 {name=M11
l=5u
w=2u
ng=1
m=2
model=sg13_lv_nmos
spiceprefix=X
}
C {iopin.sym} 20 -350 2 1 {name=p1 sig_type=std_logic lab=vdd}
C {iopin.sym} 80 180 3 1 {name=p4 sig_type=std_logic lab=vss}
C {iopin.sym} 210 -80 0 0 {name=p5 lab=v-
}
C {iopin.sym} -200 -80 0 1 {name=p7 lab=v+
}
C {iopin.sym} -180 100 0 1 {name=p11 sig_type=std_logic lab=iout}
C {decision_circuit/decision_circuit.sym} 560 -190 0 0 {name=x1}
C {lab_pin.sym} 560 -290 0 1 {name=p2 lab=vdd}
C {lab_pin.sym} -400 -210 0 1 {name=p3 lab=votap}
C {lab_pin.sym} 670 -190 0 1 {name=p6 lab=vom}
C {lab_pin.sym} 540 -90 0 0 {name=p10 lab=vss}
C {decision_circuit/decision_circuit.sym} -500 -190 0 1 {name=x2}
C {lab_pin.sym} -500 -290 0 0 {name=p12 lab=vdd}
C {lab_pin.sym} -610 -190 0 0 {name=p14 lab=vop}
C {lab_pin.sym} 460 -210 0 0 {name=p15 lab=votan}
C {lab_pin.sym} -480 -90 0 1 {name=p16 lab=vss}
C {lab_pin.sym} -190 -250 0 0 {name=p17 lab=votap}
C {lab_pin.sym} 180 -250 0 1 {name=p18 lab=votan}
C {lab_pin.sym} 460 -160 0 0 {name=p19 lab=vop}
C {lab_pin.sym} -400 -160 0 1 {name=p8 lab=vom}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_16.sym} 1210 -110 0 0 {name=x3 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {final_stage_ota/final_stage_ota.sym} 1270 -110 0 0 {name=x4}
C {lab_pin.sym} 980 -210 0 0 {name=p20 lab=vdd}
C {lab_pin.sym} 850 -140 0 0 {name=p21 lab=vop}
C {lab_pin.sym} 850 -80 0 0 {name=p22 lab=vom}
C {iopin.sym} 1400 -110 0 0 {name=p23 lab=vout}
C {lab_pin.sym} 980 -10 0 0 {name=p24 lab=vss}
C {lab_pin.sym} 1000 -20 0 1 {name=p25 lab=iout}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_16.sym} 1330 -110 0 0 {name=x5 VDD=VDD VSS=VSS prefix=sg13g2_ }
