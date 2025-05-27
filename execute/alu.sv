`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2025 07:58:00 AM
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


/**
    PBL3 - RISC-V Single Cycle Processor
    Arithmetic Logic Unit (ALU) Module

    File name: alu.sv

    Objective:
        Implement the core arithmetic and logic operations for the RISC-V processor.
        Handles all required computations for the RV32I instruction set.

    Specification:
        - Supports basic arithmetic operations (ADD, SUBTRACT)
        - Implements logical operations (AND, OR)
        - Provides comparison operation (SET LESS THAN)
        - Generates zero flag for branch comparisons
        - 32-bit inputs and outputs
        - Combinational logic (no clocked elements)

    Operations:
        - ADD:       i_a + i_b
        - SUBTRACT:  i_a - i_b
        - AND:       i_a & i_b
        - OR:        i_a | i_b
        - SLT:       Sets result to 1 if  i_a < i_b (signed comparison)

    Functional Diagram:

                       +------------------+
                       |                  |
        i_a[31:0] ---->|                  |
        i_b[31:0] ---->|       ALU        |---> o_result[31:0]
        i_alucontrol ->|                  |---> o_zero
                       |                  |
                       +------------------+

    Inputs:
        i_a[31:0]       - First operand (typically from register file)
        i_b[31:0]       - Second operand (from register or immediate)
        i_alucontrol[2:0] - Operation selector:
                            * 3'b000: ADD
                            * 3'b001: SUBTRACT
                            * 3'b010: AND
                            * 3'b011: OR
                            * 3'b101: SET LESS THAN

    Outputs:
        o_result[31:0]  - Result of ALU operation
        o_zero          - Asserted (1) when result is zero, used for BEQ/BNE

    Control Signals:
        i_alucontrol    - Determines which operation the ALU performs
                         (decoded from funct3 and funct7 fields of instruction)
**/

//----------------------------------------------------------------------------- 
//  Arithmetic Logic Unit (ALU) Module
//-----------------------------------------------------------------------------
module alu (
    input  logic [31:0] i_a,          // Operand A
    input  logic [31:0] i_b,          // Operand B
    input  logic [3:0]  i_alucontrol, // 3-bit ALU control signal
    output logic [31:0] o_result,     // ALU result
    output logic        o_zero        // Zero flag (1 when result is zero)
);

always_comb begin
    case (i_alucontrol)
        3'b000: o_result = i_a + i_b;                                   // ADD
        3'b001: o_result = i_a - i_b;                                   // SUB
        3'b010: o_result = i_a & i_b;                                   // AND
        3'b011: o_result = i_a | i_b;                                   // OR
        3'b100: o_result = i_a ^ i_b;                                   // XOR
        3'b101: o_result = ($signed(i_a) < $signed(i_b)) ? 32'd1 : 32'd0; // SLT
        3'b110: o_result = ($unsigned(i_a) < $unsigned(i_b)) ? 32'd1 : 32'd0; // SLTU
        3'b111: o_result = i_a << i_b[4:0];                             // SLL
        3'b1000: o_result = i_a >> i_b[4:0];                            // SRL
        3'b1001: o_result = $signed(i_a) >>> i_b[4:0];                  // SRA
        default: o_result = 32'hDEADBEEF;
    endcase

    o_zero = (o_result == 32'b0);
end


endmodule