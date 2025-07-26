//------------------------------------------------------------------------------
// Package for listing RISCV sequences
//------------------------------------------------------------------------------
// This package includes the basic sequence for the RISCV testbench.
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

  /*
   * Including RISCV store sequence 
   */
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
  `include "RISCV_jalr_seq.sv"
  `include "RISCV_beq_seq.sv"
  `include "RISCV_lb_seq.sv"
  `include "RISCV_lh_seq.sv"
  `include "RISCV_lw_seq.sv"
  `include "RISCV_lbu_seq.sv"
  `include "RISCV_lhu_seq.sv"


endpackage

`endif
