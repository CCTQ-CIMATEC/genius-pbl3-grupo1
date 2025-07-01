`ifndef RISCV_TB_TOP
`define RISCV_TB_TOP
`include "uvm_macros.svh"
`include "RISCV_interface.sv"
import uvm_pkg::*;
import riscv_definitions::*; 

module RISCV_tb_top;
   
import RISCV_test_list::*;

/*
 * Local parameter declarations
 * Usando os parâmetros do definitions do seu colega
 */
localparam REG_ADDR = 5;
localparam DATA_WIDTH = 32;
localparam REG_COUNT = 32;
localparam RAM_AMOUNT = 4;

// Parâmetros para a interface (compatibilidade)
parameter P_DATA_WIDTH = DATA_WIDTH;
parameter P_IMEM_ADDR_WIDTH = 9;
parameter P_DMEM_ADDR_WIDTH = 8;

parameter cycle = 10;
bit clk;
bit reset;

/*
 * Clock generation process
 * Generates a clock signal with a period defined by the cycle parameter.
 */
initial begin
  clk = 0;
  forever #(cycle/2) clk = ~clk;
end

/*
 * Reset generation process
 * Generates a reset signal that is asserted for a few clock cycles.
 */
initial begin
   reset <= 0;   // Assert reset (active low)
   #10;          // Hold reset for 10ns
   reset <= 1;   // Release reset
end

/*
 * Instantiate interface to connect DUT and testbench elements
 * The interface connects the DUT to the testbench components.
 */
RISCV_interface #(
       .P_DATA_WIDTH(P_DATA_WIDTH),
       .P_IMEM_ADDR_WIDTH(P_IMEM_ADDR_WIDTH),
       .P_DMEM_ADDR_WIDTH(P_DMEM_ADDR_WIDTH)
) RISCV_intf(clk, reset);

/*
 * DUT instantiation for RISCV (core do seu colega)
 * Instantiates the RISCV DUT and connects it to the interface signals.
 */
RISCV u_riscv_core (
    .clk                (clk),
    .rst_n              (reset),
    
    // Instruction Memory Interface
    .i_instr_ready      (RISCV_intf.instr_ready),      // Instruction memory ready
    .i_instr_data       (RISCV_intf.instr_data),       // Instruction memory data
    .o_inst_rd_en       (RISCV_intf.inst_rd_en),       // Enable instruction memory read
    .o_inst_addr        (RISCV_intf.inst_addr),        // PC address to fetch instruction
    
    // Data Memory Interface  
    .i_data_ready       (RISCV_intf.data_ready),       // Data memory ready
    .i_data_rd          (RISCV_intf.data_rd),          // Data memory read data
    .o_data_wr          (RISCV_intf.data_wr),          // Data memory write data
    .o_data_addr        (RISCV_intf.data_addr),        // Data memory address
    .o_data_rd_en_ctrl  (RISCV_intf.data_rd_en_ctrl),  // Control for data memory read
    .o_data_rd_en_ma    (RISCV_intf.data_rd_en_ma),    // Enable data memory read (memory access)
    .o_data_wr_en_ma    (RISCV_intf.data_wr_en_ma)     // Enable data memory write (memory access)
);

/*
 * Start UVM test phases
 * Initiates the UVM test phases.
 */
initial begin
  run_test();
end

/*
 * Set the interface instance in the UVM configuration database
 * Registers the interface instance with the UVM configuration database.
 */
initial begin
  uvm_config_db#(virtual RISCV_interface)::set(uvm_root::get(), "*", "intf", RISCV_intf);
end

endmodule
`endif