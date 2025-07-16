/*-----------------------------------------------------------------------------
    PBL3 - RISC-V Single Cycle Processor  
    Instruction Memory Module

    File name: instrucmem.sv

    Objective:
        Implement a byte-addressable instruction memory for RISC-V processor.
        Provides read-only storage for program instructions with word-aligned access.

        A parameterized instruction memory module supporting configurable address space.

    Specification:
        - Configurable memory size via address width parameter
        - Word-aligned access (32-bit instructions)
        - Read-only operation (ROM behavior)
        - Byte address to word address conversion
        - Fully synthesizable (initialized as ROM)
-----------------------------------------------------------------------------*/

`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps
module instrucmem #(
    parameter P_DATA_WIDTH = 32,                // Word size (4 bytes)
    parameter P_ADDR_WIDTH = 11                 // Byte address width (1024 bytes)
)(
    input  logic [P_ADDR_WIDTH-1:0] i_pc,       // 10-bit PC counter address
    output logic [P_DATA_WIDTH-1:0] o_instr     // 32-bit data instruction
);
    // 1KB memory: 256 words (32-bit each)
    logic [P_DATA_WIDTH-1:0] l_rom [0:255];     // 256 words = 2^8
                                                // To access a 32-bit word in ROM, 
                                                // we need to ignore the 2 least s
                                                // ignificant bits by discarding 
                                                // the 2 LSBs (i_pc[1:0])

    // Convert byte address to word address (divide by 4)
    assign o_instr = l_rom[i_pc[P_ADDR_WIDTH-1:2]];

endmodule