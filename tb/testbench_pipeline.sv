/*-----------------------------------------------------------------------------
  PBL3 - RISC-V Pipelined Processor  
  Testbench Module (Top-Level)
 
  File name: testbench_pipeline.sv
 
  Objective:
      Verification environment for RISC-V 5-stage pipelined processor with external memories.
      Provides stimulus generation, memory initialization, and result checking with pipeline-aware timing.
  
  Signal Descriptions:
      l_clk       - Generated clock signal (i_clk in DUT)
      l_rst_n     - Generated reset signal (i_rst_n in DUT)
      r_WriteData - Monitored write data from data memory interface
      r_DataAdr   - Monitored address from data memory interface
      l_MemWrite  - Active-high write strobe monitor

  Test Sequence:
      1. Initialization:
         - $readmemh loads instruction memory
         - l_rst_n pulse sequence (0-1 transition)
 
      2. Execution:
         - l_clk free-runs at 500MHz
 
      3. Completion:
         - Checks memory write operations
         - Terminates on success/failure
 
  Memory Initialization:
      Path: Adjust path
      Target: External instruction memory
 
  Verification Logic:
      Success Case:
      r_DataAdr == 100 && r_WriteData == 25
-----------------------------------------------------------------------------*/

`timescale 1ns/1ps

module testbench_pipeline();

    logic           l_clk;         // Clock signal
    logic           l_rst_n;       // Reset signal
    
    // Internal pipeline monitoring signals
    logic [31:0]    r_WriteData;   // Data to be written to memory
    logic [31:0]    r_DataAdr;     // Memory address for write operation
    logic           l_MemWrite;    // Memory write enable signal
    // Memory interface monitoring signals
    logic [8:0]     l_imem_addr;   // Instruction memory address
    logic [31:0]    l_imem_rdata;  // Instruction memory read data
    logic [7:0]     l_dmem_addr;   // Data memory address
    logic [31:0]    l_dmem_wdata;  // Data memory write data
    logic [31:0]    l_dmem_rdata;  // Data memory read data
    logic           l_dmem_we;     // Data memory write enable
    // Pipeline stage monitoring
    logic [31:0]    l_if_pc;       // Current PC in IF/ID stage
    logic [31:0]    l_if_instr;    // Current instruction in IF/ID stage
    
    integer         cycle_count;

    // DUT Instantiation
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

    // Signal Monitoring Assignments
    assign r_WriteData = dut.dmem_wdata;
    assign r_DataAdr   = dut.dmem_addr;
    assign l_MemWrite  = dut.dmem_we;
    
    assign l_imem_addr = dut.imem_addr;
    assign l_imem_rdata = dut.imem_rdata;
    assign l_dmem_addr = dut.dmem_addr;
    assign l_dmem_wdata = dut.dmem_wdata;
    assign l_dmem_rdata = dut.dmem_rdata;
    assign l_dmem_we = dut.dmem_we;

    assign l_if_pc     = dut.u_riscv_core.if_id_pc;
    assign l_if_instr  = dut.u_riscv_core.if_id_instr;

    initial begin

        // Initialize cycle counter
        cycle_count = 0;

        // Load instructions
        $readmemh("/home/david/Documents/PBL03/PBL3_equipe1/rtl/test0.txt", // OBS -> Adjust the path
                  dut.u_instrucmem.l_rom);
        
        // Reset
        l_rst_n <= 0;  
        #10;           
        l_rst_n <= 1; 
        
        $display("RISC-V Top-Level processor testbench started");
        $display("Reset sequence completed at time %0t", $time);
        $display("Instruction memory loaded from: /home/david/Documents/PBL03/PBL3_equipe1/rtl/test0.txt");
    end

    // Clock Generation
    always begin
        l_clk <= 1; #1; l_clk <= 0; #1; // 500MHz

    end
    
    // Cycle Counter
    // Count clock cycles for pipeline timing analysis
    always @(posedge l_clk) begin
        if (l_rst_n) begin
            cycle_count <= cycle_count + 1;
        end else begin
            cycle_count <= 0;
        end
    end

    // Memory Interface Monitoring
    always @(posedge l_clk) begin
        if (l_rst_n) begin
            // $display("Cycle %0d: IMEM - PC: %h, Instr: %h", cycle_count, l_imem_addr, l_imem_rdata);
        end
    end

    // Result Verification
    always @(negedge l_clk) begin
        if (l_rst_n && l_MemWrite) begin
            
            $display("Cycle %0d: Data Memory Write - Address: %0d, Data: %0d", 
                     cycle_count, r_DataAdr, r_WriteData);
            
            // If writing value 25 to address 100, simulation succeeded
            if ((r_DataAdr === 100) && (r_WriteData === 25)) begin
                $display("\n=== RISC-V TOP SUCCESS ===");
                $display("Final result: Address %0d = %0d", r_DataAdr, r_WriteData);
                $display("Total cycles: %0d", cycle_count);
                $display("Simulation time: %0t", $time);
                $display("======================================\n");
                #10;
                $stop;
                
            // Check for failure condition
            end else if (r_DataAdr !== 96) begin
                $display("\n=== RISC-V TOP SIMULATION FAILED ===");
                $display("Unexpected write: Address %0d = %0d", r_DataAdr, r_WriteData);
                $display("Expected: Address 100 = 15 or Address 96 = intermediate");
                $display("Cycle: %0d, Time: %0t", cycle_count, $time);
                $display("=====================================\n");
                #10;
                $stop;
            end
        end
    end

    // Monitor data memory read operations
    always @(posedge l_clk) begin
        if (l_rst_n && !l_dmem_we && (|l_dmem_addr)) begin  // Read operation (not write, address not zero)
            $display("Cycle %0d: Data Memory Read - Address: %0d, Data: %0d", 
                     cycle_count, l_dmem_addr, l_dmem_rdata);
        end
    end

    // Error by timeout
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