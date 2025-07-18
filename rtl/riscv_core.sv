/*-------------------------------------------------------------------------
    PBL3 - RISC-V Pipelined Processor Core
    
    File name: riscv_core.sv
    Usage: riscv_top.sv
    
    Objective:
        5-stage pipelined RISC-V processor core datapath.
        Provides interfaces for external instruction and data memories.
 -------------------------------------------------------------------------*/

module riscv_core #(
    parameter P_DATA_WIDTH = 32,
    parameter P_ADDR_WIDTH = 11,
    parameter P_REG_ADDR_WIDTH = 5,
    parameter P_DMEM_ADDR_WIDTH = 11
)(
    input  logic i_clk,
    input  logic i_rst_n,
    
    // Instruction Memory Interface
    output logic [P_ADDR_WIDTH-1:0]       o_imem_addr,
    input  logic [P_DATA_WIDTH-1:0]       i_imem_rdata,
    
    // Data Memory Interface
    output logic                          o_dmem_we,
    output logic [P_DMEM_ADDR_WIDTH-1:0]  o_dmem_addr,
    output logic [P_DATA_WIDTH-1:0]       o_dmem_wdata,
    input  logic [P_DATA_WIDTH-1:0]       i_dmem_rdata,
    output logic [2:0]                    o_dmem_f3
);
    
    // IF/ID Pipeline Register Signals
    logic [P_ADDR_WIDTH-1:0]  if_id_pc;
    logic [P_ADDR_WIDTH-1:0]  if_id_pc4;
    logic [P_DATA_WIDTH-1:0]  if_id_instr;
    
    // ID/EX Pipeline Register Signals
    logic                           id_ex_regwrite;
    logic [1:0]                     id_ex_resultsrc;
    logic                           id_ex_memwrite;
    logic                           id_ex_jump;
    logic                           id_ex_branch;
    alu_op_t                        id_ex_aluctrl;
    logic [1:0]                     id_ex_alusrc;
    logic [2:0]                     id_ex_f3; //NEW FOR SH, SB
    logic [P_DATA_WIDTH-1:0]        id_ex_rs1_data;
    logic [P_DATA_WIDTH-1:0]        id_ex_rs2_data;
    logic [P_ADDR_WIDTH-1:0]        id_ex_pc;
    logic [P_REG_ADDR_WIDTH-1:0]    id_ex_rs1_addr;
    logic [P_REG_ADDR_WIDTH-1:0]    id_ex_rs2_addr;
    logic [P_REG_ADDR_WIDTH-1:0]    id_ex_rd_addr;
    logic [P_DATA_WIDTH-1:0]        id_ex_immext;
    logic [P_ADDR_WIDTH-1:0]        id_ex_pc4;
    
    // EX/MEM Pipeline Register Signals
    logic [P_DATA_WIDTH-1:0]        ex_mem_alu_result;
    logic [P_DATA_WIDTH-1:0]        ex_mem_write_data;
    logic                           ex_mem_regwrite;
    logic                           ex_mem_memwrite;
    logic [1:0]                     ex_mem_resultsrc;
    logic [P_REG_ADDR_WIDTH-1:0]    ex_mem_rd_addr;
    logic [P_ADDR_WIDTH-1:0]        ex_mem_pc4;
    logic [2:0]                     ex_mem_f3;
    
    // MEM/WB Pipeline Register Signals
    logic [P_DATA_WIDTH-1:0]        mem_wb_read_data;
    logic                           mem_wb_regwrite;
    logic [1:0]                     mem_wb_resultsrc;
    logic [P_REG_ADDR_WIDTH-1:0]    mem_wb_rd_addr;
    logic [P_ADDR_WIDTH-1:0]        mem_wb_pc4;
    logic [P_DATA_WIDTH-1:0]        mem_wb_alu_result;
    logic [2:0]                     mem_wb_f3;
    
    // Writeback Stage Signals
    logic [P_DATA_WIDTH-1:0]  wb_result;
    
    // Hazard Unit Signals
    logic                     stall_f, stall_d;
    logic                     flush_d, flush_e;
    logic [1:0]               forward_a, forward_b;
    
    // Branch/Jump Control Signals
    logic                     pcsrc;
    logic [P_ADDR_WIDTH-1:0]  pc_target;
    logic                     zero_flag;
    
    // Forwarding Data
    logic [P_DATA_WIDTH-1:0]  forward_data_mem;
    logic [P_DATA_WIDTH-1:0]  forward_data_wb;
    
    //FETCH STAGE
    fetch_stage #(
        .P_DATA_WIDTH(P_DATA_WIDTH),
        .PC_WIDTH(P_ADDR_WIDTH)
    ) u_fetch_stage (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        .i_stall_f      (stall_f),
        .i_stall_d      (stall_d),
        .i_flush_d      (flush_d),
        .i_pcsrc_e      (pcsrc),
        .i_pctarget_e   (pc_target[P_ADDR_WIDTH-1:0]),
        // External instruction memory interface
        .o_imem_addr    (o_imem_addr),
        .i_imem_rdata   (i_imem_rdata),
        // Pipeline outputs
        .o_pc_d         (if_id_pc),
        .o_pc4_d        (if_id_pc4),
        .o_instr_d      (if_id_instr)
    );
    
    //DECODE STAGE
    decode_stage #(
        .DATA_WIDTH(P_DATA_WIDTH),
        .ADDR_WIDTH(P_REG_ADDR_WIDTH),
        .PC_WIDTH(P_ADDR_WIDTH)
    ) u_decode_stage (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        .i_flush_e      (flush_e),
        .i_instr_d      (if_id_instr),
        .i_pc_d         (if_id_pc),
        .i_pc4_d        (if_id_pc4),
        .i_reg_write_w  (mem_wb_regwrite),
        .i_rd_addr_w    (mem_wb_rd_addr),
        .i_result_w     (wb_result),
        .i_zero_e       (zero_flag),
        .o_regwrite_e   (id_ex_regwrite),
        .o_resultsrc_e  (id_ex_resultsrc),
        .o_memwrite_e   (id_ex_memwrite),
        .o_jump_e       (id_ex_jump),
        .o_branch_e     (id_ex_branch),
        .o_aluctrl_e    (id_ex_aluctrl),
        .o_alusrc_e     (id_ex_alusrc),
        .o_f3_e         (id_ex_f3), // NEW FOR SH,SB
        .o_rs1_data_e   (id_ex_rs1_data),
        .o_rs2_data_e   (id_ex_rs2_data),
        .o_pc_e         (id_ex_pc),
        .o_rs1_addr_e   (id_ex_rs1_addr),
        .o_rs2_addr_e   (id_ex_rs2_addr),
        .o_rd_addr_e    (id_ex_rd_addr),
        .o_immext_e     (id_ex_immext),
        .o_pc4_e        (id_ex_pc4),
        .o_pcsrc_e      (pcsrc)
    );
    

    //EXECUTE STAGE
    execute_stage #(
        .DATA_WIDTH(P_DATA_WIDTH),
        .ADDR_WIDTH(P_ADDR_WIDTH)
    ) u_execute_stage (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        .i_rs1_data_e   (id_ex_rs1_data),
        .i_rs2_data_e   (id_ex_rs2_data),
        .i_immext_e     (id_ex_immext),
        .i_pc_e         (id_ex_pc),
        .i_pc4_e        (id_ex_pc4),
        .i_rs1_addr_e   (id_ex_rs1_addr),
        .i_rs2_addr_e   (id_ex_rs2_addr),
        .i_rd_addr_e    (id_ex_rd_addr),
        .i_aluctrl_e    (id_ex_aluctrl),
        .i_alusrc_e     (id_ex_alusrc),
        .i_branch_e     (id_ex_branch),
        .i_jump_e       (id_ex_jump),
        .i_regwrite_e   (id_ex_regwrite),
        .i_memwrite_e   (id_ex_memwrite),
        .i_resultsrc_e  (id_ex_resultsrc),
        .i_f3_e         (id_ex_f3),
        .i_forward_m    (forward_data_mem),
        .i_forward_w    (forward_data_wb),
        .i_forward_a    (forward_a),
        .i_forward_b    (forward_b),
        .o_alu_result_m (ex_mem_alu_result),
        .o_write_data_m (ex_mem_write_data),
        .o_pctarget_e   (pc_target),
        .o_zero_e       (zero_flag),
        .o_regwrite_m   (ex_mem_regwrite),
        .o_memwrite_m   (ex_mem_memwrite),
        .o_f3_m  (ex_mem_f3),
        .o_resultsrc_m  (ex_mem_resultsrc),
        .o_rd_addr_m    (ex_mem_rd_addr),
        .o_pc4_m        (ex_mem_pc4)
    );
    
    //MEMORY STAGE
    memory_stage #(
        .P_DATA_WIDTH(P_DATA_WIDTH),
        .P_DMEM_ADDR_WIDTH(P_DMEM_ADDR_WIDTH)
    ) u_memory_stage (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_regwrite_m       (ex_mem_regwrite),
        .i_resultsrc_m      (ex_mem_resultsrc),
        .i_memwrite_m       (ex_mem_memwrite),
        .i_alu_result_m     (ex_mem_alu_result),
        .i_write_data_m     (ex_mem_write_data),
        .i_rd_addr_m        (ex_mem_rd_addr),
        .i_pc4_m            (ex_mem_pc4),
        .i_f3_m             (ex_mem_f3),
        // External data memory interface
        .o_dmem_we          (o_dmem_we),
        .o_dmem_addr        (o_dmem_addr),
        .o_dmem_wdata       (o_dmem_wdata),
        .i_dmem_rdata       (i_dmem_rdata),
        .o_dmem_f3          (o_dmem_f3),
        // Pipeline outputs
        .o_read_data_w      (mem_wb_read_data),
        .o_regwrite_w       (mem_wb_regwrite),
        .o_resultsrc_w      (mem_wb_resultsrc),
        .o_rd_addr_w        (mem_wb_rd_addr),
        .o_pc4_w            (mem_wb_pc4),
        .o_alu_result_w     (mem_wb_alu_result),
        .o_f3_w             (mem_wb_f3)
    );
    
    //WRITEBACK STAGE
    write_back #(
        .P_WIDTH(32)
    ) u_write_back (
        .i_alu_result_w (mem_wb_alu_result),
        .i_f3_w         (mem_wb_f3),
        .i_mem_data_w   (mem_wb_read_data),
        .i_pc_plus_4_w  (mem_wb_pc4),
        .i_sel_w        (mem_wb_resultsrc),
        .o_result_w     (wb_result)
    );
    
    // HAZARD DETECTION UNIT
    hazard_stage u_hazard_stage (
        .i_clk          (i_clk),
        .if_id_instr    (if_id_instr),
        .i_branch_d     (id_ex_branch),
        .i_jump_d       (id_ex_jump),
        .i_rs1_addr_e   (id_ex_rs1_addr),
        .i_rs2_addr_e   (id_ex_rs2_addr),
        .i_rd_addr_e    (id_ex_rd_addr),
        .i_regwrite_e   (id_ex_regwrite),
        .i_resultsrc_e  (id_ex_resultsrc),
        .i_rd_addr_m    (ex_mem_rd_addr),
        .i_regwrite_m   (ex_mem_regwrite),
        .i_rd_addr_w    (mem_wb_rd_addr),
        .i_regwrite_w   (mem_wb_regwrite),
        .i_pcsrc_e      (pcsrc),
        .o_stall_f      (stall_f),
        .o_stall_d      (stall_d),
        .o_flush_d      (flush_d),
        .o_flush_e      (flush_e),
        .o_forward_a_e  (forward_a),
        .o_forward_b_e  (forward_b)
    );
    
    // Forwarding Data Assignment

    assign forward_data_mem = ex_mem_alu_result;
    assign forward_data_wb = wb_result;

endmodule