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
  `include "RISCV_sw_seq.sv" 
  `include "RISCV_sh_seq.sv" 
  `include "RISCV_sb_seq.sv"  
  `include "RISCV_lui_seq.sv"
  `include "RISCV_auipc_seq.sv"

endpackage

`endif
