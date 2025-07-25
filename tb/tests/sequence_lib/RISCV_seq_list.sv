//------------------------------------------------------------------------------
// Package for listing RISCV sequences
//------------------------------------------------------------------------------
// This package includes the basic sequence for the RISCV seqbench.
//
// Author: Glenda & Thor
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SEQ_LIST 
`define RISCV_SEQ_LIST

package RISCV_seq_list;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import RISCV_agent_pkg::*;
  import RISCV_ref_model_pkg::*;
  import RISCV_env_pkg::*;

  `include "RISCV_store_seq.sv"
  `include "RISCV_rtype_seq.sv"
  `include "RISCV_and_seq.sv"
  `include "RISCV_add_seq.sv"
  `include "RISCV_sub_seq.sv"
  `include "RISCV_xor_seq.sv"
  `include "RISCV_or_seq.sv"
  `include "RISCV_slt_seq.sv"
  `include "RISCV_addi_seq.sv"
  `include "RISCV_ori_seq.sv"
  `include "RISCV_sll_seq.sv" 
  `include "RISCV_slli_seq.sv" 
  `include "RISCV_srl_seq.sv" 
  `include "RISCV_slti_seq.sv" 
  `include "RISCV_sltiu_seq.sv" 
  `include "RISCV_sltu_seq.sv" 
  `include "RISCV_slt_seq.sv"
  `include "RISCV_addi_seq.sv"
  `include "RISCV_ori_seq.sv"
  `include "RISCV_jalr_seq.sv"
  `include "RISCV_beq_seq.sv"
  `include "RISCV_bne_seq.sv"
  `include "RISCV_blt_seq.sv"
  `include "RISCV_bltu_seq.sv"
  `include "RISCV_bge_seq.sv"
  `include "RISCV_jal_seq.sv"
  `include "RISCV_srai_seq.sv" 

  `include "RISCV_sw_seq.sv" 
  `include "RISCV_sh_seq.sv"  
  `include "RISCV_sb_seq.sv"  
  `include "RISCV_lui_seq.sv"
  `include "RISCV_auipc_seq.sv"
  `include "RISCV_xori_seq.sv"
  `include "RISCV_srli_seq.sv"
  

endpackage

`endif
