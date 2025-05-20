/**
  Testbench for instruction_memory Module
  
  Test Coverage Implemented:
  =========================
  
  1. Basic Functional Coverage:
     - Correct loading of .mem file
     - Instruction reads at different memory positions
     - Proper byte-to-word address conversion
  
  2. Boundary Tests:
     - First memory address (0x00000000)
     - Address immediately after last initialized
     - Out-of-bounds memory address
  
  3. SAFE_START Mechanism Tests:
     - Verification of NOP at first address when enabled
     - Verification of instruction offset when enabled
     - Behavior with SAFE_START disabled (not tested in this bench)
  
  4. Critical Path Coverage:
     - Normal read path (valid address)
     - Error handling path (invalid address)
     - Safe initialization path
  
  5. Specific Test Cases:
     +------------------+---------------------+---------------------------+
     | Address          | Expected Value      | Test Description          |
     +------------------+---------------------+---------------------------+
     | 0x00000000       | 0x00000013 (NOP)    | First address with safety |
     | 0x00000004       | 0xf00015b7          | First actual instruction  |
     | 0x0000002C       | 0x001c0c13          | Middle address instruction|
     | 0x00000300       | 0x00652623          | End address instruction   |
     | 0x00000400       | 0x00000000          | Out-of-bounds instruction |
     +------------------+---------------------+---------------------------+
  
  Known Limitations:
  ------------------
  - Doesn't test behavior with SAFE_START disabled
  - Doesn't test address stress (consecutive accesses)
  - Doesn't verify propagation timing (module is combinational)
  - Doesn't test loading different .mem file formats
  
  Notes:
  ------
  - Testbench assumes SAFE_START enabled (1'b1)
  - Out-of-bounds verification expects 0x00000000, which is
    the implemented behavior (some implementations use NOPs)
 
  Potential Improvements:
  -----------------------
  - Add random tests for greater coverage
  - Implement automatic assertion checking
  - Test with SAFE_START disabled
  - Verify behavior with empty .mem file
 **/

/**
Implementation Note:
    Testbench for instruction_memory (full version)
    SAFE_START = 1
    -----------------------------------------------
    Test 1 - PC = 0x00000000
    Expected: 0x00000013 (NOP) | Received: 0x00000013
    Test 2 - PC = 0x00000004
    Expected: 0xf00015b7 | Received: 0xf00015b7
    Test 3 - PC = 0x0000002c
    Expected: 0x001c0c13 | Received: 0x001c0c13
    Test 4 - PC = 0x00000300
    Expected: 0x00652623 | Received: 0x00652623
    Test 5 - PC = 0x00000400 (out of bounds)
    Expected: 0x00000000 | Received: 0x00000000
    -----------------------------------------------
    Tests completed
**/

`timescale 1ns / 1ps
module instruction_memory_tb;

    // Module parameters
    parameter word_size = 32;
    parameter ROM_SIZE = 256;
    parameter INIT_FILE = "hex_program.mem";
    parameter SAFE_START = 1'b1;
    
    // Test signals
    reg [word_size-1:0] i_pc;
    wire [word_size-1:0] o_instr;
    
    // Instantiate instruction memory
    instruction_memory #(
        .word_size(word_size),
        .ROM_SIZE(ROM_SIZE),
        .INIT_FILE(INIT_FILE),
        .SAFE_START(SAFE_START)
    ) uut (
        .i_pc(i_pc),
        .o_instr(o_instr)
    );
    
    // Test 5 specific cases
    initial begin
        $display("Testbench for instruction_memory (full version)");
        $display("SAFE_START = %b", SAFE_START);
        $display("-----------------------------------------------");
        
        // 1. Test first address (should be NOP if SAFE_START=1)
        i_pc = 32'h00000000;
        #10;
        $display("Test 1 - PC = 0x%08h", i_pc);
        $display("Expected: %s | Received: 0x%08h", 
               (SAFE_START) ? "0x00000013 (NOP)" : "0xf0000537",
               o_instr);
        
        // 2. Test second address (first actual instruction if SAFE_START=1)
        i_pc = 32'h00000004;
        #10;
        $display("Test 2 - PC = 0x%08h", i_pc);
        $display("Expected: 0xf00015b7 | Received: 0x%08h", o_instr);
        
        // 3. Test middle program address
        i_pc = 32'h0000002C; // ST_IDLE
        #10;
        $display("Test 3 - PC = 0x%08h", i_pc);
        $display("Expected: 0x001c0c13 | Received: 0x%08h", o_instr);
        
        // 4. Test end program address
        i_pc = 32'h00000300; // VICTORY
        #10;
        $display("Test 4 - PC = 0x%08h", i_pc);
        $display("Expected: 0x00652623 | Received: 0x%08h", o_instr);
        
        // 5. Test out-of-bounds address
        i_pc = 32'h00000400; // Out of memory
        #10;
        $display("Test 5 - PC = 0x%08h (out of bounds)", i_pc);
        $display("Expected: 0x00000000 | Received: 0x%08h", o_instr);
        
        $display("-----------------------------------------------");
        $display("Tests completed");
        $finish;
    end
    
endmodule