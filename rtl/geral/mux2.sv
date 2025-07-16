/*-----------------------------------------------------------------------------
    PBL3 - RISC-V Processor
    2-to-1 Multiplexer Module

    File name: mux2.sv

    Objective:
        Implement a parameterized 2-to-1 multiplexer for selecting between two data buses.
        Provides flexible data path routing throughout the processor.

        Parameterized width multiplexer with binary selection
-----------------------------------------------------------------------------*/

module mux2 #(
    parameter P_WIDTH = 32  // Default data width is 32 bits
)(
    input  logic [P_WIDTH:0] i_a,   // First input
    input  logic [P_WIDTH:0] i_b,   // Second input
    input  logic               i_sel, // Selection signal
    output logic [P_WIDTH:0] o_y    // Output
);

    // Combinational logic
    assign o_y = i_sel ? i_b : i_a;  // Select i_b when i_sel=1, otherwise i_a

endmodule