
`ifndef RISCV_TEST_LIST 
`define RISCV_TEST_LIST

package RISCV_test_list;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import RISCV_env_pkg::*;
  import RISCV_seq_list::*;

  /*
   * Including basic test definition
   */
  `include "RISCV_store_test.sv"
  `include "RISCV_andi_test.sv" 
  `include "RISCV_ori_test.sv"
  `include "RISCV_xori_test.sv"


endpackage 

`endif





