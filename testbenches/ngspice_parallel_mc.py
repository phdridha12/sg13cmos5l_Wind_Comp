import os
import subprocess
from multiprocessing import Pool
import re
import csv
import numpy as np
import time
from datetime import datetime
import sys
import argparse
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import math
import operator
import random
import itertools
from collections import Counter

# begin/end tags
results_begin_tag = "results_save_begin"
results_end_tag = "results_save_end"
plot_begin_tag = "**results_plot_begin"
plot_end_tag = "**results_plot_end"
status_columns_suffix = "status"
pass_string = "PASSED"
fail_string = "FAILED"
_failure_reason_col_global = None

simulations_dir = "./simulations"

DEFAULT_MAX_FAILURES = 50  # per-task failure limit to break retry loop

LIB_LINE_PATTERN = re.compile(
    r'^([ \t]*\.lib[ \t]+(?:"[^"]+"|\'[^\']+\'|\S+)[ \t]+)([^\s;*]+)(.*)$',
    re.MULTILINE | re.IGNORECASE,
)

SI_PREFIXES = {
    -18: "a",
    -15: "f",
    -12: "p",
    -9: "n",
    -6: "µ",
    -3: "m",
    0: "",
    3: "k",
    6: "M",
    9: "G",
    12: "T",
    15: "P",
}

SI_PARSE_MULTIPLIERS = {
    "a": 1e-18,
    "f": 1e-15,
    "p": 1e-12,
    "n": 1e-9,
    "u": 1e-6,
    "µ": 1e-6,
    "m": 1e-3,
    "k": 1e3,
    "K": 1e3,
    "meg": 1e6,
    "MEG": 1e6,
    "M": 1e6,
    "g": 1e9,
    "G": 1e9,
    "t": 1e12,
    "T": 1e12,
}

FILTER_OPERATORS = {
    "<=": operator.le,
    ">=": operator.ge,
    "!=": operator.ne,
    "==": operator.eq,
    "<": operator.lt,
    ">": operator.gt,
}


def is_status_column(col_name: str) -> bool:
    return col_name.endswith(f"_{status_columns_suffix}")


def get_si_scale(val: float) -> tuple[float, str, int]:
    """Return (scale_factor, si_prefix, exponent) for a numeric magnitude."""
    abs_val = abs(val)
    if abs_val == 0 or not math.isfinite(abs_val):
        return 1.0, "", 0
    exp = int(math.floor(math.log10(abs_val) / 3.0) * 3)
    exp = max(min(SI_PREFIXES), min(max(SI_PREFIXES), exp))
    return 10.0 ** exp, SI_PREFIXES[exp], exp


def format_si(val: float, unit: str = "") -> str:
    """Format a float using SI prefixes without scientific notation."""
    if not math.isfinite(val):
        return str(val)
    if val == 0:
        return f"0 {unit}".strip()

    scale, prefix, exp = get_si_scale(val)
    scaled = val / scale
    abs_scaled = abs(scaled)

    if abs_scaled >= 100:
        decimals = 1
    elif abs_scaled >= 10:
        decimals = 2
    else:
        decimals = 3

    # Handle rounding rollover (e.g., 999.96 k -> 1 M)
    if round(abs_scaled, decimals) >= 1000 and (exp + 3) in SI_PREFIXES:
        exp += 3
        scale = 10.0 ** exp
        prefix = SI_PREFIXES[exp]
        scaled = val / scale
        decimals = 3

    num_str = f"{scaled:.{decimals}f}".rstrip("0").rstrip(".")
    if num_str == "-0":
        num_str = "0"

    suffix = f"{prefix}{unit}"
    return f"{num_str} {suffix}" if suffix else num_str


def parse_spice_float(val_str: str) -> float:
    """Parse a float with optional SI/SPICE suffix (e.g., 8, -5m, 100u, 1M, 2meg, 1e-3)."""
    s = val_str.strip()
    m = re.match(r"^([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)\s*([a-zA-Zµ]*)$", s)
    if not m:
        raise ValueError(f"Invalid numeric threshold: {val_str!r}")
    num = float(m.group(1))
    suffix = m.group(2)
    if not suffix:
        return num
    if suffix in SI_PARSE_MULTIPLIERS:
        return num * SI_PARSE_MULTIPLIERS[suffix]
    if suffix.lower() in SI_PARSE_MULTIPLIERS:
        return num * SI_PARSE_MULTIPLIERS[suffix.lower()]
    raise ValueError(f"Unknown SI suffix {suffix!r} in threshold {val_str!r}")


def parse_plot_line(line: str):
    """
    Parse a line inside **results_plot_begin ... **results_plot_end.
    Supported examples:
      **dc_gain
      **dc_gain [dB]
      **dc_gain,<8
      **dc_gain [dB], <8
      **dc_gain,<8 [dB]
      **vcm_calc [V], <0.5, >1.3
    Returns (var_name, unit, rules) where rules is [(op_str, threshold_float), ...].
    """
    entry = re.sub(r"^\s*\*\*", "", line).strip()
    if not entry:
        return None

    unit = ""
    trailing_unit = re.search(r"\s+\[([^\]]+)\]\s*$", entry)
    if trailing_unit:
        unit = trailing_unit.group(1).strip()
        entry = entry[:trailing_unit.start()].strip()

    parts = [p.strip() for p in entry.split(",") if p.strip()]
    if not parts:
        return None

    var_name = parts[0]
    if not unit:
        m_space = re.match(r"^(.*?)\s+\[([^\]]+)\]\s*$", var_name)
        if m_space:
            var_name = m_space.group(1).strip()
            unit = m_space.group(2).strip()
        elif not var_name.startswith("@"):
            m_tight = re.match(r"^([^\[\]]+)\[([^\]]+)\]$", var_name)
            if m_tight:
                var_name = m_tight.group(1).strip()
                unit = m_tight.group(2).strip()

    rules = []
    for cond in parts[1:]:
        cond_match = re.match(r"^(<=|>=|!=|==|<|>)\s*(.+)$", cond)
        if not cond_match:
            raise ValueError(f"Invalid filter condition {cond!r} on line {line!r}")
        rules.append((cond_match.group(1), parse_spice_float(cond_match.group(2))))

    return var_name, unit, rules


def parse_plot_config(netlist_text: str) -> tuple[list[tuple[str, str]], dict]:
    """Parse **results_plot_begin ... **results_plot_end block from netlist."""
    pattern = re.compile(
        rf"{re.escape(plot_begin_tag)}(.*?){re.escape(plot_end_tag)}",
        re.DOTALL,
    )
    match = pattern.search(netlist_text)
    results_plot_list = []
    filter_rules = {}
    if match:
        block = match.group(1)
        for line in block.strip().splitlines():
            parsed = parse_plot_line(line)
            if not parsed:
                continue
            var_name, unit, rules = parsed
            results_plot_list.append((var_name, unit))
            if rules:
                filter_rules.setdefault(var_name, []).extend(rules)
    return results_plot_list, filter_rules


def check_reject_rules(result: dict, filter_rules: dict) -> str | None:
    """Populate per-parameter *_status entries and return failure/skip reason string, else None."""
    ret_value = []
    if not filter_rules:
        return None

    lower_map = {k.lower(): v for k, v in result.items()}
    for var_name, rules in filter_rules.items():
        if is_status_column(var_name):
            continue
        if var_name in result:
            val = result[var_name]
        elif var_name.lower() in lower_map:
            val = lower_map[var_name.lower()]
        else:
            return f"{var_name} missing; skip-not"

        if val is None or not math.isfinite(val):
            return f"{var_name} non-finite; skip-not"

        status_col = f"{var_name}_{status_columns_suffix}"
        result[status_col] = pass_string
        for op_str, thresh in rules:
            if FILTER_OPERATORS[op_str](val, thresh):
                result[status_col] = fail_string
                ret_value.append(f"{var_name} = {val} {op_str} {thresh:g} {fail_string}")
                break

    return " | ".join(ret_value) if ret_value else None


def parse_csv_tokens(raw_str: str) -> list[str]:
    return [tok.strip() for tok in raw_str.split(",") if tok.strip()]


def detect_default_process(netlist_text: str) -> str:
    m = LIB_LINE_PATTERN.search(netlist_text)
    return m.group(2).strip() if m else "nominal"


def detect_default_temp(netlist_text: str) -> str:
    m = re.search(r"^[ \t]*\.temp[ \t]+(\S+)", netlist_text, re.MULTILINE | re.IGNORECASE)
    if m:
        return m.group(1).strip()
    m = re.search(r"^[ \t]*\.options?\b[^\r\n]*\btemp\s*=\s*(\S+)", netlist_text, re.MULTILINE | re.IGNORECASE)
    if m:
        return m.group(1).strip()
    return "27"


def detect_default_vdd(netlist_text: str) -> str:
    for pm in re.finditer(
        r"^[ \t]*\.param\b[^\r\n]*(?:\r?\n[ \t]*\+[^\r\n]*)*",
        netlist_text,
        re.MULTILINE | re.IGNORECASE,
    ):
        vm = re.search(r"\bvdd\s*=\s*(\{[^}]*\}|\S+)", pm.group(0), re.IGNORECASE)
        if vm:
            return vm.group(1).strip()
    sm = re.search(
        r"^[ \t]*vdd[ \t]+\S+[ \t]+\S+[ \t]+(?:dc[ \t]+)?(\{[^}]*\}|\S+)",
        netlist_text,
        re.MULTILINE | re.IGNORECASE,
    )
    if sm:
        return sm.group(1).strip()
    return "nominal"


