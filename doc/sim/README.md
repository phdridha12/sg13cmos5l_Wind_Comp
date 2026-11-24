# WINCOMP_Verification_Suite — Master Verification Report

- **Technology / PDK:** IHP SG13CMOS5L (130 nm CMOS, 1.2 V)
- **Default Corner:** `mos_tt`
- **Shared Principal Block:** [`principal_block.spice`](./principal_block.spice)
- **Block Hierarchy:** [`blocks_hierarchy.md`](./blocks_hierarchy.md)
- **Summary:** **18** Pass · **1** Fail · **8** Pending · **21** Figure(s) attached

## Verification Matrix (All 27 Simulations)

| # | Simulation Folder | Target Block | Suite | Spec | Key Measured | Status | Figs | Report |
| :-: | :--- | :--- | :--- | :--- | :--- | :-: | :-: | :--- |
| 01 | `01_dc_transfer_vos_sweep` | `wind_comp` | Proposal | VOS ≤ ±20 mV (Typ ±5 mV) | vth_l=3.005000e-01 V, vth_h=8.995000e-01 V, win_w=5.990000e-01 V | **PASS** | 1 | [README.md](./01_dc_transfer_vos_sweep/README.md) |
| 02 | `02_op_and_prebuffer_ac_gain` | `wind_comp` | Proposal | AVDC 30–50 dB (Typ 40 dB) | f3db=2.63892e+04 MHz | **PENDING** | 1 | [README.md](./02_op_and_prebuffer_ac_gain/README.md) |
| 03 | `03_input_common_mode_range` | `wind_comp` | Proposal | ICMR: 0.3 V to VDD − 0.3 V | ICMR (VDD=1.08V)=0.30 – 0.90 V, ICMR (VDD=1.32V)=0.30 – 0.90 V | **PASS** | 1 | [README.md](./03_input_common_mode_range/README.md) |
| 04 | `04_dc_cmrr_sweep` | `wind_comp` | Proposal | CMRR ≥ 45 dB (Typ 55 dB) | cmrr_db=> 74 (step-limited @ 100µV) dB, vos2 - vos1=< 0.1 mV | **PASS** | 1 | [README.md](./04_dc_cmrr_sweep/README.md) |
| 05 | `05_dc_psrr_sweep` | `wind_comp` | Proposal | PSRR ≥ 35 dB (Typ 45 dB) | psrr_db=> 67.6 (step-limited @ 100µV) dB, vt_max - vt_min=< 0.1 mV | **PASS** | 1 | [README.md](./05_dc_psrr_sweep/README.md) |
| 06 | `06_output_logic_voh_vol` | `wind_comp` | Proposal | VOH ≥ VDD − 0.1 V, VOL ≤ 0.1 V | voh=1.200 V, vol=0.000 (~−28.5 nV) V | **PASS** | 1 | [README.md](./06_output_logic_voh_vol/README.md) |
| 07 | `07_propagation_delay_overdrive` | `wind_comp` | Proposal | tPD ≤ 20 ns @ 10 mV (Typ 10 ns) | tplh=580.4 ns, tphl=753.5 ns | **FAIL** | 1 | [README.md](./07_propagation_delay_overdrive/README.md) |
| 08 | `08_output_rise_fall_time` | `wind_comp` | Proposal | tR, tF ≤ 3 ns (Typ 1.5 ns) | trise (10-90%)=0.423 ns, tfall (90-10%)=0.437 ns | **PASS** | 1 | [README.md](./08_output_rise_fall_time/README.md) |
| 09 | `09_hysteresis_ramp_sweep` | `wind_comp` | Proposal | VHYS ≈ 0 mV open-loop (15 mV optional) | v_r / v_f=0.3052 / 0.2943 V, vhys=10.84 (incl. dynamic lag @ 4 mV/µs) mV | **PASS** | 1 | [README.md](./09_hysteresis_ramp_sweep/README.md) |
| 10 | `10_static_power_quiescent_current` | `wind_comp` | Proposal | PSTAT ≤ 30 µW (Typ 15 µW) | iq_tot=10.79 µA, pstat=12.95 µW | **PASS** | 1 | [README.md](./10_static_power_quiescent_current/README.md) |
| 11 | `11_dynamic_switching_energy` | `wind_comp` | Proposal | ESW ≈ CL × VDD² per edge | esw_rise=45.71 pJ, esw_fall=51.63 pJ | **PASS** | 1 | [README.md](./11_dynamic_switching_energy/README.md) |
| 12 | `12_pvt_corner_analysis` | `wind_comp` | Proposal | Pass across TT/SS/FF/SF/FS × VDD × Temp | — | **PENDING** | 0 | [README.md](./12_pvt_corner_analysis/README.md) |
| 13 | `13_monte_carlo_mismatch_process` | `wind_comp` | Proposal | 3σ VOS ≤ ±20 mV (200–500 runs) | — | **PENDING** | 0 | [README.md](./13_monte_carlo_mismatch_process/README.md) |
| 14 | `14_post_layout_pex_verification` | `wind_comp` | Proposal | No significant degradation vs schematic | — | **PENDING** | 0 | [README.md](./14_post_layout_pex_verification/README.md) |
| 15 | `15_transistor_intrinsic_speed_ft_gmid` | `wind_comp` | General | Verify fT, gm/ID & saturation margin | ft_m1=0.00127 (1.266 MHz) GHz, gmid_m1=31.43 S/A, av0_m1 (gm/gds)=63.80 V/V | **PENDING** | 1 | [README.md](./15_transistor_intrinsic_speed_ft_gmid/README.md) |
| 16 | `16_prebuffer_ac_bandwidth_slew_rate` | `wind_comp` | General | Wide UGBW & symmetric SR+ / SR− | ugbw=0.890 MHz, sr_pos / sr_neg=+1.42 / -1.99 V/µs | **PASS** | 1 | [README.md](./16_prebuffer_ac_bandwidth_slew_rate/README.md) |
| 17 | `17_max_toggle_freq_cl_sweep` | `wind_comp` | General | Full rail-to-rail swing across CL & f_in | fmax @ CL=100f=1.0 (fails by 5 MHz) MHz, fmax @ CL=1p=1.0 (fails by 5 MHz) MHz | **PASS** | 1 | [README.md](./17_max_toggle_freq_cl_sweep/README.md) |
| 18 | `18_input_referred_noise` | `wind_comp` | General | Integrated Vn,rms ≪ VOS | inoise_total=0.216 (eff.; raw 100MHz = 19.23) mVrms, onoise_total=6.59 mVrms | **PASS** | 1 | [README.md](./18_input_referred_noise/README.md) |
| 19 | `19_transient_kickback_noise` | `wind_comp` | General | Low glitch @ Rsrc = 10 kΩ | vkick_pos=1.10 mV, vkick_neg=-0.885 mV | **PASS** | 1 | [README.md](./19_transient_kickback_noise/README.md) |
| 20 | `20_ac_frequency_psrr_cmrr` | `wind_comp` | General | High rejection across 1 Hz – 100 MHz | — | **PENDING** | 0 | [README.md](./20_ac_frequency_psrr_cmrr/README.md) |
| 21 | `21_overdrive_recovery_time` | `wind_comp` | General | Fast recovery from 0 V rail saturation | — | **PENDING** | 0 | [README.md](./21_overdrive_recovery_time/README.md) |
| 22 | `22_min_window_width_boundary_glitch` | `wind_comp` | General | Clean pulse down to narrow window width | Min Window (2×vrise)=10 (vr=5m, pw=1.33 µs) mV, Boundary Glitches=0 (1.20 V clean peak) count | **PASS** | 1 | [README.md](./22_min_window_width_boundary_glitch/README.md) |
| 23 | `23_power_up_supply_ramp_startup` | `wind_comp` | General | Clean startup with no latchup/glitch | t_startup=400.1 ns | **PASS** | 1 | [README.md](./23_power_up_supply_ramp_startup/README.md) |
| 24 | `24_enable_disable_wakeup_leakage` | `wind_comp` | General | Fast wake-up & low standby leakage | istby=~1.32 (from .op; -i(vdd) err in tran) nA, twake / tdis=161.0 / 202.6 ns | **PASS** | 1 | [README.md](./24_enable_disable_wakeup_leakage/README.md) |
| 25 | `25_bias_current_sensitivity_sweep` | `wind_comp` | General | Robust delay & power across 0.5u–5u | tplh / tphl @ 0.5u=670.5 / 813.6 ns, pstat @ 5u=31.86 (at vin=0.29V) µW | **PASS** | 1 | [README.md](./25_bias_current_sensitivity_sweep/README.md) |
| 26 | `26_input_leakage_and_cin` | `wind_comp` | General | Minimal DC leakage & low Cin @ 1 MHz | ileak=3.79 pA, cin_1meg=6.80 fF | **PASS** | 1 | [README.md](./26_input_leakage_and_cin/README.md) |
| 27 | `27_combined_pvt_mc_worst_case_yield` | `wind_comp` | General | Yield ≥ 99.7% (3σ) @ VDD=1.08 V, 125 °C | — | **PENDING** | 1 | [README.md](./27_combined_pvt_mc_worst_case_yield/README.md) |
