v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
L 4 -1040 -370 -1040 -280 {}
L 4 -1040 -280 -1010 -280 {}
L 4 -1010 -280 -1000 -290 {}
L 4 -1000 -360 -1000 -290 {}
L 4 -1010 -370 -1000 -360 {}
L 4 -1040 -370 -1010 -370 {}
L 4 -960 -370 -960 -290 {}
L 4 -960 -290 -950 -280 {}
L 4 -950 -280 -920 -280 {}
L 4 -920 -280 -910 -290 {}
L 4 -910 -370 -910 -290 {}
L 4 -880 -370 -880 -280 {}
L 4 -880 -370 -850 -340 {}
L 4 -850 -340 -830 -370 {}
L 4 -830 -370 -830 -280 {}
L 4 -810 -370 -810 -280 {}
L 4 -810 -370 -780 -340 {}
L 4 -780 -340 -760 -370 {}
L 4 -760 -370 -760 -280 {}
L 4 -730 -370 -710 -370 {}
L 4 -730 -280 -710 -280 {}
L 4 -720 -370 -720 -280 {}
L 4 -690 -370 -640 -370 {}
L 4 -690 -370 -690 -280 {}
L 4 -690 -280 -640 -280 {}
L 4 -690 -320 -660 -320 {}
L 4 -620 -360 -610 -370 {}
L 4 -620 -360 -620 -340 {}
L 4 -620 -340 -610 -330 {}
L 4 -610 -330 -580 -330 {}
L 4 -580 -330 -570 -320 {}
L 4 -570 -320 -570 -300 {}
L 4 -570 -300 -570 -290 {}
L 4 -580 -280 -570 -290 {}
L 4 -610 -280 -580 -280 {}
L 4 -620 -290 -610 -280 {}
L 4 -620 -300 -620 -290 {}
L 4 -610 -370 -580 -370 {}
L 4 -580 -370 -570 -360 {}
L 4 -570 -360 -570 -350 {}
L 4 -1080 -240 -1080 -50 {}
L 4 -1080 -50 -500 -50 {}
L 4 -500 -240 -500 -50 {}
L 4 -1080 -240 -500 -240 {}
L 4 -780 -240 -780 -50 {}
N -160 140 -70 140 {lab=shift}
N -280 80 -280 110 {lab=vout}
N -30 110 50 110 {lab=vota_n}
N -240 110 -70 110 {lab=vss}
N -240 140 -160 140 {lab=shift}
N -160 140 -160 180 {lab=shift}
N -160 180 50 180 {lab=shift}
N -140 80 -70 80 {lab=vout}
N -140 30 -140 80 {lab=vout}
N -280 80 -140 80 {lab=vout}
N -140 -130 -140 -40 {lab=vdd}
N -310 -40 -180 -40 {lab=vota}
N -140 30 -70 30 {lab=vout}
N -140 -10 -140 30 {lab=vout}
N -690 -160 -650 -190 {lab=vss}
N -650 -190 -650 -160 {lab=vss}
N -650 -160 -580 -160 {lab=vss}
N -650 -130 -650 -100 {lab=vout}
N -900 -190 -860 -160 {lab=vdd}
N -900 -190 -900 -160 {lab=vdd}
N -1010 -160 -900 -160 {lab=vdd}
N -900 -130 -900 -100 {lab=vout}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -160 -40 0 0 {name=M1
l=1u
w=0.7u
ng=1
m=1
mm_ok=1
annot_side=2
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -260 110 0 0 {name=M2
l=10u
w=0.26u
ng=1
m=2
mm_ok=1
model=sg13_lv_nmos
annot_side=1
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -50 110 0 1 {name=M3
l=10u
w=0.26u
ng=1
m=2
mm_ok=1
model=sg13_lv_nmos
annot_side=1
spiceprefix=X
}
C {iopin.sym} -310 -40 0 1 {name=p1 sig_type=std_logic lab=vota}
C {iopin.sym} 50 180 0 0 {name=p2 sig_type=std_logic lab=shift}
C {iopin.sym} 50 110 0 0 {name=p3 sig_type=std_logic lab=vota_n}
C {iopin.sym} -140 -130 0 1 {name=p4 sig_type=std_logic lab=vdd}
C {iopin.sym} -140 110 0 1 {name=p5 sig_type=std_logic lab=vss}
C {iopin.sym} -70 30 0 0 {name=p6 sig_type=std_logic lab=vout}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -670 -160 0 0 {name=M4
l=0.5u
w=0.26u
ng=1
m=4
mm_ok=1
model=sg13_lv_nmos
annot_side=1
spiceprefix=X
}
C {lab_pin.sym} -650 -100 0 0 {name=p7 sig_type=std_logic lab=vout}
C {lab_pin.sym} -580 -160 0 1 {name=p8 sig_type=std_logic lab=vss}
C {sg13g2_pr/sg13_lv_pmos.sym} -880 -160 2 0 {name=M5
l=0.5u
w=0.35u
ng=1
m=2
model=sg13_lv_pmos
spiceprefix=X
annot_side=1}
C {lab_pin.sym} -900 -100 0 0 {name=p9 sig_type=std_logic lab=vout}
C {lab_pin.sym} -1010 -160 0 0 {name=p10 sig_type=std_logic lab=vdd}
