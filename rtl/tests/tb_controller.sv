/**
    PBL3 - RISC-V Single Cycle Processor  
    Controller Testbench Module

    File name: tb_controller.sv

    Objective:
        Verification environment for RISC-V control unit.
        Tests all major instruction types by exercising control signal generation.

        Features:
        - Tests all RISC-V instruction formats (R/I/S/B/J)
        - Verifies control signal combinations
        - Includes display task for results visualization
        - Covers edge cases (branch taken/not taken)

    Specification:
        - Tests 7 instruction types (lw, sw, add, sub, beq, addi, jal)
        - Checks 8 control signals
        - 1ns timing precision
        - Self-terminating
        - Clear output formatting

    Functional Diagram:

                    +-----------------------+
                    |                       |
                    |    CONTROLLER TESTBENCH |
                    |                       |
                    |  +------------------+ |
                    |  |  Stimulus Generator |<- Test Patterns
                    |  +------------------+ |
                    |           |           |
                    |           v           |
                    |  +------------------+ |
                    |  |    DUT (Controller) | 
                    |  +------------------+ |
                    |           |           |
                    |           v           |
                    |  +------------------+ |
                    |  |   Result Analyzer  |--> Console Output
                    |  +------------------+ |
                    |                       |
                    +-----------------------+

    Signal Descriptions:
        Inputs:
        i_op[6:0]     - 7-bit opcode field
        i_funct3[2:0] - 3-bit function field
        i_funct7b5    - funct7 bit 5 (for R-type differentiation)
        i_zero        - ALU zero flag (for branches)

        Outputs:
        o_alucrtl[2:0]  - ALU operation control
        o_resultsrc[1:0] - Result multiplexer select
        o_immsrc[1:0]   - Immediate generator select
        o_memwrite      - Memory write enable
        o_pcsrc         - PC source select
        o_alusrc        - ALU source select
        o_regwrite      - Register write enable
        o_jump          - Jump instruction flag

    Test Cases:
        1. lw (Load Word)
           - Verifies memory read controls
        2. sw (Store Word)
           - Tests memory write controls
        3. add (R-type)
           - Checks R-type ALU operations
        4. sub (R-type)
           - Tests funct7 differentiation
        5. beq (Branch)
           - Tests branch taken/not taken cases
        6. addi (I-type)
           - Verifies immediate operations
        7. jal (Jump and Link)
           - Tests jump controls

    Test Methodology:
        1. Apply instruction inputs
        2. Wait 1ns for propagation
        3. Display all control outputs
        4. Repeat for all instruction types

    Output Format:
        [instr] alucrtl=XXX resultsrc=XX immsrc=XX memwrite=X pcsrc=X alusrc=X regwrite=X jump=X

    Timing Characteristics:
        - 1ns delay between test cases
        - Immediate output checking
        - Zero-delay stimulus application

    Verification Points:
        - ALU control codes for each operation
        - Correct result source selection
        - Proper immediate generation
        - Memory control signals
        - PC source logic
        - Register file controls

    Usage Notes:
        1. Extend by adding new test patterns
        2. Modify print_outputs task for different formats
        3. Add assertions for automatic checking
        4. Monitor waveforms for signal transitions

    Debug Features:
        - Time-stamped output display
        - All control signals visible
        - Clear instruction identification
        - Immediate test case modification
**/

//----------------------------------------------------------------------------- 
// Controlller Testbech
//-----------------------------------------------------------------------------
`timescale 1ns/1ps  // Simulation time unit = 1ns, precision = 1ps
module tb_controller();

    // Inputs
    logic [6:0] i_op;
    logic [2:0] i_funct3;
    logic       i_funct7b5;
    logic       i_zero;

    // Outputs
    logic [2:0] o_alucrtl;
    logic [1:0] o_resultsrc, o_immsrc;
    logic       o_memwrite, o_pcsrc, o_alusrc, o_regwrite, o_jump;

    // DUT
    controller dut (
        .i_op(i_op),
        .i_funct3(i_funct3),
        .i_funct7b5(i_funct7b5),
        .i_zero(i_zero),
        .o_alucrtl(o_alucrtl),
        .o_resultsrc(o_resultsrc),
        .o_immsrc(o_immsrc),
        .o_memwrite(o_memwrite),
        .o_pcsrc(o_pcsrc),
        .o_alusrc(o_alusrc),
        .o_regwrite(o_regwrite),
        .o_jump(o_jump)
    );

    // Task to display results
    task print_outputs(string instr);
        $display("[%s] alucrtl=%b resultsrc=%b immsrc=%b memwrite=%b pcsrc=%b alusrc=%b regwrite=%b jump=%b",
                 instr, o_alucrtl, o_resultsrc, o_immsrc, o_memwrite, o_pcsrc, o_alusrc, o_regwrite, o_jump);
    endtask

    initial begin
        // Test lw
        i_op = 7'b0000011;  // lw
        i_funct3 = 3'b010;
        i_funct7b5 = 1'b0;
        i_zero = 1'b0;
        #1; print_outputs("lw");

        // Test sw
        i_op = 7'b0100011;  // sw
        i_funct3 = 3'b010;
        i_funct7b5 = 1'b0;
        i_zero = 1'b0;
        #1; print_outputs("sw");

        // Test add (R-type)
        i_op = 7'b0110011;  // R-type
        i_funct3 = 3'b000;
        i_funct7b5 = 1'b0;
        i_zero = 1'b0;
        #1; print_outputs("add");

        // Test sub (R-type)
        i_op = 7'b0110011;
        i_funct3 = 3'b000;
        i_funct7b5 = 1'b1;
        i_zero = 1'b0;
        #1; print_outputs("sub");

        // Test beq
        i_op = 7'b1100011;  // beq
        i_funct3 = 3'b000;
        i_funct7b5 = 1'b0;
        i_zero = 1'b1; // Should take branch
        #1; print_outputs("beq - taken");
        i_zero = 1'b0; // Should not take branch
        #1; print_outputs("beq - not taken");

        // Test I-type ALU (addi)
        i_op = 7'b0010011;
        i_funct3 = 3'b000;
        i_funct7b5 = 1'b0;
        i_zero = 1'b0;
        #1; print_outputs("addi");

        // Test jal
        i_op = 7'b1101111;  // jal
        i_funct3 = 3'b000;
        i_funct7b5 = 1'b0;
        i_zero = 1'b0;
        #1; print_outputs("jal");

        $finish;
    end

endmodule