
`ifndef RISCV_REF_MODEL_PKG
`define RISCV_REF_MODEL_PKG

package RISCV_ref_model_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  /*
   * Importing packages: agent, ref model, register, etc.
   */
  import RISCV_agent_pkg::*;

  /*
   * Include ref model files 
   */
  `include "RISCV_ref_model.sv"

endpackage

`endif



