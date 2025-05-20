`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: David Machado Couto Bezerra
// 
// Create Date: 05/19/2025
// Module Name: maindec
// Project Name: SYNGLE_CYCLE
// Tool Versions: 1.0
// Description: main decoder
//
// Additional Comments: The main decoder define all control signals required by the datapath
//                      except for the ALU control signals.
//////////////////////////////////////////////////////////////////////////////////

// Signal meanings:
//   o_regwrite   - enables writing to register file
//   o_immsrc     - selects immediate format for instruction
//   o_alusrc     - selects ALU input source (register or immediate)
//   o_memwrite   - enables memory write
//   o_resultsrc  - selects result source (e.g., from ALU, memory, PC+4)
//   o_branch     - branch instruction flag
//   o_aluop      - main ALU operation type for further decoding
//   o_jump       - jump instruction flag

module maindec(
    input  logic [6:0] i_op,
    output logic [1:0] o_resultsrc,
    output logic       o_memwrite,
    output logic       o_branch, o_alusrc,
    output logic       o_regwrite, o_jump,
    output logic [1:0] o_immsrc,
    output logic [1:0] o_aluop
);
    
    logic [10:0] l_controls;

    assign {o_regwrite, o_immsrc, 
            o_alusrc, o_memwrite, 
            o_resultsrc, o_branch, 
            o_aluop, o_jump} = l_controls;

    always_comb begin   
        case (i_op)
            // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
            7'b0000011: l_controls = 11'b1_00_1_0_01_0_00_0; // lw
            7'b0100011: l_controls = 11'b0_01_1_1_00_0_00_0; // sw
            7'b0110011: l_controls = 11'b1_xx_0_0_00_0_10_0; // R–type
            7'b1100011: l_controls = 11'b0_10_0_0_00_1_01_0; // beq
            7'b0010011: l_controls = 11'b1_00_1_0_00_0_10_0; // I–type ALU
            7'b1101111: l_controls = 11'b1_11_0_0_10_0_00_1; // jal
            default: l_controls = 11'bx_xx_x_x_xx_x_xx_x;    // ???
        endcase
    end

endmodule