/**
    PBL3 - Instruction Memory for RISC-V Single Cycle Processor
    Intruction Memory module

    file name: instruction_memory.sv 

    Objective:
        Implement a word-addressable instruction memory for RISC-V processor.
        The memory should initialize with a program and provide synchronous read access.
    
    Specification:
        - 1KB memory (256 words of 32 bits each)
        - Word-addressable (byte addresses converted to word addresses)
        - Asynchronous read (combinational output)
        - Initialized with program code at startup
        - PC input is byte-addressable but converted to word address by dropping last 2 bits

Functional Diagram

                    +---------------------------+
                    |         Module            |
                    |   INSTRUCTION MEMORY      |
                    |                           |
     i_pc[31:0] --->| Program Counter 32 bits   |                      |
                    |                           |
                    |                           |
                    |       Instruction 32 bits |---> o_instr[31:0]
                    |                           |
                    +---------------------------+
                
**/

//----------------------------------------------------------------------------- 
//  instruction Memory Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps
module instruction_memory #(
    parameter P_DATA_WIDTH = 32,                // Word size (4 bytes)
    parameter P_ADDR_WIDTH = 10                 // Byte address width (1024 bytes)
)(
    input  logic [P_ADDR_WIDTH-1:0] i_pc,       // 10-bit PC counter address
    output logic [P_DATA_WIDTH-1:0] o_instr     // 32-bit data instruction
);
    // 1KB memory: 256 words (32-bit each)
    logic [P_DATA_WIDTH-1:0] l_rom [0:255];     // 256 words = 2^8

    // Convert byte address to word address (divide by 4)
    assign o_instr = l_rom[i_pc[P_ADDR_WIDTH-1:2]];

endmodule