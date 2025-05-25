/**
    File name: data_memory.sv

    Objective:
        Implement a synchronous data memory module for the RISC-V processor
        with configurable address and data widths.

    Specification:
        - Synchronous write, asynchronous read
        - Configurable memory size through parameters
        - Word-addressable interface (32-bit data)
        - Supports single-cycle read/write operations
        - Initialized to all zeros on power-up

    Functional Diagram:

                    +---------------------------+
                    |                           |
                    |       DATA MEMORY         |
                    |                           |
        i_clk   --->|                           |
        i_we    --->|                           |
        i_addr  --->|                           |
        i_wdata --->|                           |
                    |                           |---> o_rdata
                    +---------------------------+

    Parameters:
        P_ADDR_WIDTH - Address bus width (default: 8 = 256 words)
        P_DATA_WIDTH - Data bus width (default: 32 bits)

    Inputs:
        i_clk      - System clock (posedge triggered)
        i_we       - Write enable (active high)
        i_addr     - Word address input [P_ADDR_WIDTH-1:0]
        i_wdata    - Data input [P_DATA_WIDTH-1:0]

    Outputs:
        o_rdata    - Data output [P_DATA_WIDTH-1:0] (asynchronous read)

    Operation:
        - Reads occur combinatorially when address changes
        - Writes occur on rising clock edge when i_we is high
**/

//----------------------------------------------------------------------------- 
//  Data Memoory Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps
module data_memory #(
    parameter P_ADDR_WIDTH = 8,                  // Address bus width (default: 8 bits = 256 words)
    parameter P_DATA_WIDTH = 32                  // Data bus width (default: 32 bits per word)
)(
    input  logic                    i_clk,       // System clock (posedge triggered)
    input  logic                    i_we,        // Write enable (active high; 1 = write, 0 = read)
    input  logic [P_ADDR_WIDTH-1:0] i_addr,      // Word address input (unsigned, 0 to 2**P_ADDR_WIDTH-1)
    input  logic [P_DATA_WIDTH-1:0] i_wdata,     // Data input to be written (on write operation)
    output logic [P_DATA_WIDTH-1:0] o_rdata      // Data output (asynchronous read; updates immediately on i_addr change)
);

    // Memory array declaration:
    // - Depth: 2^P_ADDR_WIDTH words (e.g., 256 for P_ADDR_WIDTH=8)
    // - Width: P_DATA_WIDTH bits per word (e.g., 32 bits)
    logic [P_DATA_WIDTH-1:0] r_mem [0:2**(P_ADDR_WIDTH)-1];  // Index from 0 to 2^N-1

    // Asynchronous read: Output reflects mem_r[i_addr] combinatorially
    assign o_rdata = r_mem[i_addr];

    // Synchronous write (clocked):
    always_ff @(posedge i_clk) begin
        if (i_we) begin                  // Write only if i_we=1
            mem_r[i_addr] <= i_wdata;    // Store i_wdata at address i_addr
        end
    end

endmodule