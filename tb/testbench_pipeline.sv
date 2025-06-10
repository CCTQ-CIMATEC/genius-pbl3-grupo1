/**
 * PBL3 - RISC-V Pipelined Processor  
 * Testbench Module (Pipeline Version)
 *
 * File name: testbench_pipeline.sv
 *
 * Objective:
 *     Verification environment for RISC-V 5-stage pipelined processor with standardized signal prefixes.
 *     Provides stimulus generation, memory initialization, and result checking with pipeline-aware timing.
 *
 *     Enhanced testbench featuring:
 *     - Prefix-based signal type identification (i_/l_/r_)
 *     - Pipeline delay consideration (5 cycles for full execution)
 *     - Type-consistent monitoring points
 *     - Strict naming convention enforcement
 *
 * Specification:
 *     - i_ prefix: Input signals to DUT
 *     - l_ prefix: Local testbench signals/wires
 *     - r_ prefix: Register-type signals
 *     - Active-low reset (i_rst_n)
 *     - Clock generation with l_clk
 *     - Pipeline-aware result checking
 *
 * Functional Diagram:
 *
 *                 +-----------------------+
 *                 |                       |
 *                 |      TESTBENCH        |
 *                 |                       |
 *                 |  +-----------------+  |
 *                 |  | Clock Generator |  |--l_clk--> DUT
 *                 |  +-----------------+  |
 *                 |                       |
 *                 |  +-----------------+  |
 *                 |  | Reset Sequencer |  |--l_rst_n-> DUT
 *                 |  +-----------------+  |
 *                 |                       |
 *                 |  +-----------------+  |
 *                 |  | Pipeline Monitor|  |<--internal signals-- DUT
 *                 |  +-----------------+  |
 *                 |                       |
 *                 +-----------------------+
 *
 * Signal Descriptions:
 *     l_clk       - Generated clock signal (i_clk in DUT)
 *     l_rst_n     - Generated reset signal (i_rst_n in DUT)
 *     r_WriteData - Monitored write data from memory stage
 *     r_DataAdr   - Monitored address from memory stage
 *     l_MemWrite  - Active-high write strobe monitor
 *
 * Pipeline Considerations:
 *     - 5-stage pipeline: IF -> ID -> EX -> MEM -> WB
 *     - Memory operations occur in MEM stage (stage 4)
 *     - Results available 5 cycles after instruction fetch
 *     - Hazard handling may introduce additional delays
 *
 * Test Sequence:
 *     1. Initialization:
 *        - $readmemh loads instruction memory
 *        - l_rst_n pulse sequence (0-1 transition)
 *
 *     2. Execution:
 *        - l_clk free-runs at 500MHz
 *        - Monitors pipeline stages
 *        - Accounts for pipeline latency
 *
 *     3. Completion:
 *        - Checks memory write operations
 *        - Terminates on success/failure
 *
 * Memory Initialization:
 *     Path: Adjust path as needed for your test program
 *     Target: Pipeline instruction memory
 *     Format: Verilog hex memory file
 *
 * Clock Generation:
 *     Properties:
 *     - 500MHz (1ns high, 1ns low)
 *     - l_clk signal drives DUT
 *     - Continuous operation
 *
 * Reset Control:
 *     Sequence:
 *     t=0ns: l_rst_n = 0 (reset active)
 *     t=5ns: l_rst_n = 1 (reset released)
 *     Effect: Full pipeline reset and initialization
 *
 * Verification Logic:
 *     Trigger: negedge l_clk
 *     Success Case:
 *     r_DataAdr == 100 && r_WriteData == 25
 *     Failure Case:
 *     Unexpected r_DataAdr (!= 96) during l_MemWrite
 *
 * Usage Guide:
 *     1. Set correct instruction memory path
 *     2. Maintain prefix consistency
 *     3. Account for pipeline delays in timing
 *     4. Adjust success/failure addresses as needed
 *
 * Debug Support:
 *     - Pipeline stage monitoring
 *     - Hazard detection observation
 *     - Memory operation tracking
 *     - Clear termination messages
 */

