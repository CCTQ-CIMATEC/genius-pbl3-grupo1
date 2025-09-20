# P-RV32I Processor
A simple RISC-V processor implementation with a structured verification environment.

### Team members:
- David Machado
- Glenda Barbosa
- Ramylla Bezerra
- Paulo Paixão

## Source Organization
- **RTL Design**: Located in the `rtl/` directory.
- **Testbench Components**: Organized under `tb/` with subdirectories for agents, reference models, and top-level environment.
- **Source Lists**: Defined in `srclist/` for easy inclusion in simulation scripts.
- **doc**: Located in `doc/ `contains the conception and microarchitecture.

## Implementation Status

| Task | Progress |
| :--- | :--- |
| **Conception** | `[██████████] 100%` |
| **Microarchitecture** | `[██████████] 100%` |
| **RTL Design** | `[█████████░] 90%` |
| **TB Environment** | `[██████████] 100%` |
| **Functional Verification** | `[██████████] 100%` |
| **RTL Signoff** | `[░░░░░░░░░░] 0%` |

---

## How to run

### Step 1: Set up the environment
Before running the simulation, ensure that the required tools (Vivado or Vitis) are sourced. This sets up the necessary environment variables for the tools to function correctly.

```bash
$ source /opt/Xilinx/Vitis/2024.1/settings64.sh 
# or
$ source /opt/Xilinx/Vivado/2024.1/.settings64-Vivado.sh 
```

### Step 2: Run the simulation script
The `xrun.sh` script automates the process of compiling, elaborating, and simulating the design. Below are the common usage scenarios:

#### Run all tests
To run all tests in batch mode:
```bash
$ ../bin/xrun.sh -top RISCV_tb_top -vivado "--R"
```
- `-top RISCV_tb_top`: Specifies the top-level testbench module.
- `--vivado "--R"`: Runs the simulation in batch mode.

#### Open the GUI
To open the Vivado GUI for debugging:
```bash
$ ../bin/xrun.sh -top testbench_riscv_top --c -vivado "--g"
```
- `--c`: Cleans the build directory before running.
- `--vivado "--g"`: Opens the simulation in GUI mode.

#### Load a waveform structure
To load a specific waveform structure for analysis:
```bash
$ ../bin/xrun.sh -top RISCV_tb_top --c -vivado "--g -view RISCV_tb_top_sim.wcfg"
```
- `--vivado "--g -view RISCV_tb_top_sim.wcfg"`: Opens the GUI and loads the specified waveform configuration file.

#### Run a specific test
To run a specific test case:
```bash
$ ../bin/xrun.sh -top RISCV_tb_top --name_of_test RISCV_store_test --c -vivado "--g -view RISCV_tb_top_sim.wcfg"
```
- `--name_of_test RISCV_store_test`: Specifies the test case to run (default is `RISCV_store_test`).

### Step 3: Analyze results
- For batch mode, check the console output for pass/fail status and logs.
- For GUI mode, use the waveform viewer to debug and analyze signal activity.

### Notes
- The `--clean` option ensures a fresh build by removing intermediate files.
- The `--vivado` option allows passing additional parameters directly to Vivado for customization.

# Usage
```
xrun.sh [options]

Options:
  --t|-top <top_name>              Specify the top module name
  --N|-name_of_test <test_name>    Specify the test name (default: RISCV_store_test)
  --h|help                         Display this help message
  --c|-clean                       Clean build
  --v|-vivado <"--vivado_params">  Pass Vivado parameters

Use -v "--R" to run all, --v "--g" to gui, and --v "--g -view top_sim.wcfg" to load waveforms
```

## License

This project is distributed under the BSD license. Refer to the `LICENSE` file for details.
