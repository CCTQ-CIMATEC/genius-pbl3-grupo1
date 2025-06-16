/*-----------------------------------------------------------------------------
    PBL3 - RISC-V Single Cycle Processor
    Arithmetic Logic Unit (ALU) Module

    File name: alu.sv
    Usage: rtl/execute/execute_stage.sv

    Objective:
        Implement the core arithmetic and logic operations for the RISC-V processor.
        Handles all required computations for the RV32I instruction set.
-----------------------------------------------------------------------------*/
`timescale 1ns / 1ps

module alu (
    input  logic [31:0] i_a,            // Operand A
    input  logic [31:0] i_b,            // Operand B
    input  logic [3:0]  i_alucontrol,   // 4-bit ALU control signal - Operation selector
    output logic [31:0] o_result,       // ALU result
    output logic        o_zero          // Zero flag (1 when result is zero)
);

    always_comb begin
        case (i_alucontrol)
            4'b0000: o_result = i_a + i_b;                              // ALU_ADD - Addition
            4'b0001: o_result = i_a << i_b[4:0];                        // ALU_SLL - Shift Left Logical
            4'b0010: o_result = ($signed(i_a) < $signed(i_b)) ? 1 : 0;  // ALU_LT - Set Less Than (signed)
            4'b0011: o_result = (i_a < i_b) ? 1 : 0;                    // ALU_LTU - Set Less Than Unsigned
            4'b0100: o_result = i_a ^ i_b;                              // ALU_XOR - Bitwise XOR
            4'b0101: o_result = i_a >> i_b[4:0];                        // ALU_SRL - Shift Right Logical
            4'b0110: o_result = i_a | i_b;                              // ALU_OR - Bitwise OR
            4'b0111: o_result = i_a & i_b;                              // ALU_AND - Bitwise AND
            4'b1000: o_result = i_a - i_b;                              // ALU_SUB - Subtraction
            4'b1001: o_result = $signed(i_a) >>> i_b[4:0];              // ALU_SRA - Shift Right Arithmetic
            4'b1010: o_result = i_b;                                    // ALU_BPS2 - Bypass source 2 (pass i_b through)
            4'b1011: o_result = (i_a == i_b) ? 0 : 1;                   // ALU_EQUAL - Equal comparison
            4'b1100: o_result = (i_a != i_b) ? 0 : 1;                   // ALU_NEQUAL - Not equal comparison
            4'b1101: o_result = ($signed(i_a) >= $signed(i_b)) ? 1 : 0; // ALU_GT - Signed Greater/Equal than
            4'b1110: o_result = 32'hDEADBEEF;                           // Unused/Reserved
            4'b1111: o_result = (i_a >= i_b) ? 1 : 0;                   // ALU_GTU - Unsigned Greater/Equal than
            default: o_result = 32'hDEADBEEF;                           // Undefined operation
        endcase
        
        // Zero flag generation
        o_zero = (o_result == 32'b0);
    end

endmodule