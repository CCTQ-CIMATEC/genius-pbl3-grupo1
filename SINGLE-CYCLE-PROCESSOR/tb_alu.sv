`timescale 1ns/1ps

module tb_alu;

    logic [31:0] l_a, l_b;
    logic [3:0]  l_alu_ctrl;
    logic [31:0] s_result;
    logic        s_zero;

    // Instancia o DUT
    alu u_alu (
        .i_a        (l_a),
        .i_b        (l_b),
        .i_alu_ctrl (l_alu_ctrl),
        .o_result   (s_result),
        .o_zero     (s_zero)
    );

    task automatic run_test(
        input string t_name,
        input logic [31:0] t_a,
        input logic [31:0] t_b,
        input logic [3:0]  t_ctrl,
        input logic [31:0] t_expected
    );
        begin
            l_a        = t_a;
            l_b        = t_b;
            l_alu_ctrl = t_ctrl;
            #1;
            $display("[%s] A=%0h, B=%0h, Result=%0h (Expected=%0h), Zero=%b",
                     t_name, l_a, l_b, s_result, t_expected, s_zero);
        end
    endtask

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars;

        $display("\n--- alu testbench---\n");

        run_test("AND", 32'hA5A5A5A5, 32'hFF00FF00, 4'b0000, 32'hA500A500);
        run_test("OR",  32'h12345678, 32'h00FF00FF, 4'b0001, 32'h12FF56FF);
        run_test("ADD", 32'd10,       32'd5,        4'b0010, 32'd15);
        run_test("SUB", 32'd10,       32'd3,        4'b0110, 32'd7);
        run_test("SLT", 32'd2,        32'd5,        4'b0111, 32'd1);
        run_test("NOR", 32'hFFFF0000, 32'h0000FFFF, 4'b1100, 32'h00000000);
        run_test("ZERO",32'd2,        32'd2,        4'b0110, 32'd0); // Teste de zero flag

        $display("\n--- fim testbench ---\n");
        $finish;
    end

endmodule
