// aludec.sv - Enhanced version
`timescale 1ns / 1ps

module aludec
(
    input logic i_opb5,           // Bit 5 of the opcode
    input logic [2:0] i_funct3,   // funct3 field from instruction
    input logic i_funct7b5,       // Bit 5 of funct7 field
    input logic [1:0] i_aluop,    // ALUOp from main decoder
    output logic [3:0] o_alucrtl  // 4-bit ALU control output
);

    // Internal signal to identify R-type subtract operation
    logic l_rtypesub;
    assign l_rtypesub = i_funct7b5 & i_opb5;

    // Combinational logic for ALU control
    always_comb begin
        case (i_aluop)
            2'b00: o_alucrtl = 4'b0000;  // ADD (for loads, stores)
            
            2'b01: begin  // For branches
                case (i_funct3)
                    3'b000: o_alucrtl = 4'b1011;  // BEQ - Equal comparison
                    3'b001: o_alucrtl = 4'b1100;  // BNE - Not equal comparison
                    3'b100: o_alucrtl = 4'b0010;  // BLT - Set Less Than (signed)
                    3'b101: o_alucrtl = 4'b1101;  // BGE - Greater/Equal (signed)
                    3'b110: o_alucrtl = 4'b0011;  // BLTU - Set Less Than Unsigned
                    3'b111: o_alucrtl = 4'b1111;  // BGEU - Greater/Equal Unsigned
                    default: o_alucrtl = 4'b1110; // Undefined/Reserved
                endcase
            end
            
            default: begin  // For R-type and I-type instructions (when ALUOp = 1x)
                case (i_funct3)
                    3'b000: begin  // ADD/SUB or ADDI
                        if (l_rtypesub)
                            o_alucrtl = 4'b1000;  // SUB (R-type)
                        else
                            o_alucrtl = 4'b0000;  // ADD (R-type), ADDI (I-type)
                    end
                    3'b001: begin  // SLL/SLLI
                        if (i_funct7b5 == 1'b0)
                            o_alucrtl = 4'b0001;  // SLL
                        else
                            o_alucrtl = 4'b1110;  // Reserved/Error
                    end
                    3'b010: o_alucrtl = 4'b0010;  // SLT, SLTI
                    3'b011: o_alucrtl = 4'b0011;  // SLTU, SLTIU
                    3'b100: o_alucrtl = 4'b0100;  // XOR, XORI
                    3'b101: begin  // SRL/SRLI / SRA/SRAI
                        if (i_funct7b5 == 1'b0)
                            o_alucrtl = 4'b0101;  // SRL
                        else
                            o_alucrtl = 4'b1001;  // SRA
                    end
                    3'b110: o_alucrtl = 4'b0110;  // OR, ORI
                    3'b111: o_alucrtl = 4'b0111;  // AND, ANDI
                    default: o_alucrtl = 4'b1110; // Reserved/Error
                endcase
            end
        endcase
    end

endmodule