
`ifndef RISCV_REF_MODEL_PKG
`define RISCV_REF_MODEL_PKG

package RISCV_ref_model_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  /*
   * Importing packages: agent, ref model, register, etc.
   */
  import RISCV_agent_pkg::*;
  typedef struct {
    bit [4:0]  rd;
    bit [31:0] value;
    bit        we;
  } wb_info_t;
  `include "RISCV_ref_model.sv"

endpackage

`endif



