
`ifndef RISCV_TEST_LIST 
`define RISCV_TEST_LIST

package RISCV_test_list;

  import uvm_pkg::*; // pacote do macro
  `include "uvm_macros.svh"

  import RISCV_env_pkg::*;
  import RISCV_seq_list::*;

  // Including basic test definition
  `include "RISCV_sw_test.sv" 
  `include "RISCV_sh_test.sv" 
  `include "RISCV_sb_test.sv" 
  `include "RISCV_lui_test.sv"
  `include "RISCV_auipc_test.sv"


endpackage 

`endif