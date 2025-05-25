/**
    PBL3 - RISC-V Single Cycle Processor
    Top-level module for RISC-V processor for testbench
    File name: top.sv

    Objective:
        Implement a testbench for the RISC-V single cycle processor that:
        - Connects the processor to instruction and data memories
        - Provides clock and reset signals
        - Monitors memory write operations

    Specification:
        - Instantiates the RISC-V single cycle processor core
        - Contains separate instruction and data memories (1KB each)
        - Word-addressable memory interfaces
        - Passes through all processor signals for observation

    Functional Diagram:

                    +---------------------------+
                    |                           |
                    |        TOP MODULE         |
                    |                           |
         i_clk  --->|  +---------------------+  |
         i_rst  --->|  |  RISC-V PROCESSOR   |  |
                    |  +---------------------+  |
                    |         |          |      |
                    |         v          v      |
                    |  +--------+  +--------+   |
                    |  | IMEM    |  | DMEM   |  |
                    |  +--------+  +--------+   |
                    |                           |---> o_WriteData
                    |                           |---> o_DataAdr
                    |                           |---> o_MemWrite
                    +---------------------------+

    Inputs:
        i_clk      - System clock
        i_rst      - Asynchronous reset active high

    Outputs:
        o_WriteData - 32-bit data to be written to data memory
        o_DataAdr   - 32-bit data memory address
        o_MemWrite  - Data memory write enable signal
*/

//----------------------------------------------------------------------------- 
//  Top-level module for RISC-V processor for Testbench
//-----------------------------------------------------------------------------
`timescale 1ns/1ps  // Simulation time unit = 1ns, precision = 1ps
module top (
    // Inputs
    input  logic        i_clk,          // System clock
    input  logic        i_rst_p,        // Asynchronous reset active high

    //Outputs
    output logic [31:0] o_WriteData,    // 2-bit data to be written to data memory
    output logic [31:0] o_DataAdr,      // 32-bit data memory address
    output logic        o_MemWrite      // Data memory write enable signal
);

    // Internal signals
    logic [31:0] l_PC, l_Instr, l_ReadData;

    // Instantiate processor
    riscvsingle rvsingle (
        .i_clk       (i_clk),           // System clock
        .i_rst_p     (i_rst_p),         // Active-high asynchronous reset   
        .i_Instr     (l_Instr),         // 32-bit instruction from memory
        .i_ReadData  (l_ReadData),      // 32-bit data from data memory     
        .o_PC        (l_PC),            // 32-bit program counter (next instruction address)
        .o_MemWrite  (o_MemWrite),      // Memory write enable signal
        .o_ALUResult (o_DataAdr),       // 32-bit ALU computation result
        .o_WriteData (o_WriteData)      // 32-bit data to be written to memory
    );

    // Instruction Memory (1KB, word-addressable)
    instrucmem imem (
        .i_pc     (l_PC),               // 10-bit PC counter address
        .o_instr  (l_Instr)             // 32-bit data instruction
    );

    // Data Memory (1KB, word-addressable)
    datamemory dmem (
        .i_clk    (i_clk),
        .i_we     (o_MemWrite),
        .i_addr   (o_DataAdr),          // Convert byte address to word address
        .i_wdata  (o_WriteData),
        .o_rdata  (l_ReadData)
    );

endmodule




module top (
    input  logic        i_clk,
    input  logic        i_rst,
    output logic [31:0] o_WriteData,
    output logic [31:0] o_DataAdr,
    output logic        o_MemWrite
);

    // Internal signals
    logic [31:0] l_PC, l_Instr, l_ReadData;

    // Instantiate processor
    riscvsingle rvsingle (
        .clk       (i_clk),
        .reset     (i_rst),
        .PC        (l_PC),
        .Instr     (l_Instr),
        .MemWrite  (o_MemWrite),
        .ALUResult (o_DataAdr),
        .WriteData (o_WriteData),
        .ReadData  (l_ReadData)
    );

    // Instruction Memory (1KB, word-addressable)
    instruction_memory imem (
        .i_pc     (l_PC),        // Convert byte address to word address
        .o_instr  (l_Instr)
    );

    // Data Memory (1KB, word-addressable)
    data_memory dmem (
        .i_clk    (i_clk),
        .i_we     (o_MemWrite),
        .i_addr   (o_DataAdr),   // Convert byte address to word address
        .i_wdata  (o_WriteData),
        .o_rdata  (l_ReadData)
    );

endmodule