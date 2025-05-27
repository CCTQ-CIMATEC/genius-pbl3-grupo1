/**
 * PBL3 - RISC-V Pipelined Processor
 * Instruction Decode Stage Module
 * 
 * File name: decode_stage.sv
 * 
 * Objective:
 *     Implements the instruction decode stage of a pipelined RISC-V processor.
 *     Combines controller, register file, and immediate extender functionality.
 * 
 * Description:
 *     - Decodes instruction fields and generates control signals
 *     - Reads source operands from register file
 *     - Extends immediate values based on instruction type
 *     - Passes all necessary signals to execute stage via pipeline register
 * 
 * Functional Diagram:
 * 
 *                    +----------------------------------+
 *                    |          DECODE STAGE            |
 *                    |                                  |
 *   i_instr_d    --->|  +----------+  +----------+     |
 *   i_pc_d       --->|  |CONTROLLER|  | REGFILE  |     |---> to EX stage
 *   i_pc4_d      --->|  +----------+  +----------+     |     via ID_EX_reg
 *   i_reg_write_w--->|                 +----------+     |
 *   i_rd_addr_w  --->|                 | EXTEND   |     |
 *   i_result_w   --->|                 +----------+     |
 *                    +----------------------------------+
 */

`timescale 1ns / 1ps

module decode_stage #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
) (
    // Clock and Reset
    input logic i_clk,
    input logic i_rst_n,
    
    // Input from IF/ID pipeline register
    input logic [DATA_WIDTH-1:0] i_instr_d,     // Instruction from fetch stage
    input logic [DATA_WIDTH-1:0] i_pc_d,        // PC value from fetch stage
    input logic [DATA_WIDTH-1:0] i_pc4_d,       // PC+4 value from fetch stage
    
    // Writeback inputs (from WB stage)
    input logic i_reg_write_w,                   // Register write enable from WB
    input logic [ADDR_WIDTH-1:0] i_rd_addr_w,   // Destination register from WB
    input logic [DATA_WIDTH-1:0] i_result_w,    // Result data from WB
    
    // ALU zero flag input (for branch resolution)
    input logic i_zero_e,                        // Zero flag from execute stage
    
    // Outputs to EX stage (through ID_EX pipeline register)
    // Control signals
    output logic o_regwrite_e,
    output logic [1:0] o_resultsrc_e,
    output logic o_memwrite_e,
    output logic o_jump_e,
    output logic o_branch_e,
    output logic [2:0] o_aluctrl_e,
    output logic o_alusrc_e,
    
    // Data outputs
    output logic [DATA_WIDTH-1:0] o_rs1_data_e,
    output logic [DATA_WIDTH-1:0] o_rs2_data_e,
    output logic [DATA_WIDTH-1:0] o_pc_e,
    
    // Instruction fields
    output logic [ADDR_WIDTH-1:0] o_rs1_addr_e,
    output logic [ADDR_WIDTH-1:0] o_rs2_addr_e,
    output logic [ADDR_WIDTH-1:0] o_rd_addr_e,
    
    // Extended immediate and PC+4
    output logic [DATA_WIDTH-1:0] o_immext_e,
    output logic [DATA_WIDTH-1:0] o_pc4_e,
    
    // PC source output (for fetch stage)
    output logic o_pcsrc
);

    // Internal signals
    // Instruction field extraction
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic funct7b5;
    logic [ADDR_WIDTH-1:0] rs1_addr;
    logic [ADDR_WIDTH-1:0] rs2_addr;
    logic [ADDR_WIDTH-1:0] rd_addr;
    
    // Controller outputs
    logic [2:0] aluctrl_d;
    logic [1:0] resultsrc_d;
    logic [1:0] immsrc_d;
    logic memwrite_d;
    logic alusrc_d;
    logic regwrite_d;
    logic jump_d;
    logic branch_d;
    
    // Register file outputs
    logic [DATA_WIDTH-1:0] rs1_data_d;
    logic [DATA_WIDTH-1:0] rs2_data_d;
    
    // Immediate extender output
    logic [DATA_WIDTH-1:0] immext_d;
    
    // Extract instruction fields
    assign opcode = i_instr_d[6:0];
    assign funct3 = i_instr_d[14:12];
    assign funct7b5 = i_instr_d[30];
    assign rs1_addr = i_instr_d[19:15];
    assign rs2_addr = i_instr_d[24:20];
    assign rd_addr = i_instr_d[11:7];
    
    // Controller instance
    controller u_controller (
        .i_op(opcode),
        .i_funct3(funct3),
        .i_funct7b5(funct7b5),
        .i_zero(i_zero_e),
        .o_alucrtl(aluctrl_d),
        .o_resultsrc(resultsrc_d),
        .o_immsrc(immsrc_d),
        .o_memwrite(memwrite_d),
        .o_pcsrc(o_pcsrc),
        .o_alusrc(alusrc_d),
        .o_regwrite(regwrite_d),
        .o_jump(jump_d)
    );
    
    // Register file instance
    regfile #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_regfile (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_reg_write(i_reg_write_w),
        .i_rs1_addr(rs1_addr),
        .i_rs2_addr(rs2_addr),
        .i_rd_addr(i_rd_addr_w),
        .i_rd_data(i_result_w),
        .o_rs1_data(rs1_data_d),
        .o_rs2_data(rs2_data_d)
    );
    
    // Immediate extender instance
    extend u_extend (
        .i_instr(i_instr_d[31:7]),
        .i_immsrc(immsrc_d),
        .o_immext(immext_d)
    );
    
    // ID/EX pipeline register instance
    ID_EX_reg #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_id_ex_reg (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        
        // Control inputs from decode stage
        .i_regwrite_d(regwrite_d),
        .i_resultsrc_d(resultsrc_d),
        .i_memwrite_d(memwrite_d),
        .i_jump_d(jump_d),
        .i_branch_d(branch_d),
        .i_alucrtl_d(aluctrl_d),
        .i_alusrc_d(alusrc_d),
        
        // Data inputs from decode stage
        .i_rs1_data_d(rs1_data_d),
        .i_rs2_data_d(rs2_data_d),
        .i_pc_d(i_pc_d),
        
        // Instruction field inputs
        .i_rs1_addr_d(rs1_addr),
        .i_rs2_addr_d(rs2_addr),
        .i_rd_addr_d(rd_addr),
        
        // Immediate and PC+4 inputs
        .i_immext_d(immext_d),
        .i_pc4_d(i_pc4_d),
        
        // Outputs to execute stage
        .i_regwrite_e(o_regwrite_e),
        .i_resultsrc_e(o_resultsrc_e),
        .i_memwrite_e(o_memwrite_e),
        .i_jump_e(o_jump_e),
        .i_branch_e(o_branch_e),
        .i_alucrtl_e(o_aluctrl_e),
        .i_alusrc_e(o_alusrc_e),
        .i_rs1_data_e(o_rs1_data_e),
        .i_rs2_data_e(o_rs2_data_e),
        .i_pc_e(o_pc_e),
        .i_rs1_addr_e(o_rs1_addr_e),
        .i_rs2_addr_e(o_rs2_addr_e),
        .i_rd_addr_e(o_rd_addr_e),
        .i_immext_e(o_immext_e),
        .i_pc4_e(o_pc4_e)
    );

endmodule