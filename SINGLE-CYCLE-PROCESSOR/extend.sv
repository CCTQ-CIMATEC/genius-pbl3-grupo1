module extend (
    input  logic [31:7] i_instr,
    input  logic [1:0]  i_immsrc,    //tipo da instrução
    output logic [31:0] i_immext     //imediato estendido (sinalizado)
);

    always_comb begin
        case (immsrc)
            // I-type (ex: LW, ADDI)
            2'b00: i_immext = {{20{i_instr[31]}}, i_instr[31:20]};

            // S-type (ex: SW)
            2'b01: i_immext = {{20{i_instr[31]}}, i_instr[31:25], i_instr[11:7]};

            // B-type (ex: BEQ, BNE)
            2'b10: i_immext = {{20{i_instr[31]}}, i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0};

            // J-type (ex: JAL)
            2'b11: i_immext = {{12{i_instr[31]}}, i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0};

            default: i_immext = 32'bx;
        endcase
    end

endmodule
