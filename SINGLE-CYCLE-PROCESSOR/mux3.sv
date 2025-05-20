`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: David Machado Couto Bezerra
// 
// Create Date: 05/19/2025
// Module Name: mux3
// Project Name: SYNGLE_CYCLE
// Tool Versions: 1.0
// Description: multiplexer 3 to 1
//
// Additional Comments: 
//////////////////////////////////////////////////////////////////////////////////


module mux3 #(parameter DATA_WIDTH = 32) (
    input logic [DATA_WIDTH-1:0]    i_d0, i_d1, i_d2,
    input logic [1:0]               i_sel,
    output logic [DATA_WIDTH-1:0]   o_y
);

    assign o_y = i_sel[1] ? i_d2 : (i_sel[0] ? i_d1 : i_d0);

endmodule
