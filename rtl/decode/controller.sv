/*-----------------------------------------------------------------------------
    PBL3 - RISC-V PIPELINE Processor
    Controller Module

    File name: controller.sv    
    Usage: decode_state.sv

    Objective:
       Implements the main control unit and ALU control logic for a RISC-V processor.
       Generates all control signals based on the instruction opcode and funct fields.

    Description:
       - Decodes RISC-V instructions to produce control signals
       - Uses a main decoder for primary control signals
       - Uses an ALU decoder for ALU operation control
       - Combines branch and zero conditions for PC source control
-----------------------------------------------------------------------------*/

`timescale 1ns / 1ps
module controller(
    input logic [6:0] i_op,             // 7-bit opcode
    input logic [2:0] i_funct3,         // 3-bit funct3
    input logic       i_funct7b5,       // funct7 bit 5
    
    output alu_op_t    o_alucrtl,       // 3-bit ALU control signal
    output logic [1:0] o_resultsrc,     // Result multiplexer select (for writeback)
    output logic [2:0] o_immsrc,        // Immediate format select
    output logic       o_memwrite,      // Data memory write enable
    output logic [1:0] o_alusrc,        // ALU source select (reg/immediate/pc)
    output logic       o_regwrite,      // Register file write enable
    output logic       o_jump,          // Jump instruction flag
    output logic       o_branch,

    output logic [2:0] o_f3             // NEW -> 00 = word, 01 = halfword, 10 = byte      
);
    
    logic [1:0] r_aluop;                // ALU operation type from main decoder
    logic       l_opb5;                 // Opcode bit 5

    // Main decoder
    maindec md (
        .i_op           (i_op),         // Instruction opcode
        .i_funct3       (i_funct3),     // NEW -> SH, SB
        .o_resultsrc    (o_resultsrc),  // Result source
        .o_memwrite     (o_memwrite),   // Memory write enable
        .o_branch       (o_branch),     // Branch instruction
        .o_alusrc       (o_alusrc),     // ALU source select
        .o_regwrite     (o_regwrite),   // Register write enable
        .o_jump         (o_jump),       // Jump instruction
        .o_immsrc       (o_immsrc),     // Immediate format
        .o_aluop        (r_aluop),      // ALU operation type
        .o_f3    (o_f3)
    );

    // ALU decoder
    aludec ad(
        .i_opb5     (l_opb5),           // Opcode bit 5
        .i_funct3   (i_funct3),         // funct3 field
        .i_funct7b5 (i_funct7b5),       // funct7 bit 5
        .i_aluop    (r_aluop),          // ALU operation type
        .o_alucrtl  (o_alucrtl)         // ALU control output
    );

    // Extract opcode bit 5
    assign l_opb5 = i_op[5];

endmodule