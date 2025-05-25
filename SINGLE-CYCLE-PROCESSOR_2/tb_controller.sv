`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2025 12:14:21 PM
// Design Name: 
// Module Name: controller_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps  // Simulation time unit = 1ns, precision = 1ps
module tb_controller();

    // Inputs
    logic [6:0] i_op;
    logic [2:0] i_funct3;
    logic       i_funct7b5;
    logic       i_zero;

    // Outputs
    logic [2:0] o_alucrtl;
    logic [1:0] o_resultsrc, o_immsrc;
    logic       o_memwrite, o_pcsrc, o_alusrc, o_regwrite, o_jump;

    // DUT
    controller dut (
        .i_op(i_op),
        .i_funct3(i_funct3),
        .i_funct7b5(i_funct7b5),
        .i_zero(i_zero),
        .o_alucrtl(o_alucrtl),
        .o_resultsrc(o_resultsrc),
        .o_immsrc(o_immsrc),
        .o_memwrite(o_memwrite),
        .o_pcsrc(o_pcsrc),
        .o_alusrc(o_alusrc),
        .o_regwrite(o_regwrite),
        .o_jump(o_jump)
    );

    // Task to display results
    task print_outputs(string instr);
        $display("[%s] alucrtl=%b resultsrc=%b immsrc=%b memwrite=%b pcsrc=%b alusrc=%b regwrite=%b jump=%b",
                 instr, o_alucrtl, o_resultsrc, o_immsrc, o_memwrite, o_pcsrc, o_alusrc, o_regwrite, o_jump);
    endtask

    initial begin
        // Test lw
        i_op = 7'b0000011;  // lw
        i_funct3 = 3'b010;
        i_funct7b5 = 1'b0;
        i_zero = 1'b0;
        #1; print_outputs("lw");

        // Test sw
        i_op = 7'b0100011;  // sw
        i_funct3 = 3'b010;
        i_funct7b5 = 1'b0;
        i_zero = 1'b0;
        #1; print_outputs("sw");

        // Test add (R-type)
        i_op = 7'b0110011;  // R-type
        i_funct3 = 3'b000;
        i_funct7b5 = 1'b0;
        i_zero = 1'b0;
        #1; print_outputs("add");

        // Test sub (R-type)
        i_op = 7'b0110011;
        i_funct3 = 3'b000;
        i_funct7b5 = 1'b1;
        i_zero = 1'b0;
        #1; print_outputs("sub");

        // Test beq
        i_op = 7'b1100011;  // beq
        i_funct3 = 3'b000;
        i_funct7b5 = 1'b0;
        i_zero = 1'b1; // Should take branch
        #1; print_outputs("beq - taken");
        i_zero = 1'b0; // Should not take branch
        #1; print_outputs("beq - not taken");

        // Test I-type ALU (addi)
        i_op = 7'b0010011;
        i_funct3 = 3'b000;
        i_funct7b5 = 1'b0;
        i_zero = 1'b0;
        #1; print_outputs("addi");

        // Test jal
        i_op = 7'b1101111;  // jal
        i_funct3 = 3'b000;
        i_funct7b5 = 1'b0;
        i_zero = 1'b0;
        #1; print_outputs("jal");

        $finish;
    end

endmodule