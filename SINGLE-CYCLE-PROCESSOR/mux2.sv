`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: David Machado Couto Bezerra
// 
// Create Date: 05/19/2025
// Module Name: mux2
// Project Name: SYNGLE_CYCLE
// Tool Versions: 1.0
// Description: multiplexer 2 to 1
//
// Additional Comments: 
//////////////////////////////////////////////////////////////////////////////////

module mux2 #(parameter DATA_WIDTH = 32)(
        input logic [DATA_WIDTH-1:0]    i_d0, i_d1,
        input logic                     i_sel,
        output logic [DATA_WIDTH-1:0]   o_y
);

    assign o_y = i_sel ? i_d0 : i_d1;

endmodule
