module write_back #(

    parameter P_WIDTH = 32
)(
    input  logic [P_WIDTH-1:0] i_alu_result_w,
    input  logic [P_WIDTH-1:0] i_mem_data_w,
    input  logic [P_WIDTH-1:0] i_pc_plus_4_w,
    input  logic [1:0]         i_sel_w,   // LOOK HERE -> i_resultsrc
    output logic [P_WIDTH-1:0] o_write_data_w
    
);

    logic [P_WIDTH-1:0] mux0_out_w;

    // Primeiro mux: ALU result ou memória
    mux2 #(.P_WIDTH(P_WIDTH)) mux0 (
        .in0(i_alu_result_w),
        .in1(i_mem_data_w),
        .sel(i_sel_w[0]),
        .out(mux0_out_w)
    );

    // Segundo mux: saída do primeiro mux ou PC+4
    mux2 #(.P_WIDTH(P_WIDTH)) mux1 (
        .in0(mux0_out_w),
        .in1(i_pc_plus_4_w),
        .sel(i_sel_w[1]),
        .out(o_write_data_w)
    );

endmodule
