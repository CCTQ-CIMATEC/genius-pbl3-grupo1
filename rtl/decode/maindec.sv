/*-----------------------------------------------------------------------------
    PBL3 - RISC-V Single Cycle Processor
    Main Control Decoder Module

    File name: maindec.sv
    Usage: controller.sv

    Objective:
        Decode RISC-V instruction opcodes into control signals for the datapath.
        Generates all primary control signals for the single-cycle processor.

    Specification:
        - Supports RV32I base instruction subset
        - Decodes all major instruction formats (R, I, S, B, J)
        - Generates 11 control signals from 7-bit opcode
        - Pure combinational logic

    Operation:
        - Decodes 7-bit opcode into 11-bit control vector
        - Splits control vector into individual signals
        - Handles undefined opcodes with '0' outputs
-----------------------------------------------------------------------------*/

`timescale 1ns / 1ps
module maindec(
    input  logic [6:0] i_op,           // 7-bit opcode field
    output logic [1:0] o_resultsrc,    // Result source selection
    output logic       o_memwrite,     // Memory write enable
    output logic       o_branch,       // Branch instruction flag
    output logic       o_alusrc,       // ALU source selection
    output logic       o_regwrite,     // Register write enable
    output logic       o_jump,         // Jump instruction flag
    output logic [1:0] o_immsrc,       // Immediate format selection
    output logic [1:0] o_aluop         // ALU operation type
);

    always_comb begin   
        // Default values
        o_regwrite  = 1'b0;
        o_immsrc    = 2'b00;
        o_alusrc    = 1'b0;
        o_memwrite  = 1'b0;
        o_resultsrc = 2'b00;
        o_branch    = 1'b0;
        o_aluop     = 2'b00;
        o_jump      = 1'b0;

        case (i_op)
            // Load Word (LW) - I-type
            7'b0000011: begin
                o_regwrite  = 1'b1;
                o_immsrc    = 2'b00;
                o_alusrc    = 1'b1;
                o_memwrite  = 1'b0;
                o_resultsrc = 2'b01;
                o_branch    = 1'b0;
                o_aluop     = 2'b00;
                o_jump      = 1'b0;
            end

            // Store Word (SW) - S-type
            7'b0100011: begin
                o_regwrite  = 1'b0;
                o_immsrc    = 2'b01;
                o_alusrc    = 1'b1;
                o_memwrite  = 1'b1;
                o_resultsrc = 2'b00;
                o_branch    = 1'b0;
                o_aluop     = 2'b00;
                o_jump      = 1'b0;
            end

            // R-type instructions
            7'b0110011: begin
                o_regwrite  = 1'b1;
                o_immsrc    = 2'b00;
                o_alusrc    = 1'b0;
                o_memwrite  = 1'b0;
                o_resultsrc = 2'b00;
                o_branch    = 1'b0;
                o_aluop     = 2'b10;
                o_jump      = 1'b0;
            end

            // Branch (e.g., BEQ, BNE, BLT, etc.) - B-type
            7'b1100011: begin
                o_regwrite  = 1'b0;
                o_immsrc    = 2'b10;
                o_alusrc    = 1'b0;
                o_memwrite  = 1'b0;
                o_resultsrc = 2'b00;
                o_branch    = 1'b1;
                o_aluop     = 2'b01;
                o_jump      = 1'b0;
            end

            // I-type ALU ops (e.g., ADDI)
            7'b0010011: begin
                o_regwrite  = 1'b1;
                o_immsrc    = 2'b00;
                o_alusrc    = 1'b1;
                o_memwrite  = 1'b0;
                o_resultsrc = 2'b00;
                o_branch    = 1'b0;
                o_aluop     = 2'b10;
                o_jump      = 1'b0;
            end

            // JAL - Jump and Link
            7'b1101111: begin
                o_regwrite  = 1'b1;
                o_immsrc    = 2'b11;
                o_alusrc    = 1'b0;
                o_memwrite  = 1'b0;
                o_resultsrc = 2'b10;
                o_branch    = 1'b0;
                o_aluop     = 2'b00;
                o_jump      = 1'b1;
            end

            // undefined or unsupported opcode
            default: begin
                o_regwrite  = 1'b0;
                o_immsrc    = 2'b00;
                o_alusrc    = 1'b0;
                o_memwrite  = 1'b0;
                o_resultsrc = 2'b00;
                o_branch    = 1'b0;
                o_aluop     = 2'b00;
                o_jump      = 1'b0;
            end
        endcase
    end


endmodule