//----------------------------------------------------------------------------- 
// Testbench Implementation
//-----------------------------------------------------------------------------
`timescale 1ns/1ps

module testbench_pipeline();

    // Signal declarations
    logic           l_clk;         // Clock signal
    logic           l_rst_n;       // Reset signal (active low)
    
    // Internal pipeline monitoring signals
    logic [31:0]    r_WriteData;   // Data to be written to memory (from MEM stage)
    logic [31:0]    r_DataAdr;     // Memory address for write operation (from MEM stage)
    logic           l_MemWrite;    // Memory write enable signal (from MEM stage)
    
    // Pipeline stage monitoring (optional for debug)
    logic [31:0]    l_if_pc;       // Current PC in IF stage
    logic [31:0]    l_if_instr;    // Current instruction in IF stage
    logic           l_stall_f;     // Fetch stall signal
    logic           l_flush_d;     // Decode flush signal
    logic [1:0]     l_forward_a;   // Forward control A
    logic [1:0]     l_forward_b;   // Forward control B
    
    // Cycle counter for pipeline timing analysis
    integer         cycle_count;

    //=========================================================================
    // DUT Instantiation
    //=========================================================================
    pipeline #(
        .P_DATA_WIDTH(32),
        .P_ADDR_WIDTH(10),
        .P_REG_ADDR_WIDTH(5)
    ) dut (
        .i_clk(l_clk),
        .i_rst_n(l_rst_n)
    );

    //=========================================================================
    // Signal Monitoring Assignments
    //=========================================================================
    // Monitor memory stage signals for verification
    assign r_WriteData = dut.ex_mem_write_data;
    assign r_DataAdr   = dut.ex_mem_alu_result;
    assign l_MemWrite  = dut.ex_mem_memwrite;
    
    // Optional: Monitor pipeline control signals for debug
    assign l_if_pc     = dut.if_id_pc;
    assign l_if_instr  = dut.if_id_instr;
    assign l_stall_f   = dut.stall_f;
    assign l_flush_d   = dut.flush_d;
    assign l_forward_a = dut.forward_a;
    assign l_forward_b = dut.forward_b;

    //=========================================================================
    // Test Initialization
    //=========================================================================
    initial begin
        // Initialize cycle counter
        cycle_count = 0;

        // Load instructions into instruction memory from a file
        // NOTE: Adjust the path to match your instruction memory location
        // The hierarchical path needs to point to the instruction memory in the fetch stage
        $readmemh("/home/david/Documents/PBL03/PBL3_equipe1/rtl/test0.txt", 
                  dut.u_fetch_stage.u_instrucmem.l_rom);
        
        // Reset sequence for pipelined processor:
        // Active-low reset: assert (0), hold for sufficient time, then release (1)
        l_rst_n <= 0;  // Assert reset
        #10;           // Hold reset for 10ns (5 clock cycles)
        l_rst_n <= 1;  // Release reset
        
        $display("Pipeline processor testbench started");
        $display("Reset sequence completed at time %0t", $time);
    end

    //=========================================================================
    // Clock Generation
    //=========================================================================
    // Creates a continuous clock with 1ns high and 1ns low (500MHz, 50% duty cycle)
    always begin
        l_clk <= 1; #1; l_clk <= 0; #1;
    end
    
    //=========================================================================
    // Cycle Counter
    //=========================================================================
    // Count clock cycles for pipeline timing analysis
    always @(posedge l_clk) begin
        if (l_rst_n) begin
            cycle_count <= cycle_count + 1;
        end else begin
            cycle_count <= 0;
        end
    end

    //=========================================================================
    // Result Verification
    //=========================================================================
    // Check results on negative clock edges (when clock transitions from 1 to 0)
    always @(negedge l_clk) begin
        if (l_rst_n && l_MemWrite) begin  // Only check during memory write operations after reset
            
            $display("Cycle %0d: Memory Write - Address: %0d, Data: %0d", 
                     cycle_count, r_DataAdr, r_WriteData);
            
            // Check for success condition:
            // If writing value 25 to address 100, simulation succeeded
            if ((r_DataAdr === 100) && (r_WriteData === 25)) begin
                $display("\n=== PIPELINE SIMULATION SUCCESS ===");
                $display("Final result: Address %0d = %0d", r_DataAdr, r_WriteData);
                $display("Total cycles: %0d", cycle_count);
                $display("Simulation time: %0t", $time);
                $display("=====================================\n");
                #10;  // Small delay before stopping
                $stop;  // Stop simulation on success
                
            // Check for failure condition:
            // If writing to any address other than 96 (expected intermediate address),
            // and it's not the success case, simulation failed
            end else if (r_DataAdr !== 96) begin
                $display("\n=== PIPELINE SIMULATION FAILED ===");
                $display("Unexpected write: Address %0d = %0d", r_DataAdr, r_WriteData);
                $display("Expected: Address 100 = 25 or Address 96 = intermediate");
                $display("Cycle: %0d, Time: %0t", cycle_count, $time);
                $display("===================================\n");
                #10;  // Small delay before stopping
                $stop;  // Stop simulation on failure
            end
        end
    end

    //=========================================================================
    // Pipeline Debug Monitoring (Optional)
    //=========================================================================
    // Uncomment the following block for detailed pipeline debugging
    /*
    always @(posedge l_clk) begin
        if (l_rst_n) begin
            $display("Cycle %0d: PC=%h, Instr=%h, Stall_F=%b, Flush_D=%b, Fwd_A=%b, Fwd_B=%b",
                     cycle_count, l_if_pc, l_if_instr, l_stall_f, l_flush_d, l_forward_a, l_forward_b);
        end
    end
    */

    //=========================================================================
    // Timeout Protection
    //=========================================================================
    // Prevent infinite simulation in case of issues
    initial begin
        #10000;  // 10μs timeout
        $display("\n=== SIMULATION TIMEOUT ===");
        $display("Simulation exceeded maximum time limit");
        $display("Check for infinite loops or stalls");
        $display("==========================\n");
        $stop;
    end

endmodule