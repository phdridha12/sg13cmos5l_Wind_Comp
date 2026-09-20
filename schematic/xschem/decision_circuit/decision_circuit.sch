v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -250 110 -160 110 {lab=shift}
N -370 50 -370 80 {lab=vout}
N -120 80 -40 80 {lab=vota_n}
N -330 80 -160 80 {lab=vss}
N -330 110 -250 110 {lab=shift}
N -250 110 -250 150 {lab=shift}
N -250 150 -40 150 {lab=shift}
N -230 50 -160 50 {lab=vout}
N -230 0 -230 50 {lab=vout}
N -370 50 -230 50 {lab=vout}
N -230 -160 -230 -70 {lab=vdd}
N -400 -70 -270 -70 {lab=vota}
N -230 0 -160 0 {lab=vout}
N -230 -40 -230 0 {lab=vout}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -250 -70 0 0 {name=M1
l=1u
w=0.7u
ng=1
m=1
mm_ok=1
annot_side=2
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -350 80 0 0 {name=M2
l=10u
w=0.26u
ng=1
m=2
mm_ok=1
model=sg13_lv_nmos
annot_side=1
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -140 80 0 1 {name=M3
l=10u
w=0.26u
ng=1
m=2
mm_ok=1
model=sg13_lv_nmos
annot_side=1
spiceprefix=X
}
C {iopin.sym} -400 -70 0 1 {name=p1 sig_type=std_logic lab=vota}
C {iopin.sym} -40 150 0 0 {name=p2 sig_type=std_logic lab=shift}
C {iopin.sym} -40 80 0 0 {name=p3 sig_type=std_logic lab=vota_n}
C {iopin.sym} -230 -160 0 1 {name=p4 sig_type=std_logic lab=vdd}
C {iopin.sym} -230 80 0 1 {name=p5 sig_type=std_logic lab=vss}
C {iopin.sym} -160 0 0 0 {name=p6 sig_type=std_logic lab=vout}
