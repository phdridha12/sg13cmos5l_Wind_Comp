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
N -270 -690 -270 -650 {lab=n_mrr
}
N -340 -620 -310 -620 {lab=en_n
}
N 0 -690 0 -620 {lab=vdd
}
N 0 -590 0 -560 {lab=ibp
}
N -70 -620 -40 -620 {lab=en
}
N -270 -620 -270 -560 {lab=vss}
N 680 300 720 270 {lab=vss}
N 720 270 720 300 {lab=vss}
N 720 300 760 300 {lab=vss}
N 720 330 720 370 {lab=n_mrr}
N 510 300 550 270 {lab=vss}
N 550 270 550 300 {lab=vss}
N 550 300 590 300 {lab=vss}
N 550 330 550 370 {lab=vout}
N 850 300 890 270 {lab=vss}
N 890 270 890 300 {lab=vss}
N 890 300 990 300 {lab=vss}
N 890 330 890 360 {lab=ibp}
N 1340 270 1380 300 {lab=vdd}
N 1340 270 1340 300 {lab=vdd}
N 1260 300 1340 300 {lab=vdd}
N 1340 330 1340 360 {lab=vt}
N 1530 270 1570 300 {lab=vdd}
N 1530 270 1530 300 {lab=vdd}
N 1450 300 1530 300 {lab=vdd}
N 1530 330 1530 360 {lab=ibp}
N 1720 270 1760 300 {lab=vdd}
N 1720 270 1720 300 {lab=vdd}
N 1640 300 1720 300 {lab=vdd}
N 1720 330 1720 360 {lab=vout}
N 1900 270 1940 300 {lab=vdd}
N 1900 270 1900 300 {lab=vdd}
N 1820 300 1900 300 {lab=vdd}
N 1900 330 1900 360 {lab=n_mrr}
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
C {lab_pin.sym} 120 20 1 0 {name=p8 lab=vt
}
C {iopin.sym} -830 -70 0 0 {name=p11 sig_type=std_logic lab=iout}
C {sg13g2_pr/sg13_lv_nmos.sym} -680 10 0 0 {name=M6
l=3u
w=5u
ng=1
m=2
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
C {sg13g2_pr/sg13_lv_nmos.sym} -290 -620 2 1 {name=MB3
l=0.13u
w=0.15u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
annot_side=1
}
C {ipin.sym} -340 -620 2 1 {name=p43 sig_type=std_logic lab=en_n
}
C {lab_pin.sym} -270 -560 2 1 {name=p44 sig_type=std_logic lab=vss
}
C {lab_pin.sym} -270 -690 0 1 {name=p45 lab=n_mrr
}
C {sg13g2_pr/sg13_lv_pmos.sym} -20 -620 2 1 {name=MB4
l=0.13u
w=0.15u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
annot_side=1
}
C {lab_pin.sym} 0 -690 2 1 {name=p46 sig_type=std_logic lab=vdd
}
C {lab_pin.sym} 0 -560 0 1 {name=p47 lab=ibp
}
C {lab_pin.sym} -20 180 0 1 {name=p9 lab=n_mrr}
C {ipin.sym} -70 -620 2 1 {name=p14 sig_type=std_logic lab=en
}
C {sg13g2_pr/sg13_lv_nmos.sym} 700 300 0 0 {name=M8
l=0.5u
w=0.15u
ng=1
m=2
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} 760 300 0 1 {name=p36 lab=vss}
C {lab_pin.sym} 720 370 0 1 {name=p15 lab=n_mrr}
C {sg13g2_pr/sg13_lv_nmos.sym} 530 300 0 0 {name=M9
l=0.5u
w=0.15u
ng=1
m=2
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} 590 300 0 1 {name=p16 lab=vss}
C {lab_pin.sym} 550 370 0 1 {name=p17 lab=vout}
C {sg13g2_pr/sg13_lv_nmos.sym} 870 300 0 0 {name=M10
l=0.5u
w=5u
ng=1
m=2
annot_side=2
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} 990 300 0 1 {name=p18 lab=vss}
C {lab_pin.sym} 890 360 2 0 {name=p20 lab=ibp}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 1360 300 2 0 {name=M11
l=0.5u
w=0.5u
ng=1
m=2
mm_ok=1
annot_side=2
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_pin.sym} 1340 360 2 0 {name=p19 lab=vt
}
C {lab_pin.sym} 1260 300 2 1 {name=p21 lab=vdd}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 1550 300 2 0 {name=M12
l=0.5u
w=0.5u
ng=1
m=2
mm_ok=1
annot_side=2
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_pin.sym} 1530 360 2 0 {name=p22 lab=ibp
}
C {lab_pin.sym} 1450 300 2 1 {name=p23 lab=vdd}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 1740 300 2 0 {name=M13
l=0.5u
w=3.12u
ng=1
m=2
mm_ok=1
annot_side=2
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_pin.sym} 1720 360 2 0 {name=p24 lab=vout
}
C {lab_pin.sym} 1640 300 2 1 {name=p25 lab=vdd}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 1920 300 2 0 {name=M14
l=0.5u
w=3.12u
ng=1
m=2
mm_ok=1
annot_side=2
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_pin.sym} 1900 360 2 0 {name=p26 lab=n_mrr
}
C {lab_pin.sym} 1820 300 2 1 {name=p27 lab=vdd}