def parse_pvt_config(netlist_text: str) -> tuple[list[dict], list[str], bool]:
    """
    Parse optional PVT directives from netlist comments:
      **pvt_process = tt, ff, ss, sf, fs
      (or multiple **pvt_process lines for multi-lib PDKs like IHP:)
      **pvt_process = mos_tt_mismatch, mos_ff_mismatch
      **pvt_process = res_wc_mismatch, res_typ_mismatch
      **pvt_temp    = -40, 27, 125
      **pvt_vdd     = 1.62, 1.8, 1.98
      **pvt_param cl = 0.1p, 0.5p
      **pvt_param ibias = 2u, 2.5u, 3u
    Returns (pvt_combos, extra_param_names, pvt_enabled).
    """
    pvt_enabled = False

    process_groups: list[list[str]] = []
    for m_proc in re.finditer(
        r"^[ \t]*\*\*pvt_process[ \t]*=[ \t]*(.+)$",
        netlist_text,
        re.MULTILINE | re.IGNORECASE,
    ):
        tokens = parse_csv_tokens(m_proc.group(1))
        if tokens:
            process_groups.append(tokens)
            pvt_enabled = True

    process_product = list(itertools.product(*process_groups)) if process_groups else [None]

    m_temp = re.search(r"^[ \t]*\*\*pvt_temp[ \t]*=[ \t]*(.+)$", netlist_text, re.MULTILINE | re.IGNORECASE)
    if m_temp:
        temps = parse_csv_tokens(m_temp.group(1))
        pvt_enabled = True
    else:
        temps = [None]

    m_vdd = re.search(r"^[ \t]*\*\*pvt_vdd[ \t]*=[ \t]*(.+)$", netlist_text, re.MULTILINE | re.IGNORECASE)
    if m_vdd:
        vdds = parse_csv_tokens(m_vdd.group(1))
        pvt_enabled = True
    else:
        vdds = [None]

    extra_params: dict[str, list[str]] = {}
    for mp in re.finditer(
        r"^[ \t]*\*\*pvt_param[ \t]+([A-Za-z_][A-Za-z0-9_]*)[ \t]*=[ \t]*(.+)$",
        netlist_text,
        re.MULTILINE | re.IGNORECASE,
    ):
        pname = mp.group(1).strip()
        pvals = parse_csv_tokens(mp.group(2))
        if pvals:
            extra_params[pname] = pvals
            pvt_enabled = True

    default_proc = detect_default_process(netlist_text)
    default_temp = detect_default_temp(netlist_text)
    default_vdd = detect_default_vdd(netlist_text)

    extra_names = list(extra_params.keys())
    extra_product = list(itertools.product(*(extra_params[k] for k in extra_names))) if extra_names else [()]

    combos = []
    for proc_tuple, temp, vdd, extras in itertools.product(process_product, temps, vdds, extra_product):
        extra_dict = dict(zip(extra_names, extras))
        proc_list = list(proc_tuple) if proc_tuple is not None else None
        proc_disp = "+".join(proc_list) if proc_list is not None else default_proc
        temp_disp = temp if temp is not None else default_temp
        vdd_disp = vdd if vdd is not None else default_vdd

        label_parts = [proc_disp, f"{temp_disp}C"]
        if vdd is not None or default_vdd != "nominal":
            label_parts.append(f"{vdd_disp}V" if not str(vdd_disp).lower().endswith("v") else str(vdd_disp))
        for k, v in extra_dict.items():
            label_parts.append(f"{k}={v}")

        label = "_".join(label_parts)
        safe_id = re.sub(r"[^A-Za-z0-9_.-]+", "_", label)
        combos.append({
            "label": label,
            "safe_id": safe_id,
            "process": proc_list,
            "process_disp": proc_disp,
            "temp": temp,
            "temp_disp": temp_disp,
            "vdd": vdd,
            "vdd_disp": vdd_disp,
            "extra_params": extra_dict,
        })

    return combos, extra_names, pvt_enabled


def corners_share_prefix(target_corner: str, existing_corner: str) -> bool:
    """
    Return True if target_corner shares the same leading corner prefix as existing_corner.
      - mos_ff_mismatch vs mos_tt     -> True  (both start with 'mos_')
      - res_wc_mismatch vs res_typ    -> True  (both start with 'res_')
      - tt_mm           vs tt         -> True  (token 'tt' matches 'tt')
      - mosff           vs mostt      -> True  (undelimited common prefix len >= 3)
      - ff_mm           vs fast_cell  -> False ('ff' != 'fast')
      - res_wc          vs ref_typ    -> False ('res' != 'ref')
    """
    t = target_corner.strip().lower()
    e = existing_corner.strip().lower()
    if not t or not e:
        return False
    if t == e:
        return True

    t_parts = re.split(r"[_-]", t, maxsplit=1)
    e_parts = re.split(r"[_-]", e, maxsplit=1)
    if len(t_parts) > 1 or len(e_parts) > 1:
        return bool(t_parts[0]) and t_parts[0] == e_parts[0]

    return len(os.path.commonprefix([t, e])) >= 3


def patch_process_corners(netlist_text: str, corners: str | list[str]) -> tuple[str, list[str]]:
    """
    Patch one or more process corners into the netlist's .lib statements:
      - If only 1 .lib exists, patch it directly.
      - If multiple .lib statements exist, for each corner update all .lib lines whose
        existing corner shares the same starting prefix; if none match, update the first .lib.
    Returns (patched_netlist, warnings).
    """
    if isinstance(corners, str):
        corner_list = [corners]
    elif corners:
        corner_list = [c for c in corners if c]
    else:
        return netlist_text, []

    if not corner_list:
        return netlist_text, []

    matches = list(LIB_LINE_PATTERN.finditer(netlist_text))
    if not matches:
        return netlist_text, [
            f"No .lib line found to apply process corner(s) {', '.join(corner_list)}"
        ]

    original_corners = [m.group(2) for m in matches]
    replacements: dict[int, str] = {}
    warnings: list[str] = []

    for corner in corner_list:
        if len(matches) == 1:
            target_indices = [0]
        else:
            target_indices = [
                idx for idx, orig in enumerate(original_corners)
                if corners_share_prefix(corner, orig)
            ]
            if not target_indices:
                target_indices = [0]
                if 0 in replacements:
                    warnings.append(
                        f"Process corner '{corner}' matched no .lib prefix; "
                        f"falling back to first .lib (overwriting '{replacements[0]}')"
                    )

        for idx in target_indices:
            replacements[idx] = corner

    out_parts = []
    last_end = 0
    for idx, m in enumerate(matches):
        out_parts.append(netlist_text[last_end:m.start()])
        if idx in replacements:
            out_parts.append(f"{m.group(1)}{replacements[idx]}{m.group(3)}")
        else:
            out_parts.append(m.group(0))
        last_end = m.end()
    out_parts.append(netlist_text[last_end:])

    return "".join(out_parts), warnings


def patch_temperature(netlist_text: str, temp_str: str) -> str:
    patched = re.sub(
        r"^[ \t]*\.temp\b[^\r\n]*\r?\n?",
        "",
        netlist_text,
        flags=re.MULTILINE | re.IGNORECASE,
    )

    def strip_opt_temp(m):
        return re.sub(r"\btemp\s*=\s*\S+", "", m.group(0), flags=re.IGNORECASE)

    patched = re.sub(
        r"^[ \t]*\.options?\b[^\r\n]*$",
        strip_opt_temp,
        patched,
        flags=re.MULTILINE | re.IGNORECASE,
    )

    ctrl_m = re.search(r"^[ \t]*\.control\b", patched, re.MULTILINE | re.IGNORECASE)
    if ctrl_m:
        return patched[:ctrl_m.start()] + f".temp {temp_str}\n" + patched[ctrl_m.start():]
    end_m = re.search(r"^[ \t]*\.end\b", patched, re.MULTILINE | re.IGNORECASE)
    if end_m:
        return patched[:end_m.start()] + f".temp {temp_str}\n" + patched[end_m.start():]
    return patched + f"\n.temp {temp_str}\n"


def patch_param_or_source(netlist_text: str, name: str, val_str: str, allow_add_param: bool = True) -> tuple[str, str]:
    """
    Update a .param assignment (supports + continuations) or an independent V/I source named `name`.
    Returns (patched_netlist, mode_used).
    """
    param_found = False

    def replace_in_param(m):
        nonlocal param_found
        block = m.group(0)
        new_block, cnt = re.subn(
            rf"(\b{re.escape(name)}\s*=\s*)(\{{[^}}]*\}}|\S+)",
            lambda mm: mm.group(1) + val_str,
            block,
            flags=re.IGNORECASE,
        )
        if cnt > 0:
            param_found = True
        return new_block

    patched = re.sub(
        r"^[ \t]*\.param\b[^\r\n]*(?:\r?\n[ \t]*\+[^\r\n]*)*",
        replace_in_param,
        netlist_text,
        flags=re.MULTILINE | re.IGNORECASE,
    )
    if param_found:
        return patched, "param"

    src_pattern = re.compile(
        rf"^([ \t]*{re.escape(name)}[ \t]+\S+[ \t]+\S+[ \t]+)(.*)$",
        re.MULTILINE | re.IGNORECASE,
    )
    src_m = src_pattern.search(netlist_text)
    if src_m and name[0].lower() in ("v", "i"):
        prefix, rest = src_m.group(1), src_m.group(2)
        dc_m = re.search(r"(\bdc[ \t]+)(\{[^}]*\}|\S+)", rest, re.IGNORECASE)
        if dc_m:
            new_rest = rest[:dc_m.start(2)] + val_str + rest[dc_m.end(2):]
        else:
            first_m = re.match(r"^(\{[^}]*\}|\S+)(.*)$", rest.strip())
            if first_m and first_m.group(1).lower() not in ("ac", "pulse", "sin", "pwl", "exp", "sffm"):
                new_rest = val_str + first_m.group(2)
            else:
                new_rest = f"dc {val_str} " + rest
        patched = netlist_text[:src_m.start()] + prefix + new_rest + netlist_text[src_m.end():]
        return patched, "source"

    if allow_add_param:
        ctrl_m = re.search(r"^[ \t]*\.control\b", netlist_text, re.MULTILINE | re.IGNORECASE)
        insert_pos = ctrl_m.start() if ctrl_m else len(netlist_text)
        patched = netlist_text[:insert_pos] + f".param {name}={val_str}\n" + netlist_text[insert_pos:]
        return patched, "added_param"

    return netlist_text, "not_found"


