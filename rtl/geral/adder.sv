/*-----------------------------------------------------------------------------
    PBL3 - RISC-V Single Cycle Processor
        Adder module for RISC-V processor implementation
        File name: adder.sv

        Parameterized Adder Module
        Implements a simple combinatorial adder with configurable bit-width

    File name: adder.sv

    Objective:
        Implement a parameterized adder that can handle different bit widths
        - Supports unsigned addition
        - Zero-delay combinatorial operation
-----------------------------------------------------------------------------*/
`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps
module adder #(
    parameter P_WIDTH = 32  // Default width is 32 bits (configurable)
    
) (
    // Input Ports
    input  logic [P_WIDTH:0] i_a,  // First operand (width = P_WIDTH+1 bits)
    input  logic [P_WIDTH:0] i_b,  // Second operand (width = P_WIDTH+1 bits)
    
    // Output Ports
    output logic [P_WIDTH:0] o_y   // Sum output (width = P_WIDTH+1 bits)
);

    // Combinational Logic
    // --------------------------------------------
    // Continuous assignment: 
    // - Output o_y immediately updates when i_a or i_b changes
    // - Note: No overflow detection/carry-out 
    assign o_y = i_a + i_b;

endmodule