`timescale 1ns/1ps

module alu (
    input  logic [31:0] i_a, i_b,
    input  logic [3:0]  i_alu_ctrl,
    output logic [31:0] o_result,
    output logic        o_zero
);

    always_comb begin
        case (i_alu_ctrl)
            4'b0000: o_result = i_a & i_b;                 // AND
            4'b0001: o_result = i_a | i_b;                 // OR
            4'b0010: o_result = i_a + i_b;                 // ADD
            4'b0110: o_result = i_a - i_b;                 // SUB
            4'b0111: o_result = (i_a < i_b) ? 32'd1 : 32'd0; // SLT
            4'b1100: o_result = ~(i_a | i_b);              // NOR
            default: o_result = 32'hDEADBEEF;              // Default
        endcase

        o_zero = (o_result == 32'd0);
    end

endmodule