def apply_pvt_to_netlist(base_netlist: str, pvt_cfg: dict) -> tuple[str, list[str]]:
    """Apply process, temperature, vdd, and extra_params overrides to a copy of the netlist."""
    patched = base_netlist
    warnings = []

    if pvt_cfg["process"] is not None:
        patched, proc_warnings = patch_process_corners(patched, pvt_cfg["process"])
        warnings.extend(proc_warnings)

    if pvt_cfg["temp"] is not None:
        patched = patch_temperature(patched, pvt_cfg["temp"])

    if pvt_cfg["vdd"] is not None:
        patched, mode = patch_param_or_source(patched, "vdd", pvt_cfg["vdd"], allow_add_param=False)
        if mode == "not_found":
            warnings.append(
                f"Could not find '.param vdd=...' or 'VDD <n+> <n-> <val>' source for pvt_vdd={pvt_cfg['vdd']}"
            )

    for pname, pval in pvt_cfg["extra_params"].items():
        patched, _ = patch_param_or_source(patched, pname, pval, allow_add_param=True)

    return patched, warnings


def chunk_counts(total: int, n_chunks: int) -> list[int]:
    """Split `total` runs as evenly as possible into `n_chunks` non-zero counts."""
    n_chunks = max(1, min(total, n_chunks))
    base, rem = divmod(total, n_chunks)
    return [base + (1 if i < rem else 0) for i in range(n_chunks)]


def is_valid_param_name(name: str) -> bool:
    """Rejects ngspice control commands (e.g., 'let x', 'meas ac ...') while allowing SPICE vars."""
    if not name:
        return False
    outside_brackets = re.sub(r"\([^)]*\)|\[[^\]]*\]", "", name)
    return not re.search(r"\s", outside_brackets)


def build_worker_netlist(base_netlist: str, num_runs: int, seed: int) -> tuple[str, str]:
    """Wraps the .control block containing results_save_begin in a native ngspice repeat loop."""
    ctrl_pattern = re.compile(
        rf"(\.control\b)((?:(?!\.endc\b).)*?{re.escape(results_begin_tag)}.*?)(\.endc\b)",
        re.IGNORECASE | re.DOTALL,
    )
    match = ctrl_pattern.search(base_netlist)
    if not match:
        raise ValueError(
            f"No '.control ... .endc' block containing '{results_begin_tag}' found in the netlist. "
            "A .control block is required to loop Monte Carlo / PVT runs inside ngspice."
        )

    ctrl_body = match.group(2)
    ctrl_body = re.sub(
        r"^[ \t]*(?:quit|exit)(?:[ \t]+\d+)?[ \t]*\r?\n?",
        "",
        ctrl_body,
        flags=re.MULTILINE | re.IGNORECASE,
    )

    looped_control = (
        f"{match.group(1)}\n"
        f"set num_threads=1\n"
        f"setseed {seed}\n"
        f"repeat {num_runs}\n"
        f"    reset\n"
        f"{ctrl_body.strip()}\n"
        f"    destroy all\n"
        f"end\n"
        f"quit\n"
        f"{match.group(3)}"
    )

    full_netlist = base_netlist[:match.start()] + looped_control + base_netlist[match.end():]
    return full_netlist, looped_control


def run_worker(args):
    (
        task_id,
        target_runs,
        base_seed,
        base_netlist,
        netlist_name,
        run_results_dir,
        pvt_cfg,
        worker_filter_rules,
        worker_max_failures,
    ) = args

    rng = random.Random(base_seed + task_id * 1000003)
    pvt_label = pvt_cfg["label"]
    pvt_safe = pvt_cfg["safe_id"]

    worker_netlist_file = os.path.join(run_results_dir, f"../../{netlist_name}_{pvt_safe}_task_{task_id}.spice")
    result_file = os.path.join(run_results_dir, f"{netlist_name}_{pvt_safe}_task_{task_id}_results.txt")
    worker_debug_file = os.path.join(run_results_dir, f"{netlist_name}_{pvt_safe}_task_{task_id}_ngspice_error.log")

    block_pattern = re.compile(
        rf"^[ \t]*{re.escape(results_begin_tag)}[ \t]*\r?\n(.*?)^[ \t]*{re.escape(results_end_tag)}[ \t]*$",
        re.DOTALL | re.MULTILINE,
    )

    pvt_netlist, pvt_warnings = apply_pvt_to_netlist(base_netlist, pvt_cfg)

    parse_errors = [f"Task {task_id} ({pvt_label}) | Warning: {w}" for w in pvt_warnings]
    last_ngspice_output = ""
    last_looped_control = ""
    last_seed = 0
    worker_has_error = bool(pvt_warnings)
    valid_rows = []
    fieldnames = []
    fail_count = 0
    skip_reasons = Counter()
    batch_nr = 0
    prev_rejected_sig = None

    try:
        while len(valid_rows) < target_runs and fail_count < worker_max_failures:
            needed = target_runs - len(valid_rows)
            batch_nr += 1
            last_seed = rng.randint(1, 2147483646)

            worker_netlist_content, last_looped_control = build_worker_netlist(
                pvt_netlist, needed, last_seed
            )
            with open(worker_netlist_file, "w+") as wf:
                wf.write(worker_netlist_content)

            try:
                last_ngspice_output = subprocess.check_output(
                    ["ngspice", "-b", worker_netlist_file],
                    stderr=subprocess.STDOUT,
                    text=True,
                )
            except subprocess.CalledProcessError as e:
                last_ngspice_output = e.output or ""
                worker_has_error = True
                msg = (
                    f"Task {task_id} ({pvt_label}) | Batch {batch_nr} | ngspice exited with code {e.returncode} "
                    f"(full output saved to {worker_debug_file})"
                )
                print(f"Error: {msg}")
                parse_errors.append(msg)

            blocks = block_pattern.findall(last_ngspice_output)

            if len(blocks) < needed:
                missing = needed - len(blocks)
                fail_count += missing
                skip_reasons["missing_block"] += missing
                worker_has_error = True
                msg = (
                    f"Task {task_id} ({pvt_label}) | Batch {batch_nr} | Expected {needed} result blocks, "
                    f"got {len(blocks)} (full output saved to {worker_debug_file})"
                )
                print(f"Warning: {msg}")
                parse_errors.append(msg)

            deterministic_repeat_abort = False
            for idx, block in enumerate(blocks):
                if len(valid_rows) >= target_runs or fail_count >= worker_max_failures:
                    break

                result = {}
                block_parse_failed = False
                for line in block.strip().splitlines():
                    if "=" not in line:
                        continue
                    result_name, result_value = line.split("=", 1)
                    name_clean = result_name.strip()
                    val_clean = result_value.strip()

                    if not is_valid_param_name(name_clean):
                        worker_has_error = True
                        msg = (
                            f"Task {task_id} ({pvt_label}) | Batch {batch_nr} Run {idx} | "
                            f"Ignored non-parameter/control line: {line.strip()!r}"
                        )
                        parse_errors.append(msg)
                        continue

                    try:
                        val_float = float(val_clean)
                        if not math.isfinite(val_float):
                            raise ValueError("non-finite float")
                        result[name_clean] = val_float
                    except ValueError as e:
                        worker_has_error = True
                        block_parse_failed = True
                        msg = (
                            f"Task {task_id} ({pvt_label}) | Batch {batch_nr} Run {idx} | "
                            f"Var '{name_clean}' | Raw value: {val_clean!r} | Error: {e}"
                        )
                        parse_errors.append(msg)

                if block_parse_failed or not result:
                    fail_count += 1
                    skip_reasons["parse_or_nan_error"] += 1
                    continue

                reject_reason = check_reject_rules(result, worker_filter_rules)
                if worker_filter_rules:
                    result[f"row_{status_columns_suffix}"] = pass_string
                    result[f"failure_reason_{status_columns_suffix}"] = "\\(.__.)/"
                if reject_reason and reject_reason.endswith("skip"):
                    fail_count += 1
                    skip_reasons[reject_reason] += 1
                    if target_runs == 1:
                        sig = tuple(sorted(result.items()))
                        if prev_rejected_sig == sig:
                            deterministic_repeat_abort = True
                            worker_has_error = True
                            msg = (
                                f"Task {task_id} ({pvt_label}) | Deterministic rejection repeated "
                                f"({reject_reason}); stopping retries for this corner."
                            )
                            print(f"Warning: {msg}")
                            parse_errors.append(msg)
                            break
                        prev_rejected_sig = sig
                    continue
                elif reject_reason:
                    result[f"row_{status_columns_suffix}"] = fail_string
                    result[f"failure_reason_{status_columns_suffix}"] = reject_reason

                row_with_meta = {
                    "pvt_corner": pvt_label,
                    "process": pvt_cfg["process_disp"],
                    "temp": pvt_cfg["temp_disp"],
                    "vdd": pvt_cfg["vdd_disp"],
                }
                for ek, ev in pvt_cfg["extra_params"].items():
                    row_with_meta[ek] = ev
                row_with_meta.update(result)

                for k in row_with_meta:
                    if k not in fieldnames:
                        fieldnames.append(k)
                valid_rows.append(row_with_meta)

            if deterministic_repeat_abort:
                break

        if len(valid_rows) < target_runs and fail_count >= worker_max_failures:
            worker_has_error = True
            msg = (
                f"Task {task_id} ({pvt_label}) | Stopped early: reached max_failures={worker_max_failures} "
                f"with {len(valid_rows)}/{target_runs} valid runs collected."
            )
            print(f"Warning: {msg}")
            parse_errors.append(msg)

        if valid_rows and fieldnames:
            with open(result_file, "w", newline="") as results:
                writer = csv.DictWriter(results, fieldnames=fieldnames, delimiter=";", restval="0.0")
                writer.writeheader()
                writer.writerows(valid_rows)

        if worker_has_error:
            with open(worker_debug_file, "w") as dbg_f:
                dbg_f.write(
                    f"=== Task {task_id} ({pvt_label}) Debug Log "
                    f"(Last Seed: {last_seed}, Valid: {len(valid_rows)}/{target_runs}, Skipped: {fail_count}) ===\n"
                )
                dbg_f.write("Skip breakdown:\n")
                dbg_f.writelines(f"  - {reason}: {cnt}\n" for reason, cnt in skip_reasons.items())
                dbg_f.write("Detected errors/warnings:\n")
                dbg_f.writelines(f"  - {err}\n" for err in parse_errors)
                dbg_f.write("\n=== Last Generated .control Block ===\n")
                dbg_f.write(last_looped_control + "\n")
                dbg_f.write("\n=== Last Full ngspice Output ===\n")
                dbg_f.write(last_ngspice_output if last_ngspice_output else "<No output captured>\n")

    finally:
        if os.path.exists(worker_netlist_file):
            os.remove(worker_netlist_file)

    return pvt_label, result_file, parse_errors, fail_count, dict(skip_reasons)


