/*-------------------------------------------------------------------------
  PBL3 - RISC-V Processor
  Writeback Stage
 
  File name: writeback_cycle.sv
  Usage: writeback_cycle.sv
 
  Objective:
      Implements the memory access stage of a pipelined RISC-V processor.
      Interfaces with external data memory and forwards pipeline data.
-------------------------------------------------------------------------*/

module write_back #(
    parameter P_WIDTH = 32
)(
    input  logic [P_WIDTH-1:0]  i_alu_result_w,
    input  logic [P_WIDTH-1:0]  i_mem_data_w,
    input  logic [10:0]         i_pc_plus_4_w,
    input  logic [1:0]          i_sel_w,
    input  logic [2:0]          i_f3_w,
    output logic [P_WIDTH-1:0]  o_result_w
);

    logic [31:0] lpc;
    assign lpc = {22'b0, i_pc_plus_4_w};

    logic [31:0] extended_load_data;
    logic [7:0]  byte_data;
    logic [15:0] half_data;

    always_comb begin
        case (i_f3_w)
            3'b000: extended_load_data = {{24{i_mem_data_w[7]}},  i_mem_data_w[7:0]};   // LB
            3'b001: extended_load_data = {{16{i_mem_data_w[15]}}, i_mem_data_w[15:0]};  // LH
            3'b010: extended_load_data = i_mem_data_w;                                  // LW
            3'b100: extended_load_data = {24'b0, i_mem_data_w[7:0]};                    // LBU
            3'b101: extended_load_data = {16'b0, i_mem_data_w[15:0]};                   // LHU
            default: extended_load_data = i_mem_data_w;                                 // Fallback
        endcase
    end

    logic [P_WIDTH-1:0] mux0_out_w;

    // MUX 1
    assign mux0_out_w = i_sel_w[0] ? extended_load_data : i_alu_result_w;

    // MUX 2
    assign o_result_w = i_sel_w[1] ? lpc : mux0_out_w;

endmodule