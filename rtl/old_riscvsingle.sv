/**
    PBL3 - RISC-V Single Cycle Processor
    Top-level module for RISC-V processor implementation

    File name: riscvsingle.sv

    Objective:
        Implement a complete single-cycle RISC-V processor core with:
        - Control unit
        - Datapath
        - Instruction fetch
        - Memory interface
        - Register file
        - ALU operations

    Specification:
        - Supports RV32I base instruction set
        - Single clock cycle per instruction
        - Implements control signals for:
            * Register writes
            * ALU operations
            * Memory access
            * Branch/Jump operations
            * Immediate generation
        - Handles all R-format, I-format, S-format, B-format, and J-format instructions
        - Reset initializes all registers and control signals

    Operations:
        - Instruction Fetch: PC increments by 4 or branches/jumps.
        - Decode: Splits instruction into fields (opcode, funct3, funct7, etc.).
        - Execution: ALU performs operations (arithmetic, logical, shifts, comparisons).
        - Memory Access: Loads/stores data (if applicable) using o_MemWrite.
        - Writeback: Updates register file (if l_RegWrite=1) from ALU result, memory, or PC+4.

    Functional Diagram:

                       +----------------------------------+
                       |                                  |
                       |       RISC-V SINGLE CYCLE        |
                       |           PROCESSOR              |
                       |                                  |
        i_clk      --->|                                  |
        i_reset    --->|  +------------+  +------------+  |
        i_Instr    --->|  | Controller |  |  Datapath  |  |
        i_ReadData --->|  +------------+  +------------+  |
                       |                                  |---> o_PC
                       |                                  |---> o_MemWrite
                       |                                  |---> o_ALUResult
                       |                                  |---> o_WriteData
                       +----------------------------------+

    Inputs:
        i_clk      - System clock
        i_reset    - Asynchronous reset (active high)
        i_Instr    - 32-bit instruction from instruction memory
        i_ReadData - 32-bit data from data memory (for load instructions)

    Outputs:
        o_PC        - 32-bit program counter (next instruction address)
        o_MemWrite  - Memory write enable (active high for store instructions)
        o_ALUResult - 32-bit ALU result (address for stores or computation result)
        o_WriteData - 32-bit data to be written to memory (for store instructions)

    Control Signals:
        l_PCSrc     - Selects next PC (PC+4 or branch/jump target)
        l_ALUSrc    - Selects ALU operand (register or immediate)
        l_RegWrite  - Enables register file write
        l_Jump      - Indicates jump instruction
        l_Zero      - ALU zero flag (used for branches)
        r_ResultSrc - Selects writeback source (ALU, memory, or PC+4)
        r_ImmSrc    - Controls immediate value generation
        r_ALUControl- ALU operation selection (add/sub/and/or/xor/slt/sll/srl/sra)
**/

//----------------------------------------------------------------------------- 
//  rRISC-V Nodule
//-----------------------------------------------------------------------------
`timescale 1ns/1ps  // Simulation time unit = 1ns, precision = 1ps
module riscvsingle (
    // Inputs
    input  logic        i_clk,          // System clock
    input  logic        i_rst_p,        // Active-high asynchronous reset
    input  logic [31:0] i_Instr,        // 32-bit instruction from memory
    input  logic [31:0] i_ReadData,     // 32-bit data from data memory

    // Outputs
    output logic [31:0] o_PC,           // 32-bit program counter (next instruction address)
    output logic        o_MemWrite,     // Memory write enable signal
    output logic [31:0] o_ALUResult,    // 32-bit ALU computation result
    output logic [31:0] o_WriteData     // 32-bit data to be written to memory
);

    // Control signals
    logic        l_PCSrc, l_ALUSrc, l_RegWrite, l_Jump, l_Zero;
    logic [1:0]  r_ResultSrc, r_ImmSrc;
    logic [2:0]  r_ALUControl;

    // Controller instance (corrected port order)
    controller c (
        .i_op          (i_Instr[6:0]),       // 7-bit opcode field from instruction
        .i_funct3      (i_Instr[14:12]),     // 3-bit funct3 field from instruction
        .i_funct7b5    (i_Instr[30]),        // funct7 bit 5 (for R-type instructions)
        .i_zero        (l_Zero),             // Zero flag from ALU (for branch instructions)
        .o_alucrtl     (r_ALUControl),       // 3-bit ALU control signal
        .o_resultsrc   (r_ResultSrc),        // Result multiplexer select (for writeback)
        .o_immsrc      (r_ImmSrc),           // Immediate format select
        .o_memwrite    (o_MemWrite),         // Data memory write enable
        .o_pcsrc       (l_PCSrc),            // PC source select (branch/jump)
        .o_alusrc      (l_ALUSrc),           // ALU source select (reg/immediate)
        .o_regwrite    (l_RegWrite),         // Register file write enable
        .o_jump        (l_Jump)              // Jump instruction flag
    );

    // Datapath instance (corrected signals and reset polarity)
    datapath dp (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_p),            // Convert active-high to active-low
        .i_resultsrc   (r_ResultSrc),
        .i_pcsrc       (l_PCSrc),
        .i_alusrc      (l_ALUSrc),
        .i_regwrite    (l_RegWrite),
        .i_immsrc      (r_ImmSrc),
        .i_alucontrol  (r_ALUControl),       // Matches controller's o_alucrtl
        .i_instr       (i_Instr),
        .i_readdata    (i_ReadData),
        .o_zero        (l_Zero),
        .o_pc          (o_PC),
        .o_aluresult   (o_ALUResult),
        .o_writedata   (o_WriteData)
    );

endmodule