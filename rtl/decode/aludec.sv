/*-----------------------------------------------------------------------------
    PBL3 - RISC-V PIPELINE Processor
    ALU Decoder file

    File name: aludec.sv
    Usage: rtl/decode/controller.sv

    Objective:
        Creates the control o_alucrtl to indicate the operation to take place
        on the ALU according to the instruction
-----------------------------------------------------------------------------*/`timescale 1ns / 1ps

import cpu_pkg::*;

module aludec
(
    input  logic         i_opb5,        // Bit 5 of the opcode
    input  logic [2:0]   i_funct3,      // funct3 field from instruction
    input  logic         i_funct7b5,    // Bit 5 of funct7 field
    input  logic [1:0]   i_aluop,       // ALUOp from main decoder
    output alu_op_t      o_alucrtl      // 4-bit ALU control output
);

    // identify R-type subtract operation
    logic l_rtypesub;
    assign l_rtypesub = i_funct7b5 & i_opb5;


    always_comb begin
        case (i_aluop)
            2'b00: o_alucrtl = ALU_ADD;  // ADD -> LOAD AND STORES
            
            // SB TYPE
            2'b01: begin
                case (i_funct3)
                    3'b000  : o_alucrtl = ALU_EQUAL;      // BEQ - Equal comparison
                    3'b001  : o_alucrtl = ALU_NEQUAL;     // BNE - Not equal comparison
                    3'b100  : o_alucrtl = ALU_LT;         // BLT - Set Less Than (signed)
                    3'b101  : o_alucrtl = ALU_GT;         // BGE - Greater/Equal (signed)
                    3'b110  : o_alucrtl = ALU_LTU;        // BLTU - Set Less Than Unsigned
                    3'b111  : o_alucrtl = ALU_GTU;        // BGEU - Greater/Equal Unsigned
                    default : o_alucrtl = ALU_UNUSED;     // Undefined/Reserved
                endcase
            end
            
            default: begin  // For R-type and I-type
                case (i_funct3)

                    // ADD/ADDI/SUB
                    3'b000  : begin
                        if (l_rtypesub)
                            o_alucrtl = ALU_SUB;    // SUB
                        else
                            o_alucrtl = ALU_ADD;    // ADD, ADDI
                    end
                    
                    // SLL/SLLI
                    3'b001  : begin
                        if (i_funct7b5 == 1'b0)
                            o_alucrtl = ALU_SLL;    // SLL
                        else
                            o_alucrtl = ALU_UNUSED; // Reserved/Error
                    end

                    3'b010  : o_alucrtl = ALU_LT;   // SLT/SLTI
                    3'b011  : o_alucrtl = ALU_LTU;  // SLTU/SLTIU
                    3'b100  : o_alucrtl = ALU_XOR;  // XOR/XORI

                    // SRL/SRLI / SRA/SRAI
                    3'b101  : begin
                        if (i_funct7b5 == 1'b0)
                            o_alucrtl = ALU_SRL;    // SRL
                        else
                            o_alucrtl = ALU_SRA;    // SRA
                    end

                    3'b110  : o_alucrtl = ALU_OR;   // OR, ORI
                    3'b111  : o_alucrtl = ALU_AND;  // AND, ANDI
                    
                    default: o_alucrtl = ALU_UNUSED;   // Reserved/Error
                endcase
            end
        endcase
    end

endmodule