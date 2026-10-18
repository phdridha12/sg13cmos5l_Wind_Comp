v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
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
N -700 90 -660 60 {lab=vss}
N -660 60 -660 90 {lab=vss}
N -660 90 -590 90 {lab=vss}
N -660 120 -660 150 {lab=vout}
N -910 60 -870 90 {lab=vdd}
N -910 60 -910 90 {lab=vdd}
N -1020 90 -910 90 {lab=vdd}
N -910 120 -910 150 {lab=vout}
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
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -680 90 0 0 {name=M4
l=0.5u
w=0.26u
ng=1
m=4
mm_ok=1
model=sg13_lv_nmos
annot_side=1
spiceprefix=X
}
C {lab_pin.sym} -660 150 0 0 {name=p7 sig_type=std_logic lab=vout}
C {lab_pin.sym} -590 90 0 1 {name=p8 sig_type=std_logic lab=vss}
C {sg13g2_pr/sg13_lv_pmos.sym} -890 90 2 0 {name=M5
l=0.5u
w=0.35u
ng=1
m=2
model=sg13_lv_pmos
spiceprefix=X
annot_side=1}
C {lab_pin.sym} -910 150 0 0 {name=p9 sig_type=std_logic lab=vout}
C {lab_pin.sym} -1020 90 0 0 {name=p10 sig_type=std_logic lab=vdd}