def find_latest_results_dir(results_root: str, netlist_name: str) -> tuple[str, str]:
    """
    Locate the latest timestamped results folder for `netlist_name` containing
    `<netlist_name>_mc_results.csv`.
    Returns (run_results_dir, csv_path).
    """
    if not os.path.isdir(results_root):
        raise FileNotFoundError(f"Results directory not found: {results_root}")

    ts_pattern = re.compile(
        rf"^{re.escape(netlist_name)}_(\d{{4}}-\d{{2}}-\d{{2}}_\d{{2}}-\d{{2}}-\d{{2}})$"
    )
    candidates = []
    for entry in os.listdir(results_root):
        full_path = os.path.join(results_root, entry)
        if not os.path.isdir(full_path):
            continue
        m = ts_pattern.match(entry)
        if not m:
            continue
        csv_path = os.path.join(full_path, f"{netlist_name}_mc_results.csv")
        if os.path.isfile(csv_path):
            candidates.append((m.group(1), full_path, csv_path))

    if not candidates:
        raise FileNotFoundError(
            f"No completed results folder with '{netlist_name}_mc_results.csv' found in {results_root}"
        )

    candidates.sort(key=lambda item: item[0], reverse=True)
    _, latest_dir, latest_csv = candidates[0]
    return latest_dir, latest_csv


def plot_histograms(results_dict, results_plot_list, save_path, title_prefix=""):
    n_plots = len(results_plot_list)
    if n_plots == 0:
        return None
    n_cols = 1 if n_plots == 1 else 2
    n_rows = math.ceil(n_plots / n_cols)

    fig, axs = plt.subplots(n_rows, n_cols, figsize=(7 * n_cols, 5.2 * n_rows), squeeze=False)
    axs = axs.flatten()
    i = 0
    for var, unit in results_plot_list:
        key = var if var in results_dict else var.lower()
        if key not in results_dict:
            print(f"Warning: Plot parameter '{var}' not found in CSV headers {list(results_dict.keys())}")
            continue

        data = np.array(results_dict[key], dtype=float)
        if data.size == 0:
            continue
        mean = data.mean()
        max_val = data.max()
        min_val = data.min()
        std = data.std()

        ref_val = max(abs(min_val), abs(max_val))
        axis_scale, axis_prefix, _ = get_si_scale(ref_val)
        scaled_data = data / axis_scale
        scaled_mean = mean / axis_scale
        scaled_std = std / axis_scale

        bins = min(50, max(10, int(math.sqrt(data.size) * 2))) if data.size > 1 else 1
        axs[i].hist(scaled_data, bins=bins, color="skyblue", edgecolor="black")
        axs[i].set_title(
            f"{title_prefix}{var} (n={data.size}) | mean: {format_si(mean, unit)}, std: {format_si(std, unit)}\n"
            f"min: {format_si(min_val, unit)} | max: {format_si(max_val, unit)}",
            fontsize=9.5,
            pad=8,
        )

        axis_unit_label = f"{axis_prefix}{unit}"
        xlabel = f"{var} [{axis_unit_label}]" if axis_unit_label else var
        axs[i].set_xlabel(xlabel, fontsize=9, labelpad=6)
        axs[i].set_ylabel("Count", fontsize=9)
        ymax = axs[i].get_ylim()[1]

        axs[i].axvline(scaled_mean, color="green", linestyle="-", linewidth=2)
        axs[i].text(
            scaled_mean, ymax * 0.95, "Mean", color="green", rotation=90,
            verticalalignment="top", horizontalalignment="center", fontsize=8,
        )

        if scaled_std > 0:
            for sigma_mult in [1, 2, 3]:
                pos = scaled_mean + sigma_mult * scaled_std
                neg = scaled_mean - sigma_mult * scaled_std
                axs[i].axvline(pos, color="red", linestyle="--", linewidth=1)
                axs[i].axvline(neg, color="red", linestyle="--", linewidth=1)
                y_pos = ymax * (1 - 0.1 * sigma_mult)
                axs[i].text(
                    pos, y_pos, f"+{sigma_mult}σ", color="red", rotation=90,
                    verticalalignment="top", horizontalalignment="right", fontsize=8,
                )
                axs[i].text(
                    neg, y_pos, f"-{sigma_mult}σ", color="red", rotation=90,
                    verticalalignment="top", horizontalalignment="left", fontsize=8,
                )

            step = scaled_std / 2.0
            x_min = scaled_mean - 4.0 * scaled_std
            x_max = scaled_mean + 4.0 * scaled_std
            ticks = np.arange(x_min, x_max + step * 0.5, step)
            axs[i].set_xticks(ticks)
            tick_decimals = max(0, min(6, -math.floor(math.log10(step)) + 1))
            axs[i].xaxis.set_major_formatter(
                FuncFormatter(lambda x, _, d=tick_decimals: f"{x:.{d}f}")
            )
        else:
            axs[i].xaxis.set_major_formatter(
                FuncFormatter(lambda x, _: f"{x:.3f}".rstrip("0").rstrip("."))
            )

        plt.setp(
            axs[i].get_xticklabels(),
            rotation=35,
            ha="right",
            rotation_mode="anchor",
            fontsize=8.5,
        )
        i += 1

    if i == 0:
        plt.close(fig)
        return None

    for j in range(i, len(axs)):
        axs[j].axis("off")

    fig.tight_layout(pad=2.0, h_pad=3.2, w_pad=2.0)
    fig.savefig(save_path, dpi=150)
    return fig


def plot_pvt_comparison(rows_by_corner, corner_order, results_plot_list, save_path):
    """Plot per-corner values (or mean + min/max + +-1 sigma for PVT+MC)."""
    n_plots = len(results_plot_list)
    if n_plots == 0:
        return None
    n_cols = 1 if n_plots == 1 else 2
    n_rows = math.ceil(n_plots / n_cols)

    fig_w = max(7 * n_cols, min(22, 0.55 * len(corner_order) * n_cols + 6))
    fig, axs = plt.subplots(n_rows, n_cols, figsize=(fig_w, 5.2 * n_rows), squeeze=False)
    axs = axs.flatten()
    i = 0

    for var, unit in results_plot_list:
        means, stds, mins, maxs, valid_labels = [], [], [], [], []
        all_vals = []

        for label in corner_order:
            c_rows = rows_by_corner.get(label, [])
            vals = []
            for r in c_rows:
                raw_v = r.get(var, r.get(var.lower()))
                if raw_v is None or raw_v == "":
                    continue
                try:
                    vals.append(float(raw_v))
                except (ValueError, TypeError):
                    continue
            if vals:
                arr = np.array(vals, dtype=float)
                valid_labels.append(label)
                means.append(arr.mean())
                stds.append(arr.std())
                mins.append(arr.min())
                maxs.append(arr.max())
                all_vals.extend(vals)

        if not all_vals:
            continue

        all_arr = np.array(all_vals, dtype=float)
        ref_val = max(abs(all_arr.min()), abs(all_arr.max()))
        axis_scale, axis_prefix, _ = get_si_scale(ref_val)

        x = np.arange(len(valid_labels))
        s_means = np.array(means) / axis_scale
        s_stds = np.array(stds) / axis_scale
        s_mins = np.array(mins) / axis_scale
        s_maxs = np.array(maxs) / axis_scale

        is_mc = any(s > 0 for s in stds) or any(len(rows_by_corner.get(lbl, [])) > 1 for lbl in valid_labels)

        if is_mc:
            axs[i].vlines(x, s_mins, s_maxs, color="steelblue", linewidth=1.6, alpha=0.8, label="Min–Max")
            axs[i].vlines(x, s_means - s_stds, s_means + s_stds, color="navy", linewidth=4.5, alpha=0.7, label="Mean ± 1σ")
            axs[i].plot(x, s_means, "o", color="crimson", markersize=5.5, zorder=5, label="Mean")
            axs[i].legend(fontsize=8, loc="best")
        else:
            axs[i].plot(x, s_means, "o-", color="steelblue", linewidth=1.8, markersize=6)
            for xi, yi, raw_v in zip(x, s_means, means):
                axs[i].annotate(
                    format_si(raw_v, ""),
                    (xi, yi),
                    textcoords="offset points",
                    xytext=(0, 6),
                    ha="center",
                    fontsize=7.5,
                )

        axs[i].set_title(
            f"PVT: {var} ({len(valid_labels)} corners, n={all_arr.size}) | "
            f"min: {format_si(all_arr.min(), unit)} | max: {format_si(all_arr.max(), unit)}",
            fontsize=9.5,
            pad=8,
        )
        axis_unit_label = f"{axis_prefix}{unit}"
        ylabel = f"{var} [{axis_unit_label}]" if axis_unit_label else var
        axs[i].set_ylabel(ylabel, fontsize=9)
        axs[i].set_xticks(x)
        axs[i].set_xticklabels(valid_labels, rotation=40, ha="right", fontsize=8)
        axs[i].grid(True, axis="y", linestyle="--", alpha=0.4)
        i += 1

    if i == 0:
        plt.close(fig)
        return None

    for j in range(i, len(axs)):
        axs[j].axis("off")

    fig.tight_layout(pad=2.0, h_pad=3.2, w_pad=2.0)
    fig.savefig(save_path, dpi=150)
    return fig


