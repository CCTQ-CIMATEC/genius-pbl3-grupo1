// aludec.sv - Enhanced version
`timescale 1ns / 1ps

module aludec
(
    input logic        i_opb5,         // Bit 5 of the opcode
    input logic [2:0]  i_funct3,       // funct3 field from instruction
    input logic        i_funct7b5,     // Bit 5 of funct7 field
    input logic [1:0]  i_aluop,        // ALUOp from main decoder
    output logic [2:0] o_alucrtl,      // ALU control output
    output logic [2:0] o_branch_type   // NEW: Branch type for branch_taken logic
);

    // Internal signal to identify R-type subtract operation
    logic l_rtypesub;
    assign l_rtypesub = i_funct7b5 & i_opb5;

    // Branch type encoding:
    // 3'b000: No branch
    // 3'b001: BEQ (branch if equal)
    // 3'b010: BNE (branch if not equal)  
    // 3'b011: BLT (branch if less than)
    // 3'b100: BGE (branch if greater or equal)
    // 3'b101: BLTU (branch if less than unsigned)
    // 3'b110: BGEU (branch if greater or equal unsigned)

    // Combinational logic for ALU control and branch type
    always_comb begin
        o_branch_type = 3'b000; // Default: no branch
        
        case (i_aluop)
            2'b00: o_alucrtl = 3'b000; // ADD (for loads, stores)
            
            2'b01: begin // For branches
                case (i_funct3)
                    3'b000: begin // BEQ
                        o_alucrtl = 3'b001; // SUB
                        o_branch_type = 3'b001; // BEQ
                    end
                    3'b001: begin // BNE  
                        o_alucrtl = 3'b001; // SUB
                        o_branch_type = 3'b010; // BNE
                    end
                    3'b100: begin // BLT
                        o_alucrtl = 3'b101; // SLT
                        o_branch_type = 3'b011; // BLT
                    end
                    3'b101: begin // BGE
                        o_alucrtl = 3'b101; // SLT  
                        o_branch_type = 3'b100; // BGE
                    end
                    3'b110: begin // BLTU
                        o_alucrtl = 3'b101; // SLT (ALU needs to handle unsigned)
                        o_branch_type = 3'b101; // BLTU
                    end
                    3'b111: begin // BGEU
                        o_alucrtl = 3'b101; // SLT (ALU needs to handle unsigned)
                        o_branch_type = 3'b110; // BGEU
                    end
                    default: begin
                        o_alucrtl = 3'bxxx;
                        o_branch_type = 3'b000;
                    end
                endcase
            end
            
            default: begin // For R-type and I-type instructions (when ALUOp = 1x)
                case (i_funct3)
                    3'b000: // ADD/SUB or ADDI
                        if (l_rtypesub) 
                            o_alucrtl = 3'b001; // SUB (R-type)
                        else
                            o_alucrtl = 3'b000; // ADD (R-type), ADDI (I-type)

                    3'b001: begin // SLL/SLLI
                        if (i_funct7b5 == 1'b0)
                            o_alucrtl = 3'b110; // SLL
                        else
                            o_alucrtl = 3'bxxx;
                    end

                    3'b010: o_alucrtl = 3'b101; // SLT, SLTI
                    3'b100: o_alucrtl = 3'b100; // XOR, XORI

                    3'b101: begin // SRL/SRLI / SRA/SRAI
                        if (i_funct7b5 == 1'b0)
                            o_alucrtl = 3'b111; // SRL
                        else
                            o_alucrtl = 3'bxxx; // SRA (would need different encoding)
                    end

                    3'b110: o_alucrtl = 3'b011; // OR, ORI
                    3'b111: o_alucrtl = 3'b010; // AND, ANDI
                    default: o_alucrtl = 3'bxxx;
                endcase
            end
        endcase
    end

endmodule