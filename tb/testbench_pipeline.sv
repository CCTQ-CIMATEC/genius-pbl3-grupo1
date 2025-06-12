/**
 * PBL3 - RISC-V Pipelined Processor  
 * Testbench Module (Top-Level Version)
 *
 * File name: testbench_riscv_top.sv
 *
 * Objective:
 *     Verification environment for RISC-V 5-stage pipelined processor with external memories.
 *     Provides stimulus generation, memory initialization, and result checking with pipeline-aware timing.
 *
 *     Enhanced testbench featuring:
 *     - Prefix-based signal type identification (i_/l_/r_)
 *     - Pipeline delay consideration (5 cycles for full execution)
 *     - Type-consistent monitoring points
 *     - External memory interface monitoring
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
 * Signal Descriptions:
 *     l_clk       - Generated clock signal (i_clk in DUT)
 *     l_rst_n     - Generated reset signal (i_rst_n in DUT)
 *     r_WriteData - Monitored write data from data memory interface
 *     r_DataAdr   - Monitored address from data memory interface
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
 *     Target: External instruction memory
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
 *     - Memory interface tracking
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
    logic [31:0]    r_WriteData;   // Data to be written to memory (from data memory interface)
    logic [31:0]    r_DataAdr;     // Memory address for write operation (from data memory interface)
    logic           l_MemWrite;    // Memory write enable signal (from data memory interface)
    
    // Memory interface monitoring signals
    logic [8:0]     l_imem_addr;   // Instruction memory address
    logic [31:0]    l_imem_rdata;  // Instruction memory read data
    logic [7:0]     l_dmem_addr;   // Data memory address
    logic [31:0]    l_dmem_wdata;  // Data memory write data
    logic [31:0]    l_dmem_rdata;  // Data memory read data
    logic           l_dmem_we;     // Data memory write enable
    
    // Pipeline stage monitoring (optional for debug)
    logic [31:0]    l_if_pc;       // Current PC in IF/ID stage
    logic [31:0]    l_if_instr;    // Current instruction in IF/ID stage
    
    // Cycle counter for pipeline timing analysis
    integer         cycle_count;

    //=========================================================================
    // DUT Instantiation
    //=========================================================================
    riscv_top #(
        .P_DATA_WIDTH(32),
        .P_ADDR_WIDTH(10),
        .P_REG_ADDR_WIDTH(5),
        .P_IMEM_ADDR_WIDTH(9),
        .P_DMEM_ADDR_WIDTH(8)
    ) dut (
        .i_clk(l_clk),
        .i_rst_n(l_rst_n)
    );

    //=========================================================================
    // Signal Monitoring Assignments
    //=========================================================================
    // Monitor data memory interface signals for verification
    assign r_WriteData = dut.dmem_wdata;
    assign r_DataAdr   = dut.dmem_addr;
    assign l_MemWrite  = dut.dmem_we;
    
    // Monitor memory interface signals
    assign l_imem_addr = dut.imem_addr;
    assign l_imem_rdata = dut.imem_rdata;
    assign l_dmem_addr = dut.dmem_addr;
    assign l_dmem_wdata = dut.dmem_wdata;
    assign l_dmem_rdata = dut.dmem_rdata;
    assign l_dmem_we = dut.dmem_we;
    
    // Monitor processor core signals for debug
    // Fixed: Use correct signal names from riscv_core module
    assign l_if_pc     = dut.u_riscv_core.if_id_pc;      // IF/ID pipeline register PC
    assign l_if_instr  = dut.u_riscv_core.if_id_instr;   // IF/ID pipeline register instruction

    //=========================================================================
    // Test Initialization
    //=========================================================================
    initial begin
        // Initialize cycle counter
        cycle_count = 0;

        // Load instructions into instruction memory from a file
        // NOTE: Adjust the path to match your test program location
        // The hierarchical path points to the external instruction memory
        $readmemh("/home/david/Documents/GUSTAVO RISC/RISCV-RV32I/rtl/test0.txt", 
                  dut.u_instrucmem.l_rom);
        
        // Reset sequence for pipelined processor:
        // Active-low reset: assert (0), hold for sufficient time, then release (1)
        l_rst_n <= 0;  // Assert reset
        #10;           // Hold reset for 10ns (5 clock cycles)
        l_rst_n <= 1;  // Release reset
        
        $display("RISC-V Top-Level processor testbench started");
        $display("Reset sequence completed at time %0t", $time);
        $display("Instruction memory loaded from: /home/david/Documents/PBL03/PBL3_equipe1/rtl/test0.txt");
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
    // Memory Interface Monitoring
    //=========================================================================
    // Monitor instruction memory accesses
    always @(posedge l_clk) begin
        if (l_rst_n) begin
            // Uncomment for detailed instruction fetch monitoring
            // $display("Cycle %0d: IMEM - PC: %h, Instr: %h", cycle_count, l_imem_addr, l_imem_rdata);
        end
    end

    //=========================================================================
    // Result Verification
    //=========================================================================
    // Check results on negative clock edges (when clock transitions from 1 to 0)
    always @(negedge l_clk) begin
        if (l_rst_n && l_MemWrite) begin  // Only check during memory write operations after reset
            
            $display("Cycle %0d: Data Memory Write - Address: %0d, Data: %0d", 
                     cycle_count, r_DataAdr, r_WriteData);
            
            // Check for success condition:
            // If writing value 25 to address 100, simulation succeeded
            if ((r_DataAdr === 100) && (r_WriteData === 25)) begin
                $display("\n=== RISC-V TOP SIMULATION SUCCESS ===");
                $display("Final result: Address %0d = %0d", r_DataAdr, r_WriteData);
                $display("Total cycles: %0d", cycle_count);
                $display("Simulation time: %0t", $time);
                $display("======================================\n");
                #10;  // Small delay before stopping
                $stop;  // Stop simulation on success
                
            // Check for failure condition:
            // If writing to any address other than 96 (expected intermediate address),
            // and it's not the success case, simulation failed
            end else if (r_DataAdr !== 96) begin
                $display("\n=== RISC-V TOP SIMULATION FAILED ===");
                $display("Unexpected write: Address %0d = %0d", r_DataAdr, r_WriteData);
                $display("Expected: Address 100 = 15 or Address 96 = intermediate");
                $display("Cycle: %0d, Time: %0t", cycle_count, $time);
                $display("=====================================\n");
                #10;  // Small delay before stopping
                $stop;  // Stop simulation on failure
            end
        end
    end

    //=========================================================================
    // Data Memory Read Monitoring
    //=========================================================================
    // Monitor data memory read operations
    always @(posedge l_clk) begin
        if (l_rst_n && !l_dmem_we && (|l_dmem_addr)) begin  // Read operation (not write, address not zero)
            $display("Cycle %0d: Data Memory Read - Address: %0d, Data: %0d", 
                     cycle_count, l_dmem_addr, l_dmem_rdata);
        end
    end

    //=========================================================================
    // Pipeline Debug Monitoring (Optional)
    //=========================================================================
    // Uncomment the following block for detailed pipeline debugging
    /*
    always @(posedge l_clk) begin
        if (l_rst_n) begin
            $display("Cycle %0d: PC=%h, Instr=%h, IMEM_Addr=%h, DMEM_We=%b, DMEM_Addr=%h",
                     cycle_count, l_if_pc, l_if_instr, l_imem_addr, l_dmem_we, l_dmem_addr);
        end
    end
    */

    //=========================================================================
    // Memory Content Display (Optional Debug)
    //=========================================================================
    // Uncomment to display memory contents at the end of simulation
    /*
    final begin
        $display("\n=== INSTRUCTION MEMORY CONTENTS ===");
        for (int i = 0; i < 16; i++) begin
            $display("IMEM[%0d] = %h", i, dut.u_instrucmem.l_rom[i]);
        end
        
        $display("\n=== DATA MEMORY CONTENTS ===");
        for (int i = 0; i < 16; i++) begin
            $display("DMEM[%0d] = %h", i, dut.u_data_memory.l_ram[i]);
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
        $display("Current cycle: %0d", cycle_count);
        $display("Last PC: %h", l_if_pc);
        $display("==========================\n");
        $stop;
    end

endmodule