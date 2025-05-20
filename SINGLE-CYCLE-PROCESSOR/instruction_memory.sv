/**
    PBL3 - Instruction Memory for RISC-V Single Cycle Processor
    Intruction Memory module

    file name: instruction_memory.sv 

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

module instruction_memory #(
    parameter DATA_WIDTH = 32,                // word size
    parameter ADDR_WIDTH = 8                  // memory size
)(
    input  logic [ADDR_WIDTH-1:0] i_pc,        // Program counter input
    output logic [DATA_WIDTH-1:0] o_instr      // Instruction output
);

    // 1KB instruction memory (1024 bytes, 256 words)
    logic [DATA_WIDTH-1:0] l_rom [0:(2**ADDR_WIDTH)-1];
    
    // Read instruction
    assign o_instr = l_rom[i_pc];

endmodule

/*
Help
https://projectf.io/posts/initialize-memory-in-verilog/
*/