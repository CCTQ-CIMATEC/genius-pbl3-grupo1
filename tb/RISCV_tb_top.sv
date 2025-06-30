
`ifndef RISCV_TB_TOP
`define RISCV_TB_TOP
`include "uvm_macros.svh"
`include "RISCV_interface.sv"
import uvm_pkg::*;

module RISCV_tb_top;
   
  
import RISCV_test_list::*;

localparam REG_ADDR = 5;
localparam DATA_WIDTH = 32;
localparam REG_COUNT = 32;
localparam RAM_AMOUNT = 4;

 parameter cycle = 10;
 bit clk;
 bit reset;