/**
    PBL3 - RISC-V Single Cycle Processor  
    Top-Level Module (Testbench Integration)

    File name: top.sv

    Objective:
        Integration core for complete RISC-V processor implementation.
        Connects processor core with instruction and data memories.
        Provides testbench observation points for system verification.

    Specification:
        - Single-cycle RISC-V RV32I implementation
        - Harvard architecture (separate instruction/data memories)
        - 32-bit word-addressable memory interfaces
        - Active-high asynchronous reset
        - Testbench monitoring outputs

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
                    |  | IMEM   |  | DMEM   |   |
                    |  +--------+  +--------+   |
                    |                           |---> o_WriteData
                    |                           |---> o_DataAdr
                    |                           |---> o_MemWrite
                    +---------------------------+

    Signal Description:
        i_clk       - Global clock (50MHz typical)
        i_rst_p     - Active-high reset (asynchronous)
        o_WriteData - Data bus to memory (32-bit)
        o_DataAdr   - Memory address bus (32-bit)
        o_MemWrite  - Memory write strobe (active high)

    Memory Configuration:
        Instruction Memory (IMEM):
        - 1KB ROM (256x32-bit)
        - Read-only, asynchronous access
        - Pre-loaded with program code

        Data Memory (DMEM):
        - 1KB RAM (256x32-bit)
        - Synchronous writes
        - Asynchronous reads
        - Byte-addressable internally

    Processor Data Paths:
        1. Instruction Fetch:
           PC -> IMEM -> Processor
        
        2. Memory Access:
           Processor -> DMEM (load/store)
           DMEM -> Processor (read data)

    Testbench Monitoring:
        - All memory write operations observable
        - Full address/data bus visibility
        - Memory control signal monitoring

    Design Characteristics:
        - Single-cycle per instruction
        - No pipeline hazards
        - Fixed latency memory access
        - Pure combinational between registers

    Expansion Capabilities:
        - Memory-mapped I/O ports
        - Interrupt controller interface
        - Multi-cycle multiplier/divider
        - Cache interfaces
**/
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