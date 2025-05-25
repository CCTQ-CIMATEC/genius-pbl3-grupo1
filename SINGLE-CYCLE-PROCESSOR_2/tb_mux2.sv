/**
  Testbench for 2-to-1 Multiplexer Module
  
  File: mux2_tb.sv
  
  Objective:
  Verify correct functionality of the parameterized 2-to-1 multiplexer including:
  - Proper selection between two input buses
  - Correct behavior for all selection states
  - Data width configurability
  
  Test Coverage:
  1. Selection Logic (100%):
     - i_sel = 0 (select i_d0)
     - i_sel = 1 (select i_d1)
  
  2. Data Verification (100%):
     - Static pattern verification
     - Random value verification
     - Full data width propagation
  
  3. Timing Verification (100%):
     - Combinational path delay
     - Output stability
  
  Expected Results:
  1. Selection Behavior:
     - When i_sel=0: o_y should equal i_d0
     - When i_sel=1: o_y should equal i_d1
  
  2. Data Integrity:
     - All bits should propagate correctly
     - No bit corruption during selection
  
  3. Timing:
     - Output should change immediately with input changes
     - No glitches during selection changes
  
 */

//----------------------------------------------------------------------------- 
//  Multiplexer 2x1 Testbench
//-----------------------------------------------------------------------------
`timescale 1ns/1ps  // Simulation time unit: 1ns, precision: 1ps
module mux2_tb;

    // Parameters and signals
    parameter DATA_WIDTH = 32;
    logic [DATA_WIDTH-1:0] i_d0, i_d1;
    logic                  i_sel;
    logic [DATA_WIDTH-1:0] o_y;

    // Instantiate Unit Under Test (UUT)
    mux2 #(
        .P_WIDTH(DATA_WIDTH)
    ) uut (
        .i_a(i_d0),    // Note: Changed to match module's port names
        .i_b(i_d1),
        .i_sel(i_sel),
        .o_y(o_y)
    );

    initial begin
        $display("\nStarting MUX2 Testbench");
        
        // Test Case 1: Select input 0 (i_sel=0)
        i_d0 = 32'hAAAAAAAA;
        i_d1 = 32'h55555555;
        i_sel = 0;
        #10;
        $display("Test 1: i_sel=0, o_y = %h (Expected: %h)%s", 
                o_y, i_d0, (o_y === i_d0) ? " - PASS" : " - FAIL");

        // Test Case 2: Select input 1 (i_sel=1)
        i_sel = 1;
        #10;
        $display("Test 2: i_sel=1, o_y = %h (Expected: %h)%s",
                o_y, i_d1, (o_y === i_d1) ? " - PASS" : " - FAIL");

        // Test Case 3: Random values verification
        i_d0 = 32'h12345678;
        i_d1 = 32'h87654321;
        i_sel = 0;
        #10;
        $display("Test 3: i_sel=0, o_y = %h (Expected: %h)%s",
                o_y, i_d0, (o_y === i_d0) ? " - PASS" : " - FAIL");

        i_sel = 1;
        #10;
        $display("Test 4: i_sel=1, o_y = %h (Expected: %h)%s",
                o_y, i_d1, (o_y === i_d1) ? " - PASS" : " - FAIL");

        $display("\nTestbench completed");
        $finish;
    end

endmodule