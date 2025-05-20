module alu (
    input  logic [31:0] a, b,
    input  logic [3:0] alucontrol,
    output logic [31:0] result,
    output logic zero
);

    always_comb begin
        case (alucontrol)
            4'b0000: result = a & b;       // AND
            4'b0001: result = a | b;       // OR
            4'b0010: result = a + b;       // ADD
            4'b0110: result = a - b;       // SUB
            4'b0111: result = (a < b) ? 1 : 0; // SLT
            4'b1100: result = ~(a | b);    // NOR
            default: result = 32'hDEADBEEF;
        endcase
        zero = (result == 0);
    end

endmodule