def plot_status_results(
    rows_by_corner,
    corner_order,
    results_status_list,
    save_path,
    plot_type="auto",
    title_prefix="",
):
    """
    Plots PASSED/FAILED (or custom status) counts per status column across corners.
    """
    status_cols = list(results_status_list)
    if not status_cols:
        return None

    plot_type = plot_type.lower().strip()
    if plot_type == "auto":
        plot_type = "bar" if len(corner_order) > 1 else "pie"
    if plot_type not in ("bar", "pie"):
        raise ValueError("Invalid plot_type. Choose 'auto', 'bar', or 'pie'.")

    n_plots = len(status_cols)
    n_cols = 1 if n_plots == 1 else 2
    n_rows = max(1, math.ceil(n_plots / n_cols))

    if plot_type == "bar":
        fig_w = max(7 * n_cols, min(22, 0.55 * len(corner_order) * n_cols + 6))
    else:
        fig_w = 7 * n_cols

    fig, axs = plt.subplots(
        n_rows, n_cols, figsize=(fig_w, 5.2 * n_rows), squeeze=False
    )
    fig.subplots_adjust(wspace=0.9, bottom=0.14)
    axs = axs.flatten()

    status_palette = {
        pass_string: "#2ca02c",
        fail_string: "#d62728",
    }
    fallback_colors = ["#1f77b4", "#ff7f0e", "#9467bd", "#8c564b"]

    i = 0
    for var in status_cols:
        corner_counts = {}
        found_any = False
        all_labels = set()

        for corner in corner_order:
            c_data = rows_by_corner.get(corner)
            raw_vals = []
            if isinstance(c_data, list):
                for r in c_data:
                    if var in r:
                        raw_vals.append(r[var])
                    elif var.lower() in r:
                        raw_vals.append(r[var.lower()])
            elif isinstance(c_data, dict):
                key = var if var in c_data else var.lower()
                if key in c_data:
                    raw_vals = c_data[key]

            vals = [str(v).strip().upper() for v in raw_vals if v is not None and str(v).strip() != ""]
            if not vals:
                continue

            found_any = True
            unique, counts = np.unique(vals, return_counts=True)
            c_map = {str(u): int(cnt) for u, cnt in zip(unique, counts)}
            corner_counts[corner] = c_map
            all_labels.update(c_map.keys())

        if not found_any:
            print(f"Warning: Status parameter '{var}' not found in corners {list(rows_by_corner.keys())}")
            continue

        priority = [pass_string, fail_string]
        ordered_statuses = [s for s in priority if s in all_labels] + sorted(
            [s for s in all_labels if s not in priority]
        )

        colors = [
            status_palette.get(s, fallback_colors[idx % len(fallback_colors)])
            for idx, s in enumerate(ordered_statuses)
        ]

        total_n = sum(sum(c.values()) for c in corner_counts.values())
        passed_n = sum(c.get(pass_string, 0) for c in corner_counts.values())
        failed_n = sum(c.get(fail_string, 0) for c in corner_counts.values())
        pass_rate = (passed_n / total_n * 100.0) if total_n > 0 else 0.0

        ax = axs[i]
        title_str = (
            f"{title_prefix}{var} (n={total_n}) | pass rate: {pass_rate:.1f}%\n"
            f"passed: {passed_n} | failed: {failed_n}"
        )

        if plot_type == "bar":
            x = np.arange(len(corner_order))
            n_statuses = max(1, len(ordered_statuses))
            width = 0.75 / n_statuses

            for idx, status in enumerate(ordered_statuses):
                counts_per_corner = [
                    corner_counts.get(c, {}).get(status, 0) for c in corner_order
                ]
                offset = (idx - (n_statuses - 1) / 2.0) * width
                bars = ax.bar(
                    x + offset,
                    counts_per_corner,
                    width=width,
                    label=status,
                    color=colors[idx],
                    edgecolor="black",
                )
                ax.bar_label(bars, padding=2, fontsize=8)

            ax.set_title(title_str, fontsize=9, pad=0)
            #ha="center", va="center", x=0.9, y=0.9
            #ax.set_xlabel("Corner", fontsize=9, labelpad=6)
            #ax.set_ylabel("Count", fontsize=9)
            ax.set_xticks(x)
            ax.set_xticklabels(corner_order)
            ax.grid(axis="y", linestyle="--", alpha=0.5)
            ax.legend(fontsize=8)
            ax.set_zorder(100-i)

            ymax = ax.get_ylim()[1]
            if ymax > 0:
                ax.set_ylim(0, ymax * 1.15)

            plt.setp(
                ax.get_xticklabels(),
                rotation=35,
                ha="right",
                rotation_mode="anchor",
                fontsize=8.5,
            )

        elif plot_type == "pie":
            pie_items = [
                (status, sum(corner_counts.get(c, {}).get(status, 0) for c in corner_order), color)
                for status, color in zip(ordered_statuses, colors)
            ]
            pie_items = [item for item in pie_items if item[1] > 0]
            if not pie_items:
                ax.text(0.5, 0.5, "No Data", ha="center", va="center")
                ax.axis("off")
            else:
                pie_labels = [item[0] for item in pie_items]
                pie_totals = [item[1] for item in pie_items]
                pie_colors = [item[2] for item in pie_items]
                ax.pie(
                    pie_totals,
                    labels=pie_labels,
                    autopct=lambda pct: f"{pct:.1f}%\n({round(pct / 100.0 * total_n)})",
                    colors=pie_colors,
                    startangle=90,
                    wedgeprops={"edgecolor": "black", "linewidth": 0.8},
                    textprops={"fontsize": 8.5},
                )
            ax.set_title(title_str, fontsize=9.5, pad=8)

        i += 1

    if i == 0:
        plt.close(fig)
        return None

    for j in range(i, len(axs)):
        axs[j].axis("off")

    fig.tight_layout(pad=2.0, h_pad=3.2, w_pad=2.0)
    fig.savefig(save_path, dpi=150)
    return fig


def print_terminal_summary(rows_by_corner, corner_order, metric_cols, results_plot_list, skipped_by_corner=None):
    print("\n=== PVT / MC SUMMARY ===")
    unit_lookup = {var.lower(): unit for var, unit in results_plot_list}
    numeric_metric_cols = [c for c in metric_cols if not is_status_column(c)]
    disp_metrics = [var for var, _ in results_plot_list] if results_plot_list else numeric_metric_cols
    row_status_col = f"row_{status_columns_suffix}"

    for lbl in corner_order:
        c_rows = rows_by_corner.get(lbl, [])
        parts = []
        for vm in disp_metrics:
            key = vm if vm in numeric_metric_cols else (vm.lower() if vm.lower() in numeric_metric_cols else None)
            if not key:
                continue
            vals = []
            for r in c_rows:
                if key in r and r[key] != "":
                    try:
                        vals.append(float(r[key]))
                    except (ValueError, TypeError):
                        pass
            if not vals:
                parts.append(f"{vm}=FAIL")
                continue
            u = unit_lookup.get(vm.lower(), "")
            arr = np.array(vals, dtype=float)
            if arr.size == 1:
                parts.append(f"{vm}={format_si(arr[0], u)}")
            else:
                parts.append(
                    f"{vm}={format_si(arr.mean(), u)} "
                    f"(min {format_si(arr.min(), u)}, max {format_si(arr.max(), u)})"
                )

        status_summary = ""
        if any(row_status_col in r for r in c_rows):
            passed = sum(1 for r in c_rows if str(r.get(row_status_col, "")).strip().upper() == pass_string)
            status_summary = f", pass={passed}/{len(c_rows)}"

        skip_str = f", skip={skipped_by_corner[lbl]}" if skipped_by_corner is not None else ""
        print(f"  [{lbl}] (n={len(c_rows)}{skip_str}{status_summary}): " + " | ".join(parts))




# =============================================================
# Failure root-cause analysis (rule mining)
# =============================================================

def _to_float_or_nan(v):
    try:
        return float(v)
    except (ValueError, TypeError):
        return float("nan")


def _column_is_numeric(values):
    """True if >=90% of non-empty values parse as float and there are >=5 distinct values."""
    vals = [v for v in values if v not in (None, "")]
    if len(vals) < 5:
        return False
    try:
        nums = [float(v) for v in vals]
    except (ValueError, TypeError):
        return False
    return len(set(nums)) >= 5


def _score_predicates(sub_fail, passed_rows, input_cols,
                      min_coverage, max_pass_share, min_fail_count):
    """
    Enumerate candidate predicates per input column and score them on
    `sub_fail` (the currently-unexplained failures) vs `passed_rows`.
    Returns list of dicts; each has a `mask` list over `sub_fail`.
    """
    n_fail = len(sub_fail)
    n_pass = len(passed_rows)
    preds = []

    for col in input_cols:
        f_raw = [r.get(col) for r in sub_fail]
        p_raw = [r.get(col) for r in passed_rows]
        non_empty = [v for v in (f_raw + p_raw) if v not in (None, "")]

        # ---- numeric threshold predicates ----
        if _column_is_numeric(non_empty):
            f = np.array([_to_float_or_nan(v) for v in f_raw], dtype=float)
            p = np.array([_to_float_or_nan(v) for v in p_raw], dtype=float)
            f_ok = np.isfinite(f)
            p_ok = np.isfinite(p)
            if f_ok.sum() < min_fail_count:
                continue
            uniq = np.unique(f[f_ok])
            if len(uniq) > 12:
                uniq = np.quantile(uniq, np.linspace(0, 1, 12))
            if len(uniq) < 2:
                continue
            cuts = (uniq[:-1] + uniq[1:]) / 2.0

            for t in cuts:
                for op, f_part, p_part in (
                    ("<=", f <= t, p <= t),
                    (">",  f > t,  p > t),
                ):
                    f_mask = f_part & f_ok
                    fail_n = int(f_mask.sum())
                    if fail_n < min_fail_count:
                        continue
                    coverage = fail_n / n_fail
                    if coverage < min_coverage:
                        continue
                    pass_n = int((p_part & p_ok).sum())
                    support_pass = pass_n / n_pass if n_pass else 0.0
                    if n_pass and support_pass > max_pass_share:
                        continue
                    lift = coverage / max(support_pass, 1e-6)
                    score = coverage * (coverage - support_pass)
                    preds.append(dict(
                        col=col, op=op, thr=float(t),
                        text=f"{col} {op} {t:.4g}",
                        fail_n=fail_n, pass_n=pass_n,
                        coverage=coverage,
                        support_pass=support_pass,
                        lift=lift, score=score,
                        mask=f_mask.tolist(),
                    ))

        # ---- categorical equality predicates ----
        else:
            f_str = [str(v) for v in f_raw if v not in (None, "")]
            p_str = [str(v) for v in p_raw if v not in (None, "")]
            if not f_str:
                continue
            f_cnt = Counter(f_str)
            p_cnt = Counter(p_str)
            for val, fail_n in f_cnt.items():
                if fail_n < min_fail_count:
                    continue
                coverage = fail_n / n_fail
                if coverage < min_coverage:
                    continue
                pass_n = p_cnt.get(val, 0)
                support_pass = pass_n / n_pass if n_pass else 0.0
                if n_pass and support_pass > max_pass_share:
                    continue
                lift = coverage / max(support_pass, 1e-6)
                score = coverage * (coverage - support_pass)
                mask = [str(v) == val for v in f_raw]
                preds.append(dict(
                    col=col, op="==", thr=val,
                    text=f"{col} == '{val}'",
                    fail_n=fail_n, pass_n=pass_n,
                    coverage=coverage,
                    support_pass=support_pass,
                    lift=lift, score=score,
                    mask=mask,
                ))
    return preds


