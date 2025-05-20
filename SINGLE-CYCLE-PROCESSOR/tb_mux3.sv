`timescale 1ns/1ps

module mux3_tb;

    parameter DATA_WIDTH = 32;
    logic [DATA_WIDTH-1:0] i_d0, i_d1, i_d2;
    logic [1:0]            i_sel;
    logic [DATA_WIDTH-1:0] o_y;

    // Instantiate the mux2
    mux3 #(DATA_WIDTH) uut (
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
