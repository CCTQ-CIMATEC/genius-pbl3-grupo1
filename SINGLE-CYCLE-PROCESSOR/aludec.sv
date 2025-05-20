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
//                      ALUOp, funct3, funct7, and opcode[5].
//////////////////////////////////////////////////////////////////////////////////


module aludec
(
    input logic         i_opb5,
    input logic [2:0]   i_funct3,
    input logic         i_funct7b5,
    input logic [1:0]   i_aluop,
    output logic [2:0]  o_alucrtl
);

    logic l_rtypesub;
    assign l_rtypesub = i_funct7b5 & i_opb5; // TRUE R-type subtract

    always_comb begin
        case (i_aluop)
            2'b00:  o_alucrtl = 3'b000; // addition
            2'b01:  o_alucrtl = 3'b001; // subtraction
            default:
                case (i_funct3)
                    3'b000:
                        if(l_rtypesub)
                            o_alucrtl = 3'b001; // sub
                        else
                            o_alucrtl = 3'b000; // add, addi
                    
                    3'b010:     o_alucrtl = 3'b101; // slt, slti
                    3'b110:     o_alucrtl = 3'b101; // or, ori
                    3'b111:     o_alucrtl = 3'b101; // and, andi
                    default:    o_alucrtl = 3'bxxx; // ???    
                endcase
        endcase
    end

endmodule
