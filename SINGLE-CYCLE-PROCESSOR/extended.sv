module extend (
    input  logic [31:7] instr,
    input  logic [1:0]  immsrc,    //tipo da instrução
    output logic [31:0] immext     //imediato estendido (sinalizado)
);

    always_comb begin
        case (immsrc)
            // I-type (ex: LW, ADDI)
            2'b00: immext = {{20{instr[31]}}, instr[31:20]};

            // S-type (ex: SW)
            2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type (ex: BEQ, BNE)
            2'b10: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

            // J-type (ex: JAL)
            2'b11: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

            default: immext = 32'bx;
        endcase
    end

endmodule
