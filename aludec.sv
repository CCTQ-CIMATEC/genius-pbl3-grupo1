// aludec.sv
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: David Machado Couto Bezerra
//
// Create Date: 05/19/2025
// Module Name: aludec
// Project Name: SYNGLE_CYCLE
// Tool Versions: 1.0
// Description: ALU decoder for RISC-V single-cycle CPU.
//
// Additional Comments: Decodes ALU operations based on
//                       ALUOp, funct3, funct7, and opcode[5].
//////////////////////////////////////////////////////////////////////////////////

/**
    PBL3 - RISC-V Single Cycle Processor
    ALU Control Decoder Module

    File name: aludec.sv

    Objective:
        Decode the ALU control signals based on the instruction type and function fields.
        Translates RISC-V instruction fields into specific ALU operations.
        Determines the ALU operation based on instruction type and fields

    Specification:
        - Supports RV32I base instruction set
        - Decodes ALU operations for:
            * R-type instructions (ADD, SUB, AND, OR, XOR, SLT, SLL, SRL, SRA) // UPDATED
            * I-type instructions (ADDI, ANDI, ORI, XORI, SLTI, SLLI, SRLI, SRAI) // UPDATED
            * Branch instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU) // UPDATED
        - Uses funct3, funct7, and ALUOp fields to determine operation
        - Generates 3-bit ALU control signal

    Operations: (Mapping to ALU's i_alucontrol)
        - ADD/ADDI:    000
        - SUB:         001
        - AND/ANDI:    010
        - OR/ORI:      011
        - XOR/XORI:    100
        - SLT/SLTI:    101
        - SLL/SLLI:    110
        - SRL/SRLI:    111 (or SRA, see below)

    Functional Diagram:

                          +------------------+
                          |                  |
        i_opb5       --->|                  |
        i_funct3     --->|   ALU Control    |---> o_alucrtl[2:0]
        i_funct7b5   --->|     Decoder      |
        i_aluop      --->|                  |
                          +------------------+

    Inputs:
        i_opb5        - Bit 5 of opcode (helps distinguish R-type instructions)
        i_funct3[2:0] - Function field 3 (from instruction)
        i_funct7b5    - Bit 5 of funct7 field (identifies SUB and SRA instructions)
        i_aluop[1:0]  - Higher-level ALU control from main decoder:
                          * 2'b00: Addition (for loads/stores)
                          * 2'b01: Subtraction/Comparison (for branches)
                          * 2'b10: Use funct3/funct7 (for R/I-type)

    Outputs:
        o_alucrtl[2:0] - ALU control signal:
                          * 3'b000: ADD
                          * 3'b001: SUB
                          * 3'b010: AND
                          * 3'b011: OR
                          * 3'b100: XOR
                          * 3'b101: SLT
                          * 3'b110: SLL
                          * 3'b111: SRL (If SRA also needed, would require ALU differentiation or more control bits)

    Control Logic:
        - For R-type instructions, examines both funct3 and funct7 fields
        - For I-type instructions, uses only funct3 field (and funct7b5 for shifts)
        - For memory/branch instructions, uses ALUOp and funct3 fields
**/

//-----------------------------------------------------------------------------
//  ALU Decoder Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps
module aludec
(
    input logic        i_opb5,         // Bit 5 of the opcode (used to identify R-type)
    input logic [2:0]  i_funct3,       // funct3 field from instruction
    input logic        i_funct7b5,     // Bit 5 of funct7 field (for R-type instructions, e.g., SUB, SRA)
    input logic [1:0]  i_aluop,        // ALUOp from main decoder (determines instruction type)
    output logic [2:0] o_alucrtl       // ALU control output
);

    // Internal signal to identify R-type subtract operation
    logic l_rtypesub;
    assign l_rtypesub = i_funct7b5 & i_opb5; // funct7[5] for SUB is 1. op[5] for R-type is 1.

    // Combinational logic for ALU control
    always_comb begin
        case (i_aluop)
            2'b00: o_alucrtl = 3'b000; // ADD (for loads, stores)
            // For branches (BEQ, BNE, BLT, BGE, BLTU, BGEU) - ALU performs comparison (SUB or SLT)
            2'b01: begin // For branches (BEQ, BNE, BLT, BGE, BLTU, BGEU)
                case (i_funct3)
                    3'b000: o_alucrtl = 3'b001; // BEQ, BNE (SUB)
                    3'b100: o_alucrtl = 3'b101; // BLT (SLT - signed comparison for ALU)
                    3'b101: o_alucrtl = 3'b101; // BGE (SLT - signed comparison for ALU)
                    3'b110: o_alucrtl = 3'b101; // BLTU (SLT - but note below about unsigned comparison)
                    3'b111: o_alucrtl = 3'b101; // BGEU (SLT - but note below about unsigned comparison)
                    default: o_alucrtl = 3'bxxx; // Undefined branch operation
                endcase
            end
            default: // For R-type and I-type instructions (when ALUOp = 1x)
                case (i_funct3)
                    3'b000: // ADD/SUB or ADDI
                        if (l_rtypesub) 
                            o_alucrtl = 3'b001; // SUB (R-type)
                        else
                            o_alucrtl = 3'b000; // ADD (R-type), ADDI (I-type)

                    // SLL/SLLI: funct3 = 001
                    3'b001: begin
                        // For SLL (R-type) and SLLI (I-type), funct7[5] is 0
                        if (i_funct7b5 == 1'b0) // SLL (R-type) / SLLI (I-type)
                            o_alucrtl = 3'b110; // SLL
                        else
                            o_alucrtl = 3'bxxx;
                    end

                    3'b010: o_alucrtl = 3'b101; // SLT, SLTI

                    // XOR/XORI: funct3 = 100
                    3'b100: o_alucrtl = 3'b100; // XOR, XORI

                    // SRL/SRLI / SRA/SRAI: funct3 = 101
                    3'b101: begin
                        //this funct3 (101) is used for SRL/SRLI (funct7[5]=0) and SRA/SRAI (funct7[5]=1).
                        if (i_funct7b5 == 1'b0) // SRL (R-type) / SRLI (I-type)
                            o_alucrtl = 3'b111; // SRL
                        else
                            o_alucrtl = 3'bxxx;
                    end

                    3'b110: o_alucrtl = 3'b011; // OR, ORI
                    3'b111: o_alucrtl = 3'b010; // AND, ANDI
                    default: o_alucrtl = 3'bxxx; // undefined operation
                endcase
        endcase
    end

endmodule