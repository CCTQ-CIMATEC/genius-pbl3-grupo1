/**
    PBL3 - RISC-V Single Cycle Processor  
    Testbench Module (Updated Naming Convention)

    File name: testbench.sv

    Objective:
        Verification environment for RISC-V single-cycle processor with standardized signal prefixes.
        Provides stimulus generation, memory initialization, and result checking with clear signal typing.

        Enhanced testbench featuring:
        - Prefix-based signal type identification (i_/l_/r_)
        - Type-consistent monitoring points
        - Strict naming convention enforcement

    Specification:
        - i_ prefix: Input signals to DUT
        - l_ prefix: Local testbench signals/wires
        - r_ prefix: Register-type signals
        - Active-high reset (l_reset)
        - Clock generation with l_clk
        - Monitored outputs use r_ prefix for registered values

    Functional Diagram:

                    +-----------------------+
                    |                       |
                    |      TESTBENCH        |
                    |                       |
                    |  +-----------------+  |
                    |  | Clock Generator |  |--l_clk--> DUT
                    |  +-----------------+  |
                    |                       |
                    |  +-----------------+  |
                    |  | Reset Sequencer |  |--l_reset-> DUT
                    |  +-----------------+  |
                    |                       |
                    |  +-----------------+  |
                    |  | Result Checker  |  |<--r_* signals-- DUT
                    |  +-----------------+  |
                    |                       |
                    +-----------------------+

    Signal Descriptions:
        l_clk       - Generated clock signal (i_ in DUT)
        l_reset     - Generated reset signal (i_ in DUT)
        r_WriteData - Registered write data monitor
        r_DataAdr   - Registered address monitor
        l_MemWrite  - Active-high write strobe monitor

    Prefix Convention:
        i_  - Inputs to modules (not used in testbench top)
        l_  - Local wires/variables (testbench internal)
        r_  - Registered outputs/state elements

    Test Sequence:
        1. Initialization:
           - $readmemh loads l_rom in imem
           - l_reset pulse sequence (1-0-1)

        2. Execution:
           - l_clk free-runs at 500MHz
           - Monitors r_* signals on negedge

        3. Completion:
           - Checks r_DataAdr/r_WriteData
           - Terminates on success/failure

    Memory Initialization:
        Path: /home/david/Documents/PBL03/PBL3_equipe1/SINGLE-CYCLE-PROCESSOR/test0.txt
        Target: dut.imem.l_rom (hierarchical path)
        Format: Verilog hex memory file

    Clock Generation:
        Properties:
        - 500MHz (1ns high, 1ns low)
        - l_clk signal drives DUT
        - Infinite duration

    Reset Control:
        Sequence:
        t=0ns: l_reset = 1
        t=1ns: l_reset = 0
        t=13ns: l_reset = 1
        Effect: Full system reset

    Verification Logic:
        Trigger: negedge l_clk
        Success Case:
        r_DataAdr == 100 && r_WriteData == 25
        Failure Case:
        Unexpected r_DataAdr (!= 96) during l_MemWrite

    Usage Guide:
        1. Set correct imem path
        2. Maintain prefix consistency:
           - i_ for DUT inputs
           - l_ for testbench signals
           - r_ for monitored values
        3. Adjust success/failure addresses as needed

    Debug Support:
        - All r_ signals observable
        - l_MemWrite triggers checks
        - Clear termination messages
**/

//----------------------------------------------------------------------------- 
// Testbench Implementation
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module testbench();
    // [Rest of the implementation remains unchanged]
endmodule

//----------------------------------------------------------------------------- 
// Testbench
//-----------------------------------------------------------------------------
`timescale 1ns/1ps   // Simulation time unit = 1ns, precision = 1ps
module testbench();

    // Signal declarations
    logic           i_clk;         // Clock signal
    logic           l_reset;       // Reset signal
    logic [31:0]    r_WriteData,   // Data to be written to memory
    logic [31:0]    r_DataAdr;     // Memory address for write operation
    logic           l_MemWrite;    // Memory write enable signal

    // Instantiate the device under test (DUT)
    // This connects the testbench signals to the processor module
    top dut(l_clk, l_reset, r_WriteData, r_DataAdr, l_MemWrite);

    // Initialize test and load instruction memory
    initial begin
        // Load instructions into instruction memory from a file
        // The hierarchical path points to the ROM array inside the instruction memory
        $readmemh("/home/david/Documents/PBL03/PBL3_equipe1/SINGLE-CYCLE-PROCESSOR/test0.txt", dut.imem.l_rom);
        
        // Reset sequence:
        // Assert reset (1), wait 1 time unit, deassert reset (0), wait 12 time units, 
        // then assert reset again (1)
        l_reset <= 1; #1; l_reset <= 0; #12; l_reset <= 1;
    end

    // Clock generation
    // Creates a continuous clock with 1 time unit high and 1 time unit low (50% duty cycle)
    always begin
        l_clk <= 1; #1; l_clk <= 0; #1;
    end

    // Check results on negative clock edges (when clock transitions from 1 to 0)
    always @(negedge l_clk) begin
        if (l_MemWrite) begin  // Only check during memory write operations
            
            // Check for success condition:
            // If writing value 25 to address 100, simulation succeeded
            if ((r_DataAdr === 100) & (r_WriteData === 25)) begin
                $display(" HERE !!! Simulation succeeded  HERE !!! \n\n\n");
                $stop;  // Stop simulation on success
                
            // Check for failure condition:
            // If writing to any address other than 96 (expected intermediate address),
            // simulation failed
            end else if (r_DataAdr !== 96) begin
                $display("Simulation failed");
                $stop;  // Stop simulation on failure
            end
        end
    end

endmodule