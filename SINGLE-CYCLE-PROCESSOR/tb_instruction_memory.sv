`timescale 1ns / 1ps
module tb_instruction_memory;

    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 8;
   
    logic [ADDR_WIDTH-1:0] i_pc;
    logic [DATA_WIDTH-1:0] o_instr;
    
    // Instantiate instruction memory
    instruction_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .i_pc       (i_pc),
        .o_instr    (o_instr)
    );
    
    logic [DATA_WIDTH-1:0] expected [0:19];

    initial begin
        // Initialize ROM
        $readmemh("test0.txt", uut.l_rom);

        foreach (expected[i]) begin
            expected[i] = uut.l_rom[i];
        end

        $display("Testbench for instruction_memory");
        $display("-----------------------------------------------");
        
        // 1. Test first address
        i_pc = 0;
        #1;
        $display("Test 1 - PC (word idx) = %08h | Expected: 0x%08h | Received: 0x%08h %s",
            i_pc, expected[0], o_instr, (o_instr === expected[0]) ? "PASS" : "FAIL");
        
        // 2. Test second instruction
        i_pc = 1;
        #1;
        $display("Test 2 - PC (word idx) = %08h | Expected: 0x%08h | Received: 0x%08h %s",
            i_pc, expected[1], o_instr, (o_instr === expected[1]) ? "PASS" : "FAIL");
        
        // 3. Test 12th instruction
        i_pc = 11;
        #1;
        $display("Test 3 - PC (word idx) = %08h | Expected: 0x%08h | Received: 0x%08h %s",
            i_pc, expected[11], o_instr, (o_instr === expected[11]) ? "PASS" : "FAIL");
        
        // 4. Test 17th instruction
        i_pc = 16;
        #1;
        $display("Test 4 - PC (word idx) = %08h | Expected: 0x%08h | Received: 0x%08h %s",
            i_pc, expected[16], o_instr, (o_instr === expected[16]) ? "PASS" : "FAIL");
        
        $display("-----------------------------------------------");
        $display("Tests completed");
        $finish;
    end
    
endmodule