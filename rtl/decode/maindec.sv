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
        - Generates 12 control signals from 7-bit opcode
        - Pure combinational logic
-----------------------------------------------------------------------------*/

`timescale 1ns / 1ps
module maindec(
    input  logic [6:0] i_op,            // 7-bit opcode field
    input  logic [2:0] i_funct3,        // 3-bit funct3 field from instruction

    output logic [1:0] o_resultsrc,     // Result source selection
    output logic       o_memwrite,      // Memory write enable
    output logic       o_branch,        // Branch instruction flag
    output logic [1:0] o_alusrc,        // ALU source selection
    output logic       o_regwrite,      // Register write enable
    output logic       o_jump,          // Jump instruction flag
    output logic [2:0] o_immsrc,        // Immediate format selection
    output logic [1:0] o_aluop,         // ALU operation type
    output logic [2:0] o_f3             // NEW -> 00 = word, 01 = halfword, 10 = byte 
);

    always_comb begin   
        // Default values
        o_regwrite  = 1'b0;
        o_immsrc    = 3'b000;
        o_alusrc    = 2'b00;
        o_memwrite  = 1'b0;
        o_resultsrc = 2'b00;
        o_branch    = 1'b0;
        o_aluop     = 2'b00;
        o_jump      = 1'b0;
        o_f3 = 3'b010; // IS THE VALUE OF FUNCT3 FOR SW

        case (i_op)
            // Load Word (LW) - I-type
            7'b0000011: begin
                o_regwrite  = 1'b1;
                o_immsrc    = 3'b000;
                o_alusrc    = 2'b01;
                o_memwrite  = 1'b0;
                o_resultsrc = 2'b01;
                o_branch    = 1'b0;
                o_aluop     = 2'b00;
                o_jump      = 1'b0;
                o_f3 = i_funct3;
            end

            // Store Word (SW) - S-type
            7'b0100011: begin
                o_regwrite  = 1'b0;
                o_immsrc    = 3'b001;
                o_alusrc    = 2'b01;
                o_memwrite  = 1'b1;
                o_resultsrc = 2'b00;
                o_branch    = 1'b0;
                o_aluop     = 2'b00;
                o_jump      = 1'b0;
                o_f3 = i_funct3;
            end

            // R-type instructions
            7'b0110011: begin
                o_regwrite  = 1'b1;
                o_immsrc    = 3'b000;
                o_alusrc    = 2'b00;
                o_memwrite  = 1'b0;
                o_resultsrc = 2'b00;
                o_branch    = 1'b0;
                o_aluop     = 2'b10;
                o_jump      = 1'b0;
            end

            // Branch (e.g., BEQ, BNE, BLT, etc.) - B-type
            7'b1100011: begin
                o_regwrite  = 1'b0;
                o_immsrc    = 3'b010;
                o_alusrc    = 2'b00;
                o_memwrite  = 1'b0;
                o_resultsrc = 2'b00;
                o_branch    = 1'b1;
                o_aluop     = 2'b01;
                o_jump      = 1'b0;
            end

            // I-type ALU ops (e.g., ADDI)
            7'b0010011: begin
                o_regwrite  = 1'b1;
                o_immsrc    = 2'b000;
                o_alusrc    = 2'b01;
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
                o_alusrc    = 2'b00;
                o_memwrite  = 1'b0;
                o_resultsrc = 2'b10;
                o_branch    = 1'b0;
                o_aluop     = 2'b00;
                o_jump      = 1'b1;
            end

            // LUI
            7'b0110111: begin
                o_regwrite  = 1'b1;    
                o_immsrc    = 3'b100;  
                o_alusrc    = 2'b01;   
                o_memwrite  = 1'b0;    
                o_resultsrc = 2'b00;   
                o_branch    = 1'b0;    
                o_aluop     = 2'b00;   
                o_jump      = 1'b0;  
            end

            // AUIPC
            7'b0010111: begin
                o_regwrite  = 1'b1;
                o_immsrc    = 3'b100;
                o_alusrc    = 2'b11;
                o_memwrite  = 1'b0;
                o_resultsrc = 2'b00;
                o_branch    = 1'b0;
                o_aluop     = 2'b00;
                o_jump      = 1'b0;                  
            end

            // undefined
            default: begin
                o_regwrite  = 1'b0;
                o_immsrc    = 3'b000;
                o_alusrc    = 2'b00;
                o_memwrite  = 1'b0;
                o_resultsrc = 2'b00;
                o_branch    = 1'b0;
                o_aluop     = 2'b00;
                o_jump      = 1'b0;
            end
        endcase
    end


endmodule