`timescale 1ns/1ps

module extend_tb;

    logic [31:7] instr;
    logic [1:0]  immsrc;
    logic [31:0] immext;

    //instancia o DUT
    extend dut (
        .instr(instr),
        .immsrc(immsrc),
        .immext(immext)
    );

    initial begin
      $display("\n--- testbench extend ---\n");

        //teste 1: I-type (ex: LW, ADDI)
        instr = 25'b1000000000000000000000000; // imm[11:0] = 0x800
        immsrc = 2'b00;
        #1;
        $display("I-type: instr=0x%h -> immext=0x%h", instr, immext);

        //teste 2: S-type (ex: SW)
        instr = 0;
        instr[31:25] = 7'b1000000;  // imm[11:5] = 0x40
        instr[11:7]  = 5'b01010;    // imm[4:0]  = 0x0A
        immsrc = 2'b01;
        #1;
        $display("S-type: instr=0x%h -> immext=0x%h", instr, immext);

        //teste 3: B-type (ex: BEQ)
        instr = 0;
        instr[31]    = 1'b1;       // imm[12]
        instr[7]     = 1'b0;       // imm[11]
        instr[30:25] = 6'b000010;  // imm[10:5]
        instr[11:8]  = 4'b1010;    // imm[4:1]
        immsrc = 2'b10;
        #1;
        $display("B-type: instr=0x%h -> immext=0x%h", instr, immext);

        //teste 4: J-type (ex: JAL)
        instr = 0;
        instr[31]    = 1'b0;            // imm[20]
        instr[19:12] = 8'b00001010;     // imm[19:12]
        instr[20]    = 1'b1;            // imm[11]
        instr[30:21] = 10'b0000001010;  // imm[10:1]
        immsrc = 2'b11;
        #1;
        $display("J-type: instr=0x%h -> immext=0x%h", instr, immext);


      $display("\n--- fim testbench extend ---\n");
        $finish;
    end

endmodule
