

`ifndef RISCV_SEQ_LIST 
`define RISCV_SEQ_LIST

package RISCV_seq_list;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import RISCV_agent_pkg::*;
  import RISCV_ref_model_pkg::*;
  import RISCV_env_pkg::*;

  /*
   * Including RISCV store sequence 
   */
  `include "RISCV_store_seq.sv"

endpackage

`endif
