v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -160 180 -160 220 {lab=n_mrr}
N 170 180 170 220 {lab=vout}
N 0 20 170 20 {lab=vt}
N 0 -20 0 20 {lab=vt}
N 20 340 170 340 {lab=vss}
N -20 250 130 250 {lab=n_mrr}
N 20 340 20 380 {lab=vss}
N -160 340 20 340 {lab=vss}
N 170 250 170 340 {lab=vss}
N -160 250 -160 340 {lab=vss}
N -260 90 -200 90 {lab=vom}
N 210 90 250 90 {lab=vop}
N 170 180 260 180 {lab=vout}
N 170 120 170 180 {lab=vout}
N -0 -110 0 -50 {lab=vdd}
N -140 -50 -40 -50 {lab=ibp}
N -160 20 0 20 {lab=vt}
N -140 -80 -140 -50 {lab=ibp}
N -160 20 -160 60 {lab=vt}
N 170 20 170 60 {lab=vt}
N -160 90 170 90 {lab=vdd}
N -20 180 -20 250 {lab=n_mrr}
N -120 250 -20 250 {lab=n_mrr}
N -160 180 -20 180 {lab=n_mrr}
N -160 120 -160 180 {lab=n_mrr}
N -760 -40 -760 10 {lab=iout}
N -830 -40 -760 -40 {lab=iout}
N -830 -70 -830 -40 {lab=iout}
N -760 10 -700 10 {lab=iout}
N -660 10 -660 90 {lab=vss}
N -660 -80 -660 -20 {lab=ibp}
N -620 -140 -580 -140 {lab=ibp}
N -580 -140 -580 -80 {lab=ibp}
N -660 -80 -580 -80 {lab=ibp}
N -660 -110 -660 -80 {lab=ibp}
N -660 -190 -660 -140 {lab=vdd}
N 160 -370 160 -330 {lab=n_mrr
spice_ignore=true}
N 160 -270 160 -240 {lab=vss
spice_ignore=true}
N 90 -300 120 -300 {lab=en_n
spice_ignore=true}
N 430 -370 430 -330 {lab=ibp
spice_ignore=true}
N 430 -270 430 -240 {lab=vss
spice_ignore=true}
N 360 -300 390 -300 {lab=en_n
spice_ignore=true}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -20 -50 2 1 {name=M1
l=3u
w=1u
ng=1
m=2
mm_ok=1
annot_side=2
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -140 250 0 1 {name=M2
l=3u
w=0.15u
ng=1
m=2
mm_ok=1
model=sg13_lv_nmos
annot_side=2
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -180 90 2 1 {name=M3
l=1u
w=3.12u
ng=1
m=2
mm_ok=1
annot_side=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 150 250 0 0 {name=M4
l=3u
w=0.15u
ng=1
m=2
mm_ok=1
model=sg13_lv_nmos
annot_side=2
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 190 90 2 0 {name=M5
l=1u
w=3.12u
ng=1
m=2
mm_ok=1
annot_side=1
model=sg13_lv_pmos
spiceprefix=X
}
C {iopin.sym} 0 -110 0 0 {name=p1 lab=vdd}
C {iopin.sym} -260 90 0 1 {name=p2 lab=vom
}
C {iopin.sym} 250 90 0 0 {name=p3 lab=vop}
C {iopin.sym} 20 380 0 0 {name=p4 lab=vss}
C {iopin.sym} 260 180 0 0 {name=p5 lab=vout}
C {lab_pin.sym} -20 90 1 0 {name=p7 lab=vdd}
C {lab_pin.sym} 120 20 1 0 {name=p8 lab=vt}
C {iopin.sym} -830 -70 0 0 {name=p11 sig_type=std_logic lab=iout}
C {sg13g2_pr/sg13_lv_nmos.sym} -680 10 0 0 {name=M6
l=5u
w=2u
ng=1
m=1
annot_side=2
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} -660 90 2 0 {name=p10 lab=vss}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -640 -140 2 0 {name=M7
l=3u
w=1u
ng=1
m=1
mm_ok=1
annot_side=2
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_pin.sym} -660 -190 1 0 {name=p12 lab=vdd}
C {lab_pin.sym} -580 -140 2 0 {name=p6 lab=ibp}
C {lab_pin.sym} -140 -80 2 1 {name=p13 lab=ibp}
C {sg13g2_pr/sg13_lv_nmos.sym} 140 -300 2 1 {name=MB3
l=0.5u
w=0.5u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
annot_side=1
spice_ignore=true}
C {lab_pin.sym} 90 -300 2 1 {name=p43 sig_type=std_logic lab=en_n
spice_ignore=true}
C {lab_pin.sym} 160 -240 2 1 {name=p44 sig_type=std_logic lab=vss
spice_ignore=true}
C {lab_pin.sym} 160 -370 0 1 {name=p45 lab=n_mrr
spice_ignore=true}
C {sg13g2_pr/sg13_lv_nmos.sym} 410 -300 2 1 {name=MB4
l=0.5u
w=0.5u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
annot_side=1
spice_ignore=true}
C {lab_pin.sym} 360 -300 2 1 {name=p41 sig_type=std_logic lab=en_n
spice_ignore=true}
C {lab_pin.sym} 430 -240 2 1 {name=p46 sig_type=std_logic lab=vss
spice_ignore=true}
C {lab_pin.sym} 430 -370 0 1 {name=p47 lab=ibp
spice_ignore=true}
C {lab_pin.sym} -20 180 0 1 {name=p9 lab=n_mrr}
