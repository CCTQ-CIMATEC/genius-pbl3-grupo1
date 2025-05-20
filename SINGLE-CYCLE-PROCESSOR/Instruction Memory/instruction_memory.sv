/**
    PBL3 - Instruction Memory for RISC-V Single Cycle Processor
    Intruction Memory module

    Objective:
        Implement a word-addressable instruction memory for RISC-V processor.
        The memory should initialize with a program and provide synchronous read access.
    
    Specification:
        - 1KB memory (256 words of 32 bits each)
        - Word-addressable (byte addresses converted to word addresses)
        - Asynchronous read (combinational output)
        - Initialized with program code at startup
        - PC input is byte-addressable but converted to word address by dropping last 2 bits

Functional Diagram

                    +---------------------------+
                    |         Module            |
                    |   INSTRUCTION MEMORY      |
                    |                           |
    i_pc[31:0] ---->| Program Counter 32 bits   |                      |
                    |                           |
                    |                           |
                    |       Instruction 32 bits |---> o_instr[31:0]
                    |                           |
                    +---------------------------+
                
**/

/**
Implementation Note:

    // Instruction memory instance
    instruction_memory #(
        .INIT_FILE("cpu_firmware.mem"),
        .SAFE_START(1'b1)  // Safe boot enabled
    ) imem (
        .i_pc(pc),
        .o_instr(instruction)
    );
    
**/

//-----------------------------------------------------------------------------
// instruction_memory.sv 
//-----------------------------------------------------------------------------
module instruction_memory #(
    parameter word_size = 32,                  // Word size
    parameter ROM_SIZE = 256,                  // ROM size in words
    parameter INIT_FILE = "program.mem",       // Initialization file
    parameter SAFE_START = 1'b1                // Enable initial NOP
)(
    input  logic [word_size-1:0] i_pc,         // Program counter input
    output logic [word_size-1:0] o_instr       // Instruction output
);

    // Instruction memory with protection
    logic [word_size-1:0] r_rom [0:ROM_SIZE-1];
    logic [word_size-1:0] safe_instr;
    
    // Secure memory initialization
    initial begin        
        // Fill entire memory with zeros (safe execution)
        foreach (r_rom[i]) begin
            r_rom[i] = {word_size{1'b0}};
        end
        
        // Load program from file (with 1-word offset if SAFE_START enabled)
        $display("Loading ROM from %s...", INIT_FILE);
        if (SAFE_START) begin
            $readmemh(INIT_FILE, r_rom, 1);  // Start loading at position 1
        end else begin
            $readmemh(INIT_FILE, r_rom);     // Load from position 0
        end
        
        // 3. Force NOP at first address if SAFE_START enabled
        if (SAFE_START) begin
            r_rom[0] = 32'h00000013;          // NOP instruction
            $display("Safety NOP inserted at address 0x00000000");
        end
    end
    
    // Safety read logic
    always_comb begin
        // Memory boundary checking
        if (i_pc[word_size-1:2] >= ROM_SIZE) begin
            safe_instr = {word_size{1'b0}};    // Return NOP if out of bounds
        end else begin
            safe_instr = r_rom[i_pc[word_size-1:2]];
        end
        
        // Additional first-cycle NOP guarantee (optional)
        if (SAFE_START && (i_pc == {word_size{1'b0}})) begin
            o_instr = 32'h00000013;           // NOP at first address
        end else begin
            o_instr = safe_instr;             // Normal instruction
        end
    end
    
endmodule


/*

module instruction_memory #(
    parameter wrd_size = 32                  // Word size
)(
    input  logic [wrd_size-1:0] i_pc,        // Program counter input
    output logic [wrd_size-1:0] o_instr      // Instruction output
);

    // 1KB instruction memory (1024 bytes, 256 words)
    logic [wrd_size-1:0] r_rom [0:255];
    
    // Initialize memory (Load Hex Program)
    initial begin        
        // Read Hex file
        $display("Loading ROM...");
        $readmemh("program.mem", r_rom);
    end
    
    // Read instruction (word-aligned)
    assign instr = r_rom[i_pc[wrd_size-1:2]];  // Divide by 4 to get word address

endmodule



/*
Help
https://projectf.io/posts/initialize-memory-in-verilog/



        Feature: NOP instruction on line '0'
        // NOP (or your first instruction)
        r_mem[0] = word_size-1'h0000_0000;  
        
        fetures:  - Outputs zero for addresses beyond memory size
        // Fill rest with zeros if your programm has less 256 lines
        for (integer i = last_line+1; i < 256; i = i + 1) begin
            r_mem[i] = word_size-1'h0000_0000;
        end
*/

