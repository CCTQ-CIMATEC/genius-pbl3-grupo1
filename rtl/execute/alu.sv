/*-----------------------------------------------------------------------------
    PBL3 - RISC-V PIPELINE Processor
    Arithmetic Logic Unit (ALU) Module

    File name: alu.sv
    Usage: rtl/execute/execute_stage.sv

    Objective:
        Implement the core arithmetic and logic operations for the RISC-V processor.
        Handles all required computations for the RV32I instruction set.
-----------------------------------------------------------------------------*/
`timescale 1ns / 1ps

import cpu_pkg::*;

module alu (
    input  logic [31:0] i_a,            // Operand A
    input  logic [31:0] i_b,            // Operand B
    input  alu_op_t     i_alucontrol,   // 4-bit ALU control signal - Operation selector
    output logic [31:0] o_result,       // ALU result
    output logic        o_zero          // Zero flag (1 when result is zero)
);

    always_comb begin
        case (i_alucontrol)
            ALU_ADD :    o_result = i_a + i_b;                              // Addition
            ALU_SLL :    o_result = i_a << i_b[4:0];                        // Shift Left Logical
            ALU_LT  :    o_result = ($signed(i_a) < $signed(i_b)) ? 1 : 0;  // Set Less Than (signed)
            ALU_LTU :    o_result = (i_a < i_b) ? 1 : 0;                    // Set Less Than Unsigned
            ALU_XOR :    o_result = i_a ^ i_b;                              // XOR
            ALU_SRL :    o_result = i_a >> i_b[4:0];                        // Shift Right Logical
            ALU_OR  :    o_result = i_a | i_b;                              // OR
            ALU_AND :    o_result = i_a & i_b;                              // AND
            ALU_SUB :    o_result = i_a - i_b;                              // Subtraction
            ALU_SRA :    o_result = $signed(i_a) >>> i_b[4:0];              // Shift Right Arithmetic
            ALU_BPS2:    o_result = i_b;                                    // Bypass source 2 (pass i_b through)
            ALU_EQUAL:   o_result = (i_a == i_b) ? 0 : 1;                   // Equal comparison
            ALU_NEQUAL:  o_result = (i_a != i_b) ? 0 : 1;                   // Not equal comparison
            ALU_GT  :    o_result = ($signed(i_a) >= $signed(i_b)) ? 1 : 0; // Signed Greater/Equal than
            ALU_UNUSED:  o_result = 32'h0;                                  // Unused/Reserved
            ALU_GTU :    o_result = (i_a >= i_b) ? 1 : 0;                   // Unsigned Greater/Equal than
            default :    o_result = 32'h0;                                  // Undefined operation
        endcase
        
        o_zero = (o_result == 32'b0);
    end

endmodule