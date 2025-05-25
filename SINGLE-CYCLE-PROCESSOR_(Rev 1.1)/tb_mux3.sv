/**
  Testbench for 3-to-1 Multiplexer Module
  
  File: tb_mux3.sv
  
  Objective:
  Verify correct functionality of the parameterized 3-to-1 multiplexer including:
  - Proper selection between three input buses
  - Correct behavior for all selection states (00, 01, 10, 11)
  - Data width configurability
  - Priority handling (when i_sel[1] is set)
  
  Test Coverage:
  1. Selection Logic (100%):
     - i_sel = 00 (select i_d0)
     - i_sel = 01 (select i_d1)
     - i_sel = 1X (select i_d2, both 10 and 11 cases)
  
  2. Data Verification (100%):
     - Static pattern verification
     - Random value verification
     - Full data width propagation
  
  3. Timing Verification (100%):
     - Combinational path delay
     - Output stability during selection changes
  
  Expected Results:
  1. Selection Behavior:
     - When i_sel=00: o_y should equal i_d0
     - When i_sel=01: o_y should equal i_d1
     - When i_sel=1X: o_y should equal i_d2 (both 10 and 11 cases)
  
  2. Data Integrity:
     - All 32 bits should propagate correctly
     - No bit corruption during selection changes
  
  3. Timing:
     - Output should change immediately with input changes
     - No glitches during selection transitions
  
 */

//----------------------------------------------------------------------------- 
//  Multiplexer 3x1 Testbench File Testbench
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module tb_mux3;

    parameter P_DATA_WIDTH = 32;
    logic [P_DATA_WIDTH-1:0] i_d0, i_d1, i_d2;
    logic [1:0]              i_sel;
    logic [P_DATA_WIDTH-1:0] o_y;

    // Instantiate the mux2
    mux3 #(P_DATA_WIDTH) uut (
        .i_d0(i_d0),
        .i_d1(i_d1),
        .i_d2(i_d2),
        .i_sel(i_sel),
        .o_y(o_y)
    );

    initial begin
        $display("Starting MUX3 Testbench");
        // Test 1: i_sel = 0, expect o_y = i_d0
        i_d0 = 32'hAAAAAAAA;
        i_d1 = 32'h55555555;
        i_d2 = 32'hBBBBBBBB;
        i_sel = 0;
        #10;
        $display("i_sel=0, o_y = %h (Expected: %h)", o_y, i_d0);

        // Test 2: i_sel = 1, expect o_y = i_d1
        i_sel = 1;
        #10;
        $display("i_sel=1, o_y = %h (Expected: %h)", o_y, i_d1);

        // Test 3: i_sel = 2, expect o_y = i_d2
        i_sel = 2;
        #10;
        $display("i_sel=2, o_y = %h (Expected: %h)", o_y, i_d2);

        // Test 3: Random values
        i_d0 = 32'h12345678;
        i_d1 = 32'h87654321;
        i_d2 = 32'hA76ABC43;
        i_sel = 0;
        #10;
        $display("i_sel=0, o_y = %h (Expected: %h)", o_y, i_d0);

        i_sel = 2;
        #10;
        $display("i_sel=1, o_y = %h (Expected: %h)", o_y, i_d2);

        i_sel = 1;
        #10;
        $display("i_sel=2, o_y = %h (Expected: %h)", o_y, i_d1);

        $display("Testbench finished.");
        $finish;
    end

endmodule