def extract_failure_rules(failed_rows, passed_rows, input_cols,
                          max_rules=5, min_coverage=0.10, max_pass_share=0.25,
                          min_fail_count=2, stop_coverage=0.85):
    """
    Greedy sequential covering:
      * Rank predicates on unexplained failures.
      * Pick the best, mark its matches explained.
      * Repeat on the remaining unexplained failures.
    Each successive rule therefore captures a *different* cause.
    """
    n_fail = len(failed_rows)
    if n_fail == 0:
        return []

    explained = [False] * n_fail
    rules = []

    for _ in range(max_rules):
        sub_fail = [failed_rows[i] for i in range(n_fail) if not explained[i]]
        if len(sub_fail) < min_fail_count:
            break

        preds = _score_predicates(
            sub_fail, passed_rows, input_cols,
            min_coverage=min_coverage,
            max_pass_share=max_pass_share,
            min_fail_count=min_fail_count,
        )
        if not preds:
            break
        best = max(preds, key=lambda d: d["score"])

        # Map sub-fail mask back to global failure indices
        matched = []
        sub_i = 0
        for gi in range(n_fail):
            if explained[gi]:
                continue
            if best["mask"][sub_i]:
                matched.append(gi)
            sub_i += 1

        # Evidence: corners + most common observed failure reason
        corners = Counter(failed_rows[i].get("corner", "?") for i in matched)
        reasons = Counter(
            str(failed_rows[i].get(_failure_reason_col_global, "")).strip()
            for i in matched
            if str(failed_rows[i].get(_failure_reason_col_global, "")).strip()
        )
        top_reason = reasons.most_common(1)[0][0] if reasons else ""

        global_coverage = len(matched) / n_fail
        
        rules.append({
            "text": best["text"],
            "col": best["col"], "op": best["op"], "thr": best["thr"],
            "fail_n": best["fail_n"], "pass_n": best["pass_n"],
            "coverage": global_coverage,  # <--- Use global coverage for display
            "support_pass": best["support_pass"],
            "lift": best["lift"],
            "score": best["score"],
            "corners": dict(corners),
            "top_reason": top_reason,
            "matched_indices": matched,
        })
        for i in matched:
            explained[i] = True
        if sum(explained) / n_fail >= stop_coverage:
            break

    return rules


# Global so extract_failure_rules can see it without threading it through
_failure_reason_col_global = None


def plot_failure_analysis(
    rows_by_corner,
    corner_order,
    metric_cols,
    save_path,
    csv_save_path=None,
    target_status_col=None,
    max_table_rows=15,
    max_rules=5,
    min_coverage=0.10,
    max_pass_share=0.25,
):
    """
    Failure root-cause analysis:
      * Mines concrete input rules (excluding the 'corner' label itself).
      * Left panel: Clear text-based cards for each rule.
      * Right panel: Table of failed rows that actually match the top rules.
    """
    global _failure_reason_col_global

    if target_status_col is None:
        target_status_col = f"row_{status_columns_suffix}"
    failure_reason_col = f"failure_reason_{status_columns_suffix}"
    _failure_reason_col_global = failure_reason_col

    # --- FIX 1: Exclude derived labels so the algorithm finds base parameters ---
    excluded_cols = set(metric_cols) | {target_status_col, failure_reason_col}
    excluded_cols.update({"corner", "pvt_corner"}) 

    # ---- Collect failed vs passed rows ----
    passed_rows, failed_rows = [], []
    for corner in corner_order:
        c_data = rows_by_corner.get(corner)
        if not c_data:
            continue
        if isinstance(c_data, dict):
            keys = list(c_data.keys())
            n_items = len(c_data[keys[0]]) if keys else 0
            rows_iter = ({k: c_data[k][i] for k in keys} for i in range(n_items))
        else:
            rows_iter = c_data
        for r in rows_iter:
            row_copy = dict(r)
            # We still add it for table display, but we excluded it from mining above
            row_copy.setdefault("corner", corner) 
            status = str(row_copy.get(target_status_col,
                                      row_copy.get(target_status_col.lower(), ""))
                         ).strip().upper()
            if status == fail_string:
                failed_rows.append(row_copy)
            elif status == pass_string:
                passed_rows.append(row_copy)

    if not failed_rows:
        return None

    # ---- Extract input columns ----
    all_keys = set()
    for r in failed_rows: all_keys.update(r.keys())
    for r in passed_rows: all_keys.update(r.keys())
    input_cols = [c for c in sorted(all_keys) if c not in excluded_cols]

    # ---- Mine rules ----
    rules = extract_failure_rules(
        failed_rows, passed_rows, input_cols,
        max_rules=max_rules,
        min_coverage=min_coverage,
        max_pass_share=max_pass_share,
    )
    
    rule_cols = []
    for r in rules:
        if r["col"] not in rule_cols:
            rule_cols.append(r["col"])
    
    table_param_cols = rule_cols[:3] if rule_cols else input_cols[:3]
    # Don't duplicate 'corner' in the table
    table_param_cols = [c for c in table_param_cols if c != "corner"]
    if not table_param_cols:
        table_param_cols = [c for c in input_cols if c != "corner"][:3]

    # ---- CSV export ----
    if csv_save_path:
        ordered = (["corner"] + rule_cols
                   + [c for c in input_cols if c not in rule_cols and c != "corner"]
                   + [failure_reason_col]
                   + [c for c in metric_cols if c != failure_reason_col])
        ordered = [f for f in ordered if f in all_keys]
        with open(csv_save_path, "w", newline="", encoding="utf-8") as fh:
            w = csv.DictWriter(fh, fieldnames=ordered, extrasaction="ignore")
            w.writeheader()
            w.writerows(failed_rows)

    # ---- Figure Setup ----
    fig_h = max(5.0, 0.36 * min(len(failed_rows), max_table_rows) + 2.6)
    fig, (ax_rules, ax_tbl) = plt.subplots(
        1, 2,
        figsize=(16, fig_h),
        gridspec_kw={"width_ratios": [1.0, 1.8]},
    )

    total_runs = len(failed_rows) + len(passed_rows)
    pass_rate = (len(passed_rows) / total_runs * 100.0) if total_runs else 0.0

    headline = ""
    if rules:
        top = rules[0]
        headline = (f"Primary cause: {top['text']}  "
                    f"({top['coverage']*100:.1f}% of failures, "
                    f"lift {top['lift']:.1f}×)")
    else:
        headline = "No dominant input rule isolated."
        
    fig.suptitle(
        f"Failure Root-Cause Analysis: {target_status_col}\n"
        f"{len(failed_rows)}/{total_runs} failed ({100 - pass_rate:.1f}%) — {headline}",
        fontsize=11, fontweight="bold", y=0.98,
    )

    # ---------------- LEFT PANEL: Ranked Rules (Text Cards) ----------------
    ax_rules.axis("off")
    ax_rules.set_title("Ranked Failure Causes", fontsize=10, fontweight="bold", pad=10)
    
    if rules:
        y_pos = 0.95
        for i, r in enumerate(rules):
            box_color = "#fde8e8" if i == 0 else "#f5f5f5"
            edge_color = "#d62728" if i == 0 else "#aaaaaa"
            
            ax_rules.text(
                0.05, y_pos, f"#{i+1}  {r['text']}", 
                fontsize=10, fontweight="bold", color="#222", va="top", ha="left"
            )
            
            sub_text = (
                f"Explains {r['coverage']*100:.0f}% of ALL failures "
                f"({r['fail_n']} fail / {r['pass_n']} pass). "
                f"Lift: {r['lift']:.1f}×"
            )
            ax_rules.text(
                0.05, y_pos - 0.06, sub_text, 
                fontsize=8.5, color="#444", va="top", ha="left"
            )
            
            if r['top_reason']:
                short_reason = r['top_reason'].split('|')[0][:70]
                ax_rules.text(
                    0.05, y_pos - 0.12, f"↳ Observed: {short_reason}...", 
                    fontsize=8, color="#666", style="italic", va="top", ha="left"
                )
            
            if i == 0:
                rect = plt.Rectangle((0.0, y_pos - 0.22), 1.0, 0.25, 
                                     transform=ax_rules.transAxes, 
                                     facecolor=box_color, edgecolor=edge_color, 
                                     alpha=0.4, zorder=0, clip_on=False)
                ax_rules.add_patch(rect)
                
            y_pos -= 0.28
    else:
        ax_rules.text(0.5, 0.5, "No dominant input rule isolated", 
                      ha="center", va="center", fontsize=10)

    # ---------------- RIGHT PANEL: Failed Rows Table ----------------
    ax_tbl.axis("off")
    
    # --- FIX 2: Sort rows so the ones matching the top rules appear first ---
    def get_rule_match_score(row_obj):
        # Returns the index of the highest-priority rule this row matches
        for ri, rule in enumerate(rules):
            if any(failed_rows[gi] is row_obj for gi in rule["matched_indices"]):
                return ri
        return 999  # Doesn't match any rule
        
    sorted_failed_rows = sorted(failed_rows, key=get_rule_match_score)
    display_rows = sorted_failed_rows[:max_table_rows]

    col_headers = ["#", "Corner"] + table_param_cols + ["Failure Reason"]

    table_data = []
    row_line_counts = []
    
    display_idx_by_obj = {id(r): i for i, r in enumerate(display_rows)}
    rule_indices_for_row = [set() for _ in display_rows]
    for ri, rule in enumerate(rules):
        for gi in rule["matched_indices"]:
            i = display_idx_by_obj.get(id(failed_rows[gi]))
            if i is not None:
                rule_indices_for_row[i].add(ri + 1)

    for idx, r in enumerate(display_rows, 1):
        raw_reason = str(r.get(failure_reason_col, "")).strip()
        if raw_reason:
            reason_lines = [p.strip() for p in raw_reason.split("|") if p.strip()]
            reason = "\n".join(reason_lines) if reason_lines else "N/A"
        else:
            failed_metrics = [
                c.replace(f"_{status_columns_suffix}", "")
                for c in metric_cols
                if is_status_column(c)
                and c not in (target_status_col, failure_reason_col)
                and str(r.get(c, "")).strip().upper() == fail_string
            ]
            reason = "\n".join(failed_metrics) if failed_metrics else "N/A"

        corner_cell = str(r.get("corner", "N/A"))
        
        row_cells = [str(idx), corner_cell]
        for p in table_param_cols:
            val = r.get(p, "N/A")
            try:
                row_cells.append(f"{float(val):.4g}")
            except (ValueError, TypeError):
                row_cells.append(str(val))
        row_cells.append(reason)

        table_data.append(row_cells)
        row_line_counts.append(max(cell.count("\n") + 1 for cell in row_cells))

    all_rows_with_header = [col_headers] + table_data
    col_max_chars = [
        max(max(len(line) for line in str(row[c]).split("\n"))
            for row in all_rows_with_header)
        for c in range(len(col_headers))
    ]
    total_chars = sum(col_max_chars)
    table_width_ratio = max(1.55, total_chars / 25.0)

    gs = fig.add_gridspec(1, 2, width_ratios=[1.0, table_width_ratio])
    ax_rules.set_subplotspec(gs[0])
    ax_tbl.set_subplotspec(gs[1])

    tbl = ax_tbl.table(cellText=table_data, colLabels=col_headers,
                       loc="center", cellLoc="center")
    tbl.auto_set_font_size(False)
    tbl.set_fontsize(8.5)
    tbl.auto_set_column_width(col=list(range(len(col_headers))))

    base_h = tbl[0, 0].get_height() * 1.45
    for (row_idx, col_idx), cell in tbl.get_celld().items():
        cell.set_edgecolor("#cccccc")
        cell.PAD = 0.06
        
        if row_idx == 0:
            cell.set_height(base_h)
            cell.set_facecolor("#2b2b2b")
            cell.set_text_props(color="white", weight="bold")
        else:
            n_lines = row_line_counts[row_idx - 1]
            cell.set_height(base_h * (0.75 + 0.55 * n_lines))
            if row_idx % 2 == 1:
                cell.set_facecolor("#f9f9f9")
                
            if col_idx == len(col_headers) - 1:
                cell.get_text().set_ha("left")
                cell.PAD = 0.04
            
            if rules and col_idx >= 2 and col_idx < 2 + len(table_param_cols):
                col_name = table_param_cols[col_idx - 2]
                rule0 = rules[0]
                if rule0["col"] == col_name:
                    cell.set_facecolor("#fde8e8")

    tbl_title = f"Failed Runs (sorted by cause priority — showing {len(display_rows)} of {len(failed_rows)})"
    if csv_save_path:
        tbl_title += f"\nFull list: {os.path.basename(csv_save_path)}"
    ax_tbl.set_title(tbl_title, fontsize=9.5, pad=8)

    fig.tight_layout(rect=(0, 0, 1, 0.94))
    fig.savefig(save_path, dpi=150)
    #plt.close(fig)
    return fig

