`ifndef RISCV_INTERFACE
`define RISCV_INTERFACE

interface RISCV_interface
#(
    parameter P_DATA_WIDTH = 32,
    parameter P_IMEM_ADDR_WIDTH = 32,  // Alterado para 32
    parameter P_DMEM_ADDR_WIDTH = 32    // Alterado para 32
)
(input logic clk, reset);

  // Declaração de sinais

  // Interface memória de instrução (para DUT)
  logic [P_DATA_WIDTH-1:0] instr_data;
  logic [P_IMEM_ADDR_WIDTH-1:0] inst_addr;

  // Interface memória de dados (para DUT)
  logic [P_DATA_WIDTH-1:0] data_rd;
  logic [P_DATA_WIDTH-1:0] data_wr;
  logic [P_DMEM_ADDR_WIDTH-1:0] data_addr;
  logic data_wr_en_ma;

  // Novos sinais
  logic instr_ready;
  logic data_ready;
  logic inst_rd_en;
  logic [3:0] inst_ctrl_cpu;
  logic [3:0] data_rd_en_ctrl;
  logic data_rd_en_ma;

  // Clocking block para driver
  clocking dr_cb @(posedge clk);
    output instr_data;
    output data_rd;
    input  inst_addr; 
    input  data_wr;
    input  data_addr;
    input  data_wr_en_ma;

    input  instr_ready;
    input  data_ready;
    input  inst_rd_en;
    input  inst_ctrl_cpu;
    input  data_rd_en_ctrl;
    input  data_rd_en_ma;
  endclocking

  modport drv (clocking dr_cb, input clk, reset);

  // Clocking block para monitor
  clocking rc_cb @(negedge clk);
    input instr_data;
    input data_rd;
    input inst_addr; 
    input data_wr;
    input data_addr;
    input data_wr_en_ma;

    input instr_ready;
    input data_ready;
    input inst_rd_en;
    input inst_ctrl_cpu;
    input data_rd_en_ctrl;
    input data_rd_en_ma;
  endclocking

  modport rcv (clocking rc_cb, input clk, reset);

endinterface

`endif
