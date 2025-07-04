
`ifndef RISCV_ENV_PKG
`define RISCV_ENV_PKG

package RISCV_env_pkg;
   
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  /*
   * Importing packages: agent, ref model, register, etc.
   */
  import RISCV_agent_pkg::*;
  import RISCV_ref_model_pkg::*;

  /*
   * Include top env files 
   */
  `include "RISCV_coverage.sv"  
  `include "RISCV_scoreboard.sv"
  `include "RISCV_env.sv"

endpackage

`endif


