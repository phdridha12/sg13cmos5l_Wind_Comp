v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 200 50 200 80 {lab=ibias}
N 180 60 180 90 {lab=vss}
N 60 240 100 240 {lab=vl}
N 60 -30 100 -30 {lab=vh}
N 180 -90 180 -60 {lab=vdd}
N 80 180 100 180 {lab=vin}
N 80 110 80 180 {lab=vin}
N 80 30 100 30 {lab=vin}
N 200 260 200 290 {lab=ibias}
N 180 270 180 300 {lab=vss}
N 180 120 180 150 {lab=vdd}
N 280 -0 370 0 {lab=#net1}
N 370 0 370 50 {lab=#net1}
N 370 50 380 50 {lab=#net1}
N 280 210 370 210 {lab=#net2}
N 370 90 370 210 {lab=#net2}
N 370 90 380 90 {lab=#net2}
N 10 110 80 110 {lab=vin}
N 80 30 80 110 {lab=vin}
N 660 -170 660 -120 {lab=ibias}
N 620 -170 660 -170 {lab=ibias}
N 620 -170 620 -150 {lab=ibias}
N 620 -200 620 -170 {lab=ibias}
N 620 -120 620 -40 {lab=vss}
N 500 70 620 70 {lab=vout}
C {comparator/comparator.sym} 180 0 0 0 {name=x1}
C {iopin.sym} 180 -90 0 1 {name=p1 lab=vdd}
C {iopin.sym} 620 70 0 0 {name=p2 lab=vout}
C {iopin.sym} 60 240 0 1 {name=p3 lab=vl}
C {iopin.sym} 60 -30 0 1 {name=p4 lab=vh}
C {lab_pin.sym} 200 80 0 1 {name=p5 lab=ibias}
C {lab_pin.sym} 180 90 0 1 {name=p6 lab=vss}
C {comparator/comparator.sym} 180 210 0 0 {name=x2}
C {iopin.sym} 200 290 0 1 {name=p7 lab=ibias}
C {iopin.sym} 180 300 0 1 {name=p8 lab=vss}
C {lab_pin.sym} 180 120 0 1 {name=p9 lab=vdd}
C {sg13cmos5l_stdcells/sg13cmos5l_nand2_1.sym} 440 70 0 0 {name=x3 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {iopin.sym} 10 110 0 1 {name=p10 lab=vin}
C {sg13g2_pr/sg13_lv_nmos.sym} 640 -120 0 1 {name=M12
l=5u
w=2u
ng=1
m=1
annot_side=2
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} 620 -40 0 1 {name=p11 lab=vss}
C {lab_pin.sym} 620 -200 0 1 {name=p12 lab=ibias}