def render_all_plots(
    all_rows,
    rows_by_corner,
    corner_order,
    metric_cols,
    results_plot_list,
    run_results_dir,
    netlist_name,
    status_plot_type="auto",
    show_plots=True,
):
    numeric_cols = [c for c in metric_cols if not is_status_column(c)]
    failure_reason_col = f"failure_reason_{status_columns_suffix}"
    row_status_col = f"row_{status_columns_suffix}"

    status_cols = [
        c for c in metric_cols
        if is_status_column(c) and c != failure_reason_col
    ]
    if row_status_col in status_cols:
        status_cols = [row_status_col] + [c for c in status_cols if c != row_status_col]

    results_dict = {}
    for mc in numeric_cols:
        vals = []
        for r in all_rows:
            if mc in r and r[mc] != "":
                try:
                    vals.append(float(r[mc]))
                except (ValueError, TypeError):
                    pass
        if vals:
            results_dict[mc] = vals

    any_plotted = False

    if results_plot_list:
        if len(corner_order) > 1:
            pvt_svg = os.path.join(run_results_dir, f"{netlist_name}_pvt_comparison.svg")
            if plot_pvt_comparison(rows_by_corner, corner_order, results_plot_list, pvt_svg) is not None:
                print(f"Saved PVT comparison plot -> {pvt_svg}")
                any_plotted = True

        if len(all_rows) > 1:
            hist_svg = os.path.join(run_results_dir, f"{netlist_name}_histograms.svg")
            prefix = "Pooled PVT+MC: " if len(corner_order) > 1 else ""
            if plot_histograms(results_dict, results_plot_list, hist_svg, title_prefix=prefix) is not None:
                print(f"Saved histogram plot -> {hist_svg}")
                any_plotted = True

    if status_cols:
        #analyze_failure_root_causes(rows_by_corner, corner_order, metric_cols)
        status_svg = os.path.join(run_results_dir, f"{netlist_name}_status.svg")
        if plot_status_results(
            rows_by_corner,
            corner_order,
            status_cols,
            status_svg,
            plot_type=status_plot_type,
        ) is not None:
            print(f"Saved status plot -> {status_svg}")
            any_plotted = True
            
        
        fail_svg = os.path.join(run_results_dir, f"{netlist_name}_failure_analysis.svg")
        fail_csv = os.path.join(run_results_dir, f"{netlist_name}_failed_rows.csv")
        if plot_failure_analysis(
            rows_by_corner=rows_by_corner,
            corner_order=corner_order,
            metric_cols=metric_cols,
            save_path=fail_svg,
            csv_save_path=fail_csv,
            target_status_col=row_status_col,
            max_rules=50,
            min_coverage=0.10,
            max_pass_share=0.25,
        )  is not None:
            print(f"Saved failure analysis plot -> {fail_svg}")
            print(f"Saved failed rows CSV -> {fail_csv}")
            any_plotted = True

    if show_plots and any_plotted:
        plt.show()
    


def parse_args():
    parser = argparse.ArgumentParser(
        description="Run parallel ngspice Monte Carlo / PVT simulations or redraw the latest saved results."
    )
    parser.add_argument(
        "netlist",
        help="Path to schematic or netlist (e.g., simulations/inv_tb.sch or simulations/inv_tb.spice)",
    )
    parser.add_argument(
        "-s", "--show",
        action="store_true",
        help="Skip simulations; load and redraw the latest saved results for this netlist.",
    )
    parser.add_argument(
        "--status-plot",
        choices=["auto", "bar", "pie"],
        default="auto",
        help="Status chart style (default: auto -> 'bar' for multi-corner PVT, 'pie' for single corner).",
    )
    return parser.parse_args()


