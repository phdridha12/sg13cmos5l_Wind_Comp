# Design Block Hierarchy — WINCOMP_Chipalooza2_Verification

- **PDK:** IHP SG13CMOS5L
- **Detected Files:** xschem/comparator.sch, xschem/comparator.sym, xschem/decision_circuit.sch, xschem/decision_circuit.sym, xschem/final_stage_ota.sch, xschem/final_stage_ota.sym, xschem/sg13cmos5l_and2_2.sym, xschem/sg13cmos5l_inv_1.sym, xschem/sg13cmos5l_inv_16.sym, xschem/wind_comp.sch, xschem/wind_comp.sym

## Top-Level & Sub-Blocks

| Block Name | Role | Pins | Child Instances | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `wind_comp` | TOP | `vdd, vout, vl, vh, ibias, vss, vin, en` | `x1:comparator`, `x2:comparator`, `x3:sg13cmos5l_and2_2` | Imported from xschem/wind_comp.sch |
| `comparator` | SUB | `vdd, vss, v-, v+, ibias, votap, vom, vop, votan, vout, ibias_en, en, en_n, tail` | `M6:sg13_lv_nmos`, `M8:sg13_lv_pmos`, `M9:sg13_lv_nmos`, `M10:sg13_lv_pmos`, `M11:sg13_lv_nmos`, `x1:decision_circuit`, `x2:decision_circuit`, `x3:sg13cmos5l_inv_16`, `x4:final_stage_ota`, `x5:sg13cmos5l_inv_16`, `M12:sg13_lv_nmos`, `MB1:sg13_lv_pmos`, `MB2:sg13_lv_pmos`, `MB5:sg13_lv_nmos`, `x6:sg13cmos5l_inv_1`, `MB3:sg13_lv_nmos`, `x7:sg13cmos5l_antennanp`, `M1:sg13_lv_nmos`, `M2:sg13_lv_nmos`, `M3:sg13_lv_nmos`, `M5:sg13_lv_nmos`, `M4:sg13_lv_pmos` | Imported from xschem/comparator.sch |
| `decision_circuit` | SUB | `vota, shift, vota_n, vdd, vss, vout` | `M1:sg13_lv_pmos`, `M2:sg13_lv_nmos`, `M3:sg13_lv_nmos`, `M4:sg13_lv_nmos`, `M5:sg13_lv_pmos` | Imported from xschem/decision_circuit.sch |
| `final_stage_ota` | SUB | `vdd, vom, vop, vss, vout, vt, iout, ibp, en_n, n_mrr, en` | `M1:sg13_lv_pmos`, `M2:sg13_lv_nmos`, `M3:sg13_lv_pmos`, `M4:sg13_lv_nmos`, `M5:sg13_lv_pmos`, `M6:sg13_lv_nmos`, `M7:sg13_lv_pmos`, `MB3:sg13_lv_nmos`, `MB4:sg13_lv_pmos`, `M8:sg13_lv_nmos`, `M9:sg13_lv_nmos`, `M10:sg13_lv_nmos`, `M11:sg13_lv_pmos`, `M12:sg13_lv_pmos`, `M13:sg13_lv_pmos`, `M14:sg13_lv_pmos` | Imported from xschem/final_stage_ota.sch |
| `sg13_lv_nmos` | SUB | `vinp, vinn, vdd, vss, vout` | — | Auto-detected sub-block referenced by parent schematic. |
| `sg13_lv_pmos` | SUB | `vinp, vinn, vdd, vss, vout` | — | Auto-detected sub-block referenced by parent schematic. |
| `sg13cmos5l_and2_2` | SUB | `vin, vdd, vss, vout` | — | Imported from xschem/sg13cmos5l_and2_2.sym |
| `sg13cmos5l_antennanp` | SUB | `vinp, vinn, vdd, vss, vout` | — | Auto-detected sub-block referenced by parent schematic. |
| `sg13cmos5l_inv_1` | SUB | `vin, vdd, vss, vout` | — | Imported from xschem/sg13cmos5l_inv_1.sym |
| `sg13cmos5l_inv_16` | SUB | `vin, vdd, vss, vout` | — | Imported from xschem/sg13cmos5l_inv_16.sym |
