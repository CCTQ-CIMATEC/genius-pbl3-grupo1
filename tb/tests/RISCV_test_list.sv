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
  `include "RISCV_rtype_test.sv"
  `include "RISCV_and_test.sv"
  `include "RISCV_add_test.sv"
  `include "RISCV_sub_test.sv"
  `include "RISCV_xor_test.sv"
  `include "RISCV_or_test.sv"
  `include "RISCV_ori_test.sv"
  `include "RISCV_jalr_test.sv"
  `include "RISCV_beq_test.sv"
  `include "RISCV_bne_test.sv"
  `include "RISCV_blt_test.sv"
  `include "RISCV_bge_test.sv"
  `include "RISCV_bltu_test.sv"
  `include "RISCV_jal_test.sv"
  `include "RISCV_srai_test.sv"
  `include "RISCV_slt_test.sv"
  `include "RISCV_addi_test.sv"
  `include "RISCV_ori_test.sv"
  `include "RISCV_sll_test.sv" 
  `include "RISCV_slli_test.sv" 
  `include "RISCV_srl_test.sv" 
  `include "RISCV_slti_test.sv" 
  `include "RISCV_sltiu_test.sv" 
  `include "RISCV_sltu_test.sv" 
  `include "RISCV_srai_test.sv" 
  `include "RISCV_sw_test.sv" 
  `include "RISCV_sh_test.sv"  
  `include "RISCV_sb_test.sv"  
  `include "RISCV_lui_test.sv"
  `include "RISCV_auipc_test.sv"
  `include "RISCV_xori_test.sv"
  `include "RISCV_srli_test.sv"

endpackage 

`endif


