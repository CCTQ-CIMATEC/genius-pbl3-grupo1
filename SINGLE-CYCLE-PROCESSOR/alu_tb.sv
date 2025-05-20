`timescale 1ns/1ps

module alu_tb;

    logic [31:0] a, b;
    logic [3:0]  alucontrol;
    logic [31:0] result;
    logic        zero;

    //instancia o DUT
    alu dut (
        .a(a),
        .b(b),
        .alucontrol(alucontrol),
        .result(result),
        .zero(zero)
    );

    task test_case(input string op, input [31:0] op_a, op_b, input [3:0] ctrl, input [31:0] expected);
        begin
            a = op_a;
            b = op_b;
            alucontrol = ctrl;
            #1;
            $display("%s: a=%0d b=%0d -> result=%0d (esperado=%0d), zero=%b",
                     op, a, b, result, expected, zero);
        end
    endtask

    initial begin
      $dumpfile("dump.vcd");
  $dumpvars;
      $display("\n--- testbench alu ---\n");

        test_case("AND", 32'hA5A5A5A5, 32'hFF00FF00, 4'b0000, 32'hA500A500);
        test_case("OR",  32'h12345678, 32'h00FF00FF, 4'b0001, 32'h12FF56FF);
        test_case("ADD", 10, 5, 4'b0010, 15);
        test_case("SUB", 10, 5, 4'b0110, 5);
        test_case("SLT", 3, 7, 4'b0111, 1);
        test_case("SLT", 7, 3, 4'b0111, 0);
        test_case("NOR", 32'h0F0F0F0F, 32'hF0F0F0F0, 4'b1100, ~(32'hFFFFFFFF));

      $display("\n--- fim testbench alu ---\n");
        $finish;
    end

endmodule
