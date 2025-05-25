module testbench();

    logic       clk;
    logic       reset;
    logic [31:0] WriteData, DataAdr;
    logic       MemWrite;

    // Instantiate device under test
    top dut(clk, reset, WriteData, DataAdr, MemWrite);

    // Initialize test and load instruction memory
    initial begin
        // Load instructions into instruction memory
        $readmemh("/home/david/Documents/PBL03/PBL3_equipe1/SINGLE-CYCLE-PROCESSOR/test0.txt", dut.imem.l_rom); // Hierarchical path to ROM array
        reset <= 1; #1; reset <= 0; #12; reset <= 1;           // Apply reset
        
    end

    // Generate clock
    always begin
        clk <= 1; #1; clk <= 0; #1;
    end

    // Check results
    always @(negedge clk) begin
        if (MemWrite) begin
            if ((DataAdr === 100) & (WriteData === 25)) begin
                $display(" HERE !!! Simulation succeeded  HERE !!! \n\n\n");
                $stop;
            end else if (DataAdr !== 96) begin
                $display("Simulation failed");
                $stop;
            end
        end
    end

endmodule