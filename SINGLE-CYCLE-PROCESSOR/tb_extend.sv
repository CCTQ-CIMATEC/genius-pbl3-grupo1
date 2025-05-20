`timescale 1ns/1ps

module extend_tb;

    logic [31:7] i_instr;
    logic [1:0]  i_immsrc;
    logic [31:0] i_immext;

    //instancia o DUT
    extend dut (
        .i_instr(i_instr),
        .i_immsrc(i_immsrc),
        .i_immext(i_immext)
    );

    initial begin
        $display("\n--- testbench extend ---\n");

        // Teste 1: I-type (ex: LW, ADDI)
        i_instr = 25'b1000000000000000000000000; // imm[11:0] = 0x800
        i_immsrc = 2'b00;
        #1;
        $display("I-type: instr=0x%h -> immext=0x%h", i_instr, i_immext);

        // Teste 2: S-type (ex: SW)
        i_instr = 0;
        i_instr[31:25] = 7'b1000000;  // imm[11:5] = 0x40
        i_instr[11:7]  = 5'b01010;    // imm[4:0]  = 0x0A
        i_immsrc = 2'b01;
        #1;
        $display("S-type: instr=0x%h -> immext=0x%h", i_instr, i_immext);

        // Teste 3: B-type (ex: BEQ)
        i_instr = 0;
        i_instr[31]    = 1'b1;       // imm[12]
        i_instr[7]     = 1'b0;       // imm[11]
        i_instr[30:25] = 6'b000010;  // imm[10:5]
        i_instr[11:8]  = 4'b1010;    // imm[4:1]
        i_immsrc = 2'b10;
        #1;
        $display("B-type: instr=0x%h -> immext=0x%h", i_instr, i_immext);

        // Teste 4: J-type (ex: JAL)
        i_instr = 0;
        i_instr[31]    = 1'b0;            // imm[20]
        i_instr[19:12] = 8'b00001010;     // imm[19:12]
        i_instr[20]    = 1'b1;            // imm[11]
        i_instr[30:21] = 10'b0000001010;  // imm[10:1]
        i_immsrc = 2'b11;
        #1;
        $display("J-type: instr=0x%h -> immext=0x%h", i_instr, i_immext);

        $display("\n--- fim testbench extend ---\n");
        $finish;
    end

endmodule
