/**
    PBL3 - Register File for RISC-V Single Cycle Processor
    Register File module
    
    Objective:
        Implement a 32-register file for RISC-V processor with synchronous write
        and asynchronous read capabilities, following RISC-V specifications.

        Implements a general-purpose register file with synchronous write/async reset
    
    Specification:
        - 32 registers of 32 bits each
        - Register x0 hardwired to zero
        - Synchronous write on positive clock edge when write enable is asserted
        - Asynchronous read (combinational output)
        - Reset initializes all registers to zero
        - Register write to x0 is ignored (always remains zero)

    Operation:
        The register file operates as follows:
        1. Reset Phase:
            - When i_rst_n is low, all registers are asynchronously cleared to zero
            - This occurs immediately, independent of the clock signal

        2. Write Operation (Synchronous):
            - On rising clock edge (posedge i_clk) when:
                * i_reg_write is high AND
                * i_rd_addr is not zero (x0 cannot be written)
            - The value at i_rd_data is stored in register[i_rd_addr]
            - Write operation has priority over reset when both occur simultaneously

        3. Read Operation (Combinational):
            - Read address decoding occurs continuously
            - When i_rs1_addr/i_rs2_addr = 0: Outputs forced to zero (x0 constraint)
            - Otherwise: Outputs reflect current register contents
            - Implements write-first behavior: Newly written data appears immediately

        4. Special Cases:
            - Writing to x0 (address 0) is silently ignored
            - Reads from x0 always return zero
            - Simultaneous read/write to same register returns new data

    Functional Diagram

                       +---------------------------+
                       |         Module            |
                       |       REGISTER FILE       |
                       |                           |
     i_rs1_addr[4:0]-->| RS1 address               |
     i_rs2_addr[4:0]-->| RS2 address               |                      
     i_rd_addr[4:0] -->| RD address                |                      
     i_rd_data[31:0]-->| Write data                |                      
     i_reg_write    -->| Write enable              |                      
                       |                           |
                       |           RS1 data [31:0] |---> o_rs1_data[31:0] 
                       |           RS2 data [31:0] |---> o_rs2_data[31:0] |
                       +---------------------------+
                    
**/

//-----------------------------------------------------------------------------
// Register File Module (RISC-V style)
//-----------------------------------------------------------------------------
`timescale 1ns/1ps  // Simulation time unit = 1ns, precision = 1ps
module register_file #(
    parameter DATA_WIDTH = 32,  // Width of each register (default 32 bits)
    parameter ADDR_WIDTH = 5    // Number of address bits (default 5 for 32 regs)
)(
    // Clock and Reset
    input logic                  i_clk,       // System clock
    input logic                  i_rst_n,     // Active-low asynchronous reset
    
    // Control Signals
    input logic                  i_reg_write, // Register write enable
    
    // Address Inputs
    input logic [ADDR_WIDTH-1:0] i_rs1_addr,  // Read address port 1
    input logic [ADDR_WIDTH-1:0] i_rs2_addr,  // Read address port 2
    input logic [ADDR_WIDTH-1:0] i_rd_addr,   // Write address
    
    // Data Ports
    input logic [DATA_WIDTH-1:0] i_rd_data,   // Write data
    output logic [DATA_WIDTH-1:0] o_rs1_data, // Read data port 1
    output logic [DATA_WIDTH-1:0] o_rs2_data  // Read data port 2
);

    // Register Storage (2^ADDR_WIDTH registers of DATA_WIDTH bits each)
    logic [DATA_WIDTH-1:0] register_r [0:(1<<ADDR_WIDTH)-1];
    
    // Register Update Logic
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            // Asynchronous reset - clear all registers
            foreach (register_r[i]) register_r[i] <= '0;
        end
        else if (i_reg_write && (i_rd_addr != '0)) begin
            // Synchronous write operation (with x0 hardwired to zero check)
            register_r[i_rd_addr] <= i_rd_data;
        end
    end
    
    // Read Ports (combinational)
    // - Register x0 is always hardwired to zero in RISC-V
    // - Bypasses newly written data (write-first behavior)
    assign o_rs1_data = (i_rs1_addr == '0) ? '0 : register_r[i_rs1_addr];
    assign o_rs2_data = (i_rs2_addr == '0) ? '0 : register_r[i_rs2_addr];

endmodule