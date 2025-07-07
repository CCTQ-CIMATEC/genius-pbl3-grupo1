/*----------------------------------------------------------------------------- 
    PBL3 - RISC-V Single Cycle Processor  
    Data Memory Module

    File name: datamemory.sv
    Usage: rtl/riscv_top.sv

    Description:
        A parameterized RAM module with single read/write port and word-addressable access.on.

    Specification:
        - 
-----------------------------------------------------------------------------*/

`timescale 1ns / 1ps

module data_memory #(
    parameter P_ADDR_WIDTH = 11,
    parameter P_DATA_WIDTH = 32
)(
    input  logic                i_clk,         
    input  logic                i_we,        
    input  logic [P_ADDR_WIDTH-1:0] i_addr,     
    input  logic [P_DATA_WIDTH-1:0] i_wdata,    
    output logic [P_DATA_WIDTH-1:0] o_rdata   
);

    logic [P_DATA_WIDTH-1:0] mem_r [0:2**(P_ADDR_WIDTH)]; 


    assign o_rdata = mem_r[i_addr];

    always_ff @(posedge i_clk) begin
        if (i_we) begin
            mem_r[i_addr] <= i_wdata;
        end
    end

endmodule