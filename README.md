# Matrix Multiplication Accelerator:

Hardware accelerator for multiplying a **4×8** matrix with an **8×4** matrix to produce a **4×4** output matrix.  
The project includes **SystemVerilog RTL**, **MATLAB/Python reference simulation & verification**, and **Yosys-based ASIC synthesis** with standard-cell library comparisons.

---

## What’s Included

- **SystemVerilog RTL**: modular architecture (control, input register file, MAC units, RAM interface, output logic)
- **Verification**:
  - RTL simulation (Vivado / EDA Playground)
  - Testbench with automated checking against **MATLAB-generated expected results**
  - Additional **Python/MATLAB** simulation utilities (reference model + data generation)
- **ASIC Synthesis (Yosys)**:
  - multi-run synthesis scripts
  - gate-level netlists for different optimization modes
  - area/cell breakdown and reports

---

## Interface Overview

The accelerator supports three operations:

### Reset
- Set `rst = 1`
- Reset stops ongoing work but **does not clear RAM**

### Compute (store result in RAM)
1. Ensure accelerator is idle (or reset)
2. Set `ram_slot` (0–31) to select the destination slot
3. Assert `start = 1`
4. Provide the input matrix **column-wise** on `in_data` during the `start` cycle and the next **31 cycles**
5. Computation starts automatically; `finish = 1` indicates completion

### Read Result (from RAM)
1. Ensure accelerator is idle
2. Set `ram_slot` to select the stored matrix
3. Set `start = 0`
4. Assert `read = 1`

Readout details:
- Output values are returned **column-wise**
- Each value takes **2 cycles**:
  - LSB half first, then MSB half
- Full readout duration: **32 cycles** (16 values × 2 cycles)

---

## Architecture

Key modules:

- `top_file.sv` — top-level integration
- `calc_asmd.sv` — control unit (ASMD)
- `ireg.sv` — input register file (32 × 8-bit, 1W + 4R)
- `mul.sv` — multipliers
- `mac_unit.sv` — accumulation stage
- `ram_mux.sv` — single-port RAM write multiplexing
- `output_logic.sv` — splits 18-bit values into 2×9-bit transfers
- `rom.sv` — coefficient/constant storage
- `RM_IHPSG13_1P_512x32_c2_bm_bist.v` — SRAM macro
- `RM_IHPSG13_1P_core_behavioral_bm_bist.v` — behavioral SRAM model

---


## Performance

Cycle breakdown (per multiply):

- Load input: **32 cycles**
- Compute + accumulate: **32 cycles**
- Write to RAM: **16 cycles**
- Optional readout: **32 cycles**

**Total (compute only): 80 cycles**  
**Total (compute + read): 112 cycles**

---

## ASIC Synthesis Notes (Yosys)

Synthesis was evaluated across:
- optimization modes: **speed / balanced / area**
- standard-cell libraries representing **slow / typical / fast** corners

The design is **memory dominated** (SRAM macro contributes the majority of total area), so library choice has a stronger impact than logic optimization flags.

Artifacts typically included:
- `multirun.ys`
- `netlist_speed.v`, `netlist_balanced.v`, `netlist_area.v`
- synthesis figures/reports under `figures/` and/or `synth/`

---

## License
MIT — see [LICENSE](LICENSE).

