//////////////////////////////////////////////////////////////////////////////////
// Engineer: David Machado Couto Bezerra
// 
// Create Date: 05/19/2025
// Module Name: controller
// Project Name: SYNGLE_CYCLE
// Tool Versions: 1.0
// Description: controller unit for RISC-V single-cycle CPU.
//
// Additional Comments: Takes both ALUdec and maindec to form the control unit.
//                      o_pcsrc: Asserted to select branch/jump target as next PC.
//////////////////////////////////////////////////////////////////////////////////

module controller(
    input logic [6:0] i_op,
    input logic [2:0] i_funct3,
    input logic       i_funct7b5,
    input logic       i_zero,
    
    output logic [2:0] o_alucrtl,
    output logic [1:0] o_resultsrc, o_immsrc,
    output logic       o_memwrite,
    output logic       o_pcsrc, o_alusrc,
    output logic       o_regwrite, o_jump
);
    
    logic [1:0] l_aluop;
    logic       l_branch;
    logic       i_opb5;

    maindec md (
        .i_op           (i_op),
        .o_resultsrc    (o_resultsrc),
        .o_memwrite     (o_memwrite),
        .o_branch       (l_branch),
        .o_alusrc       (o_alusrc),
        .o_regwrite     (o_regwrite),
        .o_jump         (o_jump),
        .o_immsrc       (o_immsrc),
        .o_aluop        (l_aluop)
    );

    aludec ad(
        .i_opb5    (i_opb5),
        .i_funct3   (i_funct3),
        .i_funct7b5 (i_funct7b5),
        .i_aluop    (l_aluop),
        .o_alucrtl  (o_alucrtl)
    );

    assign i_opb5 = i_op[5];

    //True if (branch & zero for beq) or jump for jal.
    assign o_pcsrc = l_branch & i_zero | o_jump;

endmodule