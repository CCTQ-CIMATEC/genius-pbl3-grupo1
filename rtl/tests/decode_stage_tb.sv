`timescale 1ns / 1ps

module decode_stage_tb;

    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 5;

    // Clock and Reset
    logic i_clk;
    logic i_rst_n;

    // Input from IF/ID pipeline register
    logic [DATA_WIDTH-1:0] i_instr_d;     // Instruction from fetch stage
    logic [DATA_WIDTH-1:0] i_pc_d;        // PC value from fetch stage
    logic [DATA_WIDTH-1:0] i_pc4_d;       // PC+4 value from fetch stage

    // Writeback inputs (from WB stage)
    logic i_reg_write_w;                  // Register write enable from WB
    logic [ADDR_WIDTH-1:0] i_rd_addr_w;   // Destination register from WB
    logic [DATA_WIDTH-1:0] i_result_w;    // Result data from WB

    // ALU zero flag input (for branch resolution)
    logic i_zero_e;                       // Zero flag from execute stage

    // Outputs from decode_stage (to EX stage)
    logic o_regwrite_e;
    logic [1:0] o_resultsrc_e;
    logic o_memwrite_e;
    logic o_jump_e;
    logic o_branch_e;
    logic [2:0] o_aluctrl_e;
    logic o_alusrc_e;

    logic [DATA_WIDTH-1:0] o_rs1_data_e;
    logic [DATA_WIDTH-1:0] o_rs2_data_e;
    logic [DATA_WIDTH-1:0] o_pc_e;

    logic [ADDR_WIDTH-1:0] o_rs1_addr_e;
    logic [ADDR_WIDTH-1:0] o_rs2_addr_e;
    logic [ADDR_WIDTH-1:0] o_rd_addr_e;

    logic [DATA_WIDTH-1:0] o_immext_e;
    logic [DATA_WIDTH-1:0] o_pc4_e;

    // Instantiate the Unit Under Test (UUT)
    decode_stage #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_instr_d(i_instr_d),
        .i_pc_d(i_pc_d),
        .i_pc4_d(i_pc4_d),
        .i_reg_write_w(i_reg_write_w),
        .i_rd_addr_w(i_rd_addr_w),
        .i_result_w(i_result_w),
        .i_zero_e(i_zero_e),
        .o_regwrite_e(o_regwrite_e),
        .o_resultsrc_e(o_resultsrc_e),
        .o_memwrite_e(o_memwrite_e),
        .o_jump_e(o_jump_e),
        .o_branch_e(o_branch_e),
        .o_aluctrl_e(o_aluctrl_e),
        .o_alusrc_e(o_alusrc_e),
        .o_rs1_data_e(o_rs1_data_e),
        .o_rs2_data_e(o_rs2_data_e),
        .o_pc_e(o_pc_e),
        .o_rs1_addr_e(o_rs1_addr_e),
        .o_rs2_addr_e(o_rs2_addr_e),
        .o_rd_addr_e(o_rd_addr_e),
        .o_immext_e(o_immext_e),
        .o_pc4_e(o_pc4_e)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 10ns period -> 100MHz clock
    end

    // Test instructions
    logic [DATA_WIDTH-1:0] test_instructions [0:8]; // 9 instructions

    initial begin
        // Provided instructions
        test_instructions[0] = 32'h00500113; // addi x2, x0, 5
        test_instructions[1] = 32'h00C00193; // addi x3, x0, 12
        test_instructions[2] = 32'hFF718393; // addi x7, x3, -9
        test_instructions[3] = 32'h0023E233; // AND x4, x7, x2 (R-type, op:0110011, f3:111, rd:4, rs1:7, rs2:2)
        test_instructions[4] = 32'h0041F2B3; // SRL x5, x3, x4 (R-type, op:0110011, f3:101, rd:5, rs1:3, rs2:4, f7b5(instr[30])=0)
        test_instructions[5] = 32'h004282B3; // ADD x5, x5, x4 (R-type, op:0110011, f3:000, rd:5, rs1:5, rs2:4, f7b5=0)
        test_instructions[6] = 32'h02728863; // BEQ x5, x7, offset (SB-type, op:1100011, f3:000, rs1:5, rs2:7)
        test_instructions[7] = 32'h0041A233; // SLL x4, x3, x4 (R-type, op:0110011, f3:001, rd:4, rs1:3, rs2:4)
        test_instructions[8] = 32'h00020463; // BEQ x4, x0, offset (SB-type, op:1100011, f3:000, rs1:4, rs2:0)
    end

    // Test sequence
    initial begin
        // Initialize inputs
        i_rst_n = 1'b0;      // Assert reset
        i_instr_d = 32'b0;   // NOP initially
        i_pc_d = 32'h0;
        i_pc4_d = 32'h4;
        i_reg_write_w = 1'b0; // Writeback signals off
        i_rd_addr_w = 5'b0;
        i_result_w = 32'b0;
        i_zero_e = 1'b0;     // ALU Zero flag

        #15; // Hold reset for a bit
        i_rst_n = 1'b1;      // De-assert reset
        #5;                  // Wait for reset to propagate and system to stabilize

        $display("Time(ns)| Instr In   | PC In    |PC+4 In   | RegWrE|ResSrcE|MemWrE|JumpE| BrE |ALUCtrlE|ALUSrcE| RdE|Rs1E|Rs2E| ImmExtE    | PC_E     | PC+4_E   | RS1DataE | RS2DataE");
        $display("---------|------------|----------|----------|-------|-------|------|-----|-----|--------|-------|----|----|----|------------|----------|----------|----------|----------");

        for (int i = 0; i <= 8; i++) begin
            i_instr_d = test_instructions[i];
            i_pc_d    = 32'h0100 + i * 4; // Example PC values
            i_pc4_d   = i_pc_d + 4;

            // Mock some other inputs that might change
            i_reg_write_w = (i % 4 == 0); // Simulate some writeback activity
            i_rd_addr_w   = (i % 32);     // Cycle through rd addresses for WB
            i_result_w    = i * 10;       // Example result from WB
            i_zero_e      = (i % 2 == 1); // Toggle ALU zero flag

            @(posedge i_clk); // Allow combinational logic in decode_stage to evaluate
                              // On this edge, the values produced by controller, regfile, extend (l_*)
                              // for the current i_instr_d are latched into the o_*_e outputs.
            #1; // Small delay for signals to settle for display if needed by simulator

            $display("%8t| %08h | %08h | %08h | %1b     | %1b%1b    | %1b    | %1b   | %1b   |  %1b%1b%1b   | %1b     | %2h | %2h | %2h | %08h | %08h | %08h | %08h | %08h",
                     $time, i_instr_d, i_pc_d, i_pc4_d,
                     o_regwrite_e, o_resultsrc_e[1], o_resultsrc_e[0], o_memwrite_e, o_jump_e, o_branch_e,
                     o_aluctrl_e[2],o_aluctrl_e[1],o_aluctrl_e[0], o_alusrc_e,
                     o_rd_addr_e, o_rs1_addr_e, o_rs2_addr_e,
                     o_immext_e, o_pc_e, o_pc4_e, o_rs1_data_e, o_rs2_data_e);
        end

        #20;
        $finish;
    end

endmodule