def main():
    global simulations_dir
    args = parse_args()

    start_time = time.time()

    # Resolve netlist name and paths
    netlist_path, _ = os.path.splitext(args.netlist)
    netlist_name = os.path.basename(netlist_path)
    simulations_dir = os.path.dirname(args.netlist)
    netlist_path_name = netlist_path + ".spice"
    results_dir = os.path.join(simulations_dir, "results") if simulations_dir else "results"

    # === SHOW-ONLY MODE (-s): load latest results and redraw ===
    if args.show:
        try:
            run_results_dir, latest_csv = find_latest_results_dir(results_dir, netlist_name)
        except FileNotFoundError as e:
            print(f"Error: {e}")
            sys.exit(1)

        print(f"Info: Loading latest results from {run_results_dir}")

        # Prefer current .spice for updated plot/unit definitions; fall back to run snapshot
        snapshot_file = os.path.join(run_results_dir, f"{netlist_name}_netlist_snapshot.spice")
        netlist = ""
        if os.path.isfile(netlist_path_name):
            with open(netlist_path_name, "r") as f:
                netlist = f.read()
        elif os.path.isfile(snapshot_file):
            print(f"Info: Using netlist snapshot {snapshot_file}")
            with open(snapshot_file, "r") as f:
                netlist = f.read()
        else:
            print("Warning: Neither netlist nor snapshot found; plotting all numeric columns without units.")

        results_plot_list = []
        filter_rules = {}
        extra_param_names = []
        netlist_corner_order = []
        if netlist:
            pvt_combos, extra_param_names, _ = parse_pvt_config(netlist)
            netlist_corner_order = [cfg["label"] for cfg in pvt_combos]
            results_plot_list, filter_rules = parse_plot_config(netlist)

        with open(latest_csv, "r", newline="") as f:
            reader = csv.DictReader(f, delimiter=";")
            merged_fieldnames = list(reader.fieldnames or [])
            all_rows = list(reader)

        if not all_rows:
            print(f"Error: Latest CSV file is empty: {latest_csv}")
            sys.exit(1)

        meta_cols = {"pvt_corner", "process", "temp", "vdd", *extra_param_names}
        metric_cols = [c for c in merged_fieldnames if c not in meta_cols]

        # Backfill status columns in memory if loading an older CSV that predates status tracking
        if filter_rules and not any(is_status_column(c) for c in metric_cols):
            for row in all_rows:
                numeric_row = {}
                for col in metric_cols:
                    try:
                        numeric_row[col] = float(row[col])
                    except (ValueError, TypeError, KeyError):
                        pass
                reject_reason = check_reject_rules(numeric_row, filter_rules)
                for k, v in numeric_row.items():
                    if is_status_column(k):
                        row[k] = v
                        if k not in metric_cols:
                            metric_cols.append(k)
                row_status_col = f"row_{status_columns_suffix}"
                row[row_status_col] = fail_string if reject_reason else pass_string
                if row_status_col not in metric_cols:
                    metric_cols.append(row_status_col)

        if not results_plot_list:
            results_plot_list = [(c, "") for c in metric_cols if not is_status_column(c)]

        rows_by_corner: dict[str, list[dict]] = {}
        csv_corner_order = []
        for row in all_rows:
            lbl = row.get("pvt_corner", "nominal")
            if lbl not in rows_by_corner:
                rows_by_corner[lbl] = []
                csv_corner_order.append(lbl)
            rows_by_corner[lbl].append(row)

        corner_order = [c for c in netlist_corner_order if c in rows_by_corner] + [
            c for c in csv_corner_order if c not in netlist_corner_order
        ]

        print_terminal_summary(rows_by_corner, corner_order, metric_cols, results_plot_list)
        render_all_plots(
            all_rows,
            rows_by_corner,
            corner_order,
            metric_cols,
            results_plot_list,
            run_results_dir,
            netlist_name,
            status_plot_type=args.status_plot,
            show_plots=True,
        )
        print(f"\nResults folder: {run_results_dir}")
        return

    # === SIMULATION MODE ===
    run_timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    if not os.path.exists(netlist_path_name):
        print("Error: Netlist file " + netlist_path_name + " not found.")
        sys.exit(1)
    with open(netlist_path_name, "r") as f:
        netlist = f.read()

    # Create a new timestamped folder inside results/ (preserves all previous runs)
    run_folder_name = f"{netlist_name}_{run_timestamp}"
    run_results_dir = os.path.join(results_dir, run_folder_name)
    os.makedirs(run_results_dir, exist_ok=True)
    print(f"Info: Saving results to {run_results_dir}")

    # Save snapshot of exact netlist used for this run
    snapshot_file = os.path.join(run_results_dir, f"{netlist_name}_netlist_snapshot.spice")
    with open(snapshot_file, "w") as snap_f:
        snap_f.write(netlist)

    final_result_file = os.path.join(run_results_dir, f"{netlist_name}_mc_results.csv")
    pvt_summary_file = os.path.join(run_results_dir, f"{netlist_name}_pvt_summary.csv")
    parse_error_log_file = os.path.join(run_results_dir, f"{netlist_name}_parse_errors.log")

    # get nr_workers from netlist
    match = re.search(r"^[ \t]*\*\*nr_workers[ \t]*=[ \t]*(\d+)[ \t]*$", netlist, re.MULTILINE)
    if match:
        nr_workers = int(match.group(1).strip())
    else:
        print("Info: **nr_workers statement not found or erroneous, setting it to 10.")
        nr_workers = 10

    # get nr_mc_sims from netlist (runs per PVT corner)
    match = re.search(r"^[ \t]*\*\*nr_mc_sims[ \t]*=[ \t]*(\d+)[ \t]*$", netlist, re.MULTILINE)
    if match:
        nr_mc_sims = int(match.group(1).strip())
    else:
        print("Info: **nr_mc_sims statement not found or erroneous, setting it to 100.")
        nr_mc_sims = 100

    # get optional max_failures per worker task from netlist
    match = re.search(r"^[ \t]*\*\*max_failures[ \t]*=[ \t]*(\d+)[ \t]*$", netlist, re.MULTILINE)
    if match:
        max_failures = int(match.group(1).strip())
    else:
        max_failures = DEFAULT_MAX_FAILURES

    # parse PVT corners (process, temp, vdd, and any **pvt_param)
    pvt_combos, extra_param_names, pvt_enabled = parse_pvt_config(netlist)
    if pvt_enabled:
        print(
            f"Info: PVT sweep enabled -> {len(pvt_combos)} corner(s) x {nr_mc_sims} run(s)/corner "
            f"= {len(pvt_combos) * nr_mc_sims} total target runs"
        )
    else:
        print(f"Info: Single corner ({pvt_combos[0]['label']}) x {nr_mc_sims} MC run(s)")

    # get plot parameters, optional [unit], and optional status filters (e.g., **dc_gain,<8)
    results_plot_list, filter_rules = parse_plot_config(netlist)
    if not results_plot_list:
        print("Info: No results plot parameter settings found.")

    if filter_rules:
        rule_summary = ", ".join(
            f"{var} ({' OR '.join(f'{op}{val:g}' for op, val in rules)})"
            for var, rules in filter_rules.items()
        )
        print(f"Info: Active status filters (max_failures={max_failures}/task): {rule_summary}")

    # Build parallel tasks so all nr_workers cores stay busy across PVT corners and MC runs
    base_seed = int(start_time * 1000) % 2147483646 + 1
    tasks_per_corner = max(1, min(nr_mc_sims, math.ceil(nr_workers / len(pvt_combos))))
    worker_inputs = []
    task_id = 0
    for pvt_cfg in pvt_combos:
        for run_count in chunk_counts(nr_mc_sims, tasks_per_corner):
            worker_inputs.append(
                (
                    task_id,
                    run_count,
                    base_seed,
                    netlist,
                    netlist_name,
                    run_results_dir,
                    pvt_cfg,
                    filter_rules,
                    max_failures,
                )
            )
            task_id += 1

    pool_size = min(nr_workers, len(worker_inputs))
    with Pool(pool_size) as pool:
        worker_outputs = pool.map(run_worker, worker_inputs)

    all_parse_errors = []
    total_skipped = 0
    total_skip_reasons = Counter()
    skipped_by_corner = Counter()
    part_files = []

    for pvt_label, part_file, errs, skipped, reasons in worker_outputs:
        part_files.append(part_file)
        all_parse_errors.extend(errs)
        total_skipped += skipped
        skipped_by_corner[pvt_label] += skipped
        total_skip_reasons.update(reasons)

    if all_parse_errors:
        with open(parse_error_log_file, "w") as log_f:
            log_f.write("\n".join(all_parse_errors) + "\n")
        print(f"Logged {len(all_parse_errors)} parse/simulation warning(s) to {parse_error_log_file}")

    all_rows = []
    merged_fieldnames = []
    for part_file in part_files:
        if os.path.exists(part_file):
            with open(part_file, "r", newline="") as part:
                reader = csv.DictReader(part, delimiter=";")
                if reader.fieldnames:
                    for fname in reader.fieldnames:
                        if fname not in merged_fieldnames:
                            merged_fieldnames.append(fname)
                    for row in reader:
                        all_rows.append(row)
            os.remove(part_file)

    total_target = len(pvt_combos) * nr_mc_sims
    print(f"Collected {len(all_rows)}/{total_target} valid runs | Skipped/failed: {total_skipped}")
    if total_skip_reasons:
        breakdown = ", ".join(f"{k}: {v}" for k, v in total_skip_reasons.most_common())
        print(f"Skip breakdown -> {breakdown}")

    if merged_fieldnames and all_rows:
        with open(final_result_file, "w", newline="") as out:
            writer = csv.DictWriter(out, fieldnames=merged_fieldnames, delimiter=";", restval="0.0")
            writer.writeheader()
            writer.writerows(all_rows)
    else:
        print("Error: No valid simulation results were collected. Check the error logs in " + run_results_dir)
        sys.exit(1)

    # Group rows by PVT corner and write PVT summary CSV + terminal summary
    meta_cols = {"pvt_corner", "process", "temp", "vdd", *extra_param_names}
    metric_cols = [c for c in merged_fieldnames if c not in meta_cols]
    numeric_metric_cols = [c for c in metric_cols if not is_status_column(c)]
    rows_by_corner: dict[str, list[dict]] = {cfg["label"]: [] for cfg in pvt_combos}
    for row in all_rows:
        rows_by_corner.setdefault(row["pvt_corner"], []).append(row)

    row_status_col = f"row_{status_columns_suffix}"
    has_row_status = row_status_col in metric_cols

    summary_rows = []
    summary_fields = ["pvt_corner", "process", "temp", "vdd", *extra_param_names, "n_valid", "n_skipped"]
    if has_row_status:
        summary_fields.extend(["n_passed", "n_failed", "pass_rate_pct"])
    for mc in numeric_metric_cols:
        if nr_mc_sims > 1:
            summary_fields.extend([f"{mc}_mean", f"{mc}_std", f"{mc}_min", f"{mc}_max"])
        else:
            summary_fields.append(mc)

    for cfg in pvt_combos:
        lbl = cfg["label"]
        c_rows = rows_by_corner.get(lbl, [])
        srow = {
            "pvt_corner": lbl,
            "process": cfg["process_disp"],
            "temp": cfg["temp_disp"],
            "vdd": cfg["vdd_disp"],
            "n_valid": len(c_rows),
            "n_skipped": skipped_by_corner[lbl],
        }
        for ek in extra_param_names:
            srow[ek] = cfg["extra_params"][ek]

        if has_row_status:
            n_pass = sum(1 for r in c_rows if str(r.get(row_status_col, "")).strip().upper() == pass_string)
            n_fail = sum(1 for r in c_rows if str(r.get(row_status_col, "")).strip().upper() == fail_string)
            srow["n_passed"] = n_pass
            srow["n_failed"] = n_fail
            srow["pass_rate_pct"] = f"{(n_pass / len(c_rows) * 100.0):.2f}" if c_rows else "nan"

        for mc in numeric_metric_cols:
            vals = [float(r[mc]) for r in c_rows if mc in r and r[mc] != ""]
            if not vals:
                if nr_mc_sims > 1:
                    srow[f"{mc}_mean"] = srow[f"{mc}_std"] = srow[f"{mc}_min"] = srow[f"{mc}_max"] = "nan"
                else:
                    srow[mc] = "nan"
            elif nr_mc_sims > 1:
                arr = np.array(vals, dtype=float)
                srow[f"{mc}_mean"] = f"{arr.mean():.6g}"
                srow[f"{mc}_std"] = f"{arr.std():.6g}"
                srow[f"{mc}_min"] = f"{arr.min():.6g}"
                srow[f"{mc}_max"] = f"{arr.max():.6g}"
            else:
                srow[mc] = f"{vals[0]:.6g}"
        summary_rows.append(srow)

    with open(pvt_summary_file, "w", newline="") as sf:
        writer = csv.DictWriter(sf, fieldnames=summary_fields, delimiter=";")
        writer.writeheader()
        writer.writerows(summary_rows)

    corner_order = [cfg["label"] for cfg in pvt_combos]
    print_terminal_summary(rows_by_corner, corner_order, metric_cols, results_plot_list, skipped_by_corner)

    render_all_plots(
        all_rows,
        rows_by_corner,
        corner_order,
        metric_cols,
        results_plot_list,
        run_results_dir,
        netlist_name,
        status_plot_type=args.status_plot,
        show_plots=True,
    )
    end_time = time.time()
    runtime = end_time - start_time
    hours = int(runtime // 3600)
    minutes = int((runtime % 3600) // 60)
    seconds = int(runtime % 60)
    print(f"\nResults folder: {run_results_dir}")
    print(f"Runtime: {hours:02}:{minutes:02}:{seconds:02}")


if __name__ == "__main__":
    main()