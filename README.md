"""# Window Comparator (WINCOMP)

A high-precision, open-loop 5-transistor (5T) differential window comparator designed in the **IHP SG13CMOS5L (130 nm CMOS)** technology for the **Chipalooza Challenge #2** run.

---

## 1. Overview
* **IP Block Name:** Window Comparator
* **Abbreviation:** WINCOMP
* **Category:** Analog IP (Open-source library block)
* **Target PDK:** IHP SG13CMOS5L (130 nm CMOS, 5 metal layers)
* **Toolchain/Design Flow:** Xschem, ngspice, Magic, KLayout, Netgen (IIC-OSIC-TOOLS)
* **Designer:** FARAH RIDHA

---

## 2. Definition
A window comparator is a dual-threshold voltage detector. It compares a single input voltage (`VIN`) against two independent reference voltages (`VL` for the lower threshold and `VH` for the upper threshold) and asserts a digital output flag when the input lies strictly between the two thresholds.

---

## 3. Target Applications
* Battery over-voltage / under-voltage monitoring
* Power-good / brown-out detection in SoC power management
* Sensor out-of-range flagging (analog level supervision)
* Simple threshold-based wake-up or alarm logic in mixed-signal chips

---

## 4. Pin List (I/O)

| Pin | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| **VIN** | Input | Analog | Signal to be monitored |
| **VL** | Input | Analog | Lower threshold reference (external) |
| **VH** | Input | Analog | Upper threshold reference (external) |
| **VDD** | Power | Supply | 1.2 V core supply |
| **VSS** | Power | Ground | 0 V |
| **OUT** | Output | Digital | High when `VL` < `VIN` < `VH`; low otherwise |

---

## 5. Electrical Specifications

| Parameter | Symbol | Min | Typ | Max | Unit |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Supply voltage** | `VDD` | 1.08 | 1.2 | 1.32 | `V` |
| **Operating temperature** | `TEMP` | -40 | 27 | 125 | `°C` |
| **Input common-mode range** | `ICMR` | 0.3 | — | `VDD-0.3` | `V` |
| **Differential DC gain** | `AVDC` | 30 | 40 | 50 | `dB` |
| **Input-referred offset voltage** | `VOS` | — | `±5` | — | `mV` |
| **Common-mode rejection ratio** | `CMRR` | 45 | 55 | — | `dB` |
| **Power-supply rejection ratio** | `PSRR` | 35 | 45 | — | `dB` |
| **Propagation delay (±10 mV overdrive)** | `t_PD` | — | 10 | 20 | `ns` |
| **Static power (both comparators)** | `P_STAT` | 15 | 30 | — | `µW` |
| **Output logic high / low** | `V_OH` / `V_OL` | `VDD-0.1` / `0` | — | `VDD` / `0.1` | `V` |

---

## 6. Architecture Notes
* Consists of two matched single-stage 5T differential comparators (one vs. `VL`, one vs. `VH`) followed by a standard-cell AND gate combining their outputs into `OUT`.
* References `VL` and `VH` are fed via external pins (no on-chip bandgap or resistor ladder is included in this block; reference generation is left to the system integrator).
* Both comparator instances share a matched analog subcircuit layout using a **common-centroid configuration** to minimize offset and layout mismatch.
* Designed intentionally without hysteresis to prioritize maximum input sensitivity, though architectural provisions for programmable hysteresis are reserved for future layouts if noise immunity adjustments are required.

---

## 7. Verification & Test Plan
The testbench suite covers the following verifications using **ngspice** and **Xschem**:
* **DC Characterization:** Threshold/offset sweeps across process corners (`SS`, `FF`, `SF`, `FS`, `TT`), temperature range (`-40°C` to `125°C`), and supply margins, alongside Monte Carlo mismatch simulations.
* **AC/Transient Characterization:** Propagation delays (`t_PLH`/`t_PHL`), rise/fall transition times (`10%–90%`), and dynamic tracking.
* **Power Characterization:** Static power dissipation across corners and dynamic switching energy.
* **Physical Verification:** DRC clean via **Magic** and **KLayout**, and LVS clean via **Netgen** against IHP SG13CMOS5L rules.

---

## 8. Repository Structure
```text
├── xschem/         # Schematic capture files and testbenches
├── sim/            # Ngspice simulation scripts and raw output data
├── layout/         # GDSII layout files (Magic / KLayout)
├── netlist/        # Extracted SPICE netlists for LVS/PEX
└── README.md       # Project documentation
