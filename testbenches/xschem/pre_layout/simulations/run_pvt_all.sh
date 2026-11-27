#!/usr/bin/env bash==============================================================================Full 45-Corner PVT Runner for WINCOMP (IHP SG13CMOS5L / Xschem + ngspice)Sweeps: 5 Process (mos_tt, mos_ss, mos_ff, mos_sf, mos_fs)x 3 Supply  (1.08 V, 1.20 V, 1.32 V)x 3 Temp    (-40 C, 27 C, 125 C)==============================================================================set -euo pipefail1. Locate Xschem-generated netlist (defaults to ./wind_comp_tb.spice)NETLIST="${1:-./wind_comp_tb.spice}"
if [[ ! -f "$NETLIST" && -f "./wind_comp_tb.spice" ]]; then
echo "[i] '$NETLIST' not found; using ./wind_comp_tb.spice"
NETLIST="./wind_comp_tb.spice"
fiif [[ ! -f "$NETLIST" ]]; then
echo "ERROR: Netlist not found at: $NETLIST"
echo "Usage: ./run_pvt_all.sh ./wind_comp_tb.spice"
exit 1
fiVerify that the netlist contains an IHP MOS corner .lib directiveif ! grep -qiE '^[[:space:]]*.lib[[:space:]].*mos_(tt_stat|tt|ss|ff|sf|fs)' "$NETLIST"; then
echo "ERROR: Could not find a '.lib ... mos_tt' (or ss/ff/sf/fs) line in $NETLIST"
grep -in '.lib' "$NETLIST" || true
exit 1
fi2. Output paths (saved inside ./pvt_full_results/)OUT_DIR="$(pwd)/pvt_full_results"
PLOT_DIR="$OUT_DIR/plots"
LOG_DIR="$OUT_DIR/logs"
SUMMARY_FILE="$OUT_DIR/pvt_all_45.txt"mkdir -p "$PLOT_DIR" "$LOG_DIR"
: > "$SUMMARY_FILE"All 5 IHP SG13CMOS5L transistor speed cornersCORNERS=("mos_tt" "mos_ss" "mos_ff" "mos_sf" "mos_fs")echo ""
echo " Running Full 45-Corner PVT Sweep"
echo " Netlist : $NETLIST"
echo " Output  : $SUMMARY_FILE"
echo ""3. Loop through each process corner and run ngspice in batch modefor CORNER in "${CORNERS[@]}"; do
TMP_SPICE="$OUT_DIR/tmp_${CORNER}.spice"
CORNER_LOG="$LOG_DIR/pvt_${CORNER}.log"echo "[*] Running corner: $CORNER (9 V x T points)..."awk -v corner="$CORNER" -v outfile="$SUMMARY_FILE" -v plotdir="$PLOT_DIR" '
{
low = tolower($0)
if (low ~ /^[[:space:]]*\.lib[[:space:]]/) {
gsub(/mos_(tt_stat|tt|ss|ff|sf|fs)/, corner)
}
if (low ~ /^[[:space:]]*echo[[:space:]]+\$vv[[:space:]]+\$tt/) {
sub(/^[[:space:]]*echo[[:space:]]+/, "    echo " corner " ")
sub(/>>.*$/, ">> " outfile)
}
if (low ~ /^[[:space:]]*hardcopy[[:space:]]+/) {
sub(/[Hh][Aa][Rr][Dd][Cc][Oo][Pp][Yy][[:space:]]+[^[:space:]]+/, "hardcopy " plotdir "/pvt_" corner ".svg")
}
if (low ~ /^[[:space:]]*plot[[:space:]]+/) {
next
}
print
}
' "$NETLIST" > "$TMP_SPICE"ngspice -b "$TMP_SPICE" > "$CORNER_LOG" 2>&1 || {
echo "    [!] ngspice returned non-zero for $CORNER — check$CORNER_LOG"
}
done4. Print formatted 45-corner table + worst-case summaryecho ""
echo "============================================================================"
printf "%-8s | %-6s | %-6s | %-12s | %-12s | %-12s\n" "CORNER" "VDD(V)" "T(C)" "VOS_L(mV)" "VOS_H(mV)" "PSTAT(uW)"
echo "----------------------------------------------------------------------------"awk '
NF >= 6 {
c = $1; vdd = $2; temp = $3
vos_l_mv = $4 * 1000.0
vos_h_mv = $5 * 1000.0
pstat_uw = $6 * 1e6
printf "%-8s | %-6s | %-6s | %12.3f | %12.3f | %12.3f\n", c, vdd, temp, vos_l_mv, vos_h_mv, pstat_uwabs_l = (vos_l_mv < 0 ? -vos_l_mv : vos_l_mv)
abs_h = (vos_h_mv < 0 ? -vos_h_mv : vos_h_mv)
cur_vos = (abs_l > abs_h ? abs_l : abs_h)

if (count == 0 || cur_vos > max_vos) {
  max_vos = cur_vos
  max_vos_tag = c " / " vdd "V / " temp "C"
}
if (count == 0 || pstat_uw > max_pstat) {
  max_pstat = pstat_uw
  max_pstat_tag = c " / " vdd "V / " temp "C"
}
count++
}
END {
print "============================================================================"
printf " Total corners collected : %d / 45\n", count
if (count > 0) {
printf " Worst-case |VOS|        : %.3f mV  (%s)  [Spec <= 20 mV]\n", max_vos, max_vos_tag
printf " Worst-case PSTAT        : %.3f uW  (%s)  [Spec <= 30 uW]\n", max_pstat, max_pstat_tag
}
}
' "$SUMMARY_FILE"echo ""
echo "Saved raw data : $SUMMARY_FILE"
echo "Saved SVG plots: $PLOT_DIR/pvt_.svg"
echo "Saved logs     : $LOG_DIR/pvt_.log"
