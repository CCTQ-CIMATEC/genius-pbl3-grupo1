/**
    PBL3 - RISC-V Single Cycle Processor
    Datapath Module

    File name: datapath.sv

    Objective:
        Implement the complete datapath for a single-cycle RISC-V processor.
        Integrates all major components for instruction execution including:
        - Program counter logic
        - Register file
        - ALU operations
        - Immediate generation
        - Result selection

        Implements the main data processing pipeline of the processor

    Specification:
        - 32-bit datapath (configurable via parameters)
        - Supports all RISC-V instruction formats (R, I, S, B, U, J)
        - Implements:
            * PC update logic (sequential and branches)
            * Register file with two read ports and one write port
            * ALU with configurable operations
            * Immediate value generation
            * Result selection for writeback (ALU, memory, PC+4)

    Functional Diagram:

                           +-------------------------------------------------------------+
                           |                                                             |
                           |                          DATAPATH                           |
                           |                                                             |
            i_clk      --->|  +------------+   +---------------+   +-----------------+   |
            i_rst_n    --->|  |            |   |               |   |                 |   |
                           |  |  PC Logic  |   |  Register     |   |    ALU &        |   |
            i_instr    --->|  |            |   |  File         |   |    Execution    |   |
                           |  |  +------+  |   |  +----------+ |   |    +--------+   |   |
            i_readdata --->|  |  |PC Reg|  |   |  | Registers| |   |    | ALU    |   |   |
                           |  |  +------+  |   |  +----------+ |   |    +--------+   |   |
            control    --->|  |      ^     |   |       ^       |   |        ^        |   |
            signals    --->|  |      |     |   |       |       |   |        |        |   |
                           |  |  +------+  |   |  +---------+  |   |    +--------+   |   |
                           |  |  |PC+4 |   |   |  | Imm Gen |  |   |    | Result |   |   |
                           |  |  +------+  |   |  +---------+  |   |    | Mux    |   |   |
                           |  |      ^     |   |       ^       |   |    +--------+   |   |
                           |  |      |     |   |       |       |   |        ^        |   |
                           |  |  +------+  |   |  +---------+  |   |        |        |   |
                           |  |  |Branch|  |   |  | Src B   |  |   |    +--------+   |   |
                           |  |  |Target|  |   |  | Mux     |  |   |    | Src A  |   |   |---> o_pc
                           |  |  +------+  |   |  +---------+  |   |    +--------+   |   |---> o_aluresult
                           |  +------------+   +---------------+   +-----------------+   |---> o_writedata
                           |                                                             |---> o_zero
                           +-------------------------------------------------------------+
    
    Parameters:
        P_DATA_WIDTH - Width of data bus (default 32-bit)
        P_ADDR_WIDTH - Width of address bus (default 8-bit)

    Inputs:
        i_clk         - System clock
        i_rst_n       - Active-low reset
        i_resultsrc   - Selects writeback source (00:ALU, 01:memory, 10:PC+4)
        i_pcsrc       - Selects next PC (0:PC+4, 1:branch target)
        i_alusrc      - Selects ALU operand B (0:register, 1:immediate)
        i_regwrite    - Register file write enable
        i_immsrc      - Immediate format selector
        i_alucontrol  - ALU operation control
        i_instr       - Current instruction
        i_readdata    - Data from memory (for load instructions)

    Outputs:
        o_pc         - Current program counter value
        o_aluresult  - ALU computation result
        o_writedata  - Data to store to memory
        o_zero       - ALU zero flag (for branches)

    Internal Components:
        - Program counter register and increment logic
        - Register file with 32 registers
        - Immediate value generator
        - ALU with operand selection mux
        - Result selection multiplexer

    Operation:
        1. Instruction fetched using PC
        2. Register file reads source operands
        3. ALU performs operation (with immediate if needed)
        4. For loads, memory data selected for writeback
        5. For branches, PC target calculated
        6. Result written back to register file (if enabled)
**/

//----------------------------------------------------------------------------- 
//  Datapath Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps
module datapath #(
    parameter P_DATA_WIDTH = 32,  // Width of data bus (default 32-bit)
    parameter P_ADDR_WIDTH = 8    // Width of address bus (default 8-bit)
) (
    input  logic                      i_clk, i_rst_n,      // Clock and active-low reset
    input  logic [1:0]                i_resultsrc,         // Result selection control
    input  logic                      i_pcsrc,             // PC source selection (next PC or branch target)
    input  logic                      i_alusrc,            // ALU source selection (register or immediate)
    input  logic                      i_regwrite,          // Register write enable
    input  logic [1:0]                i_immsrc,            // Immediate value extension type
    input  logic [2:0]                i_alucontrol,        // ALU operation control
    input  logic [P_DATA_WIDTH-1:0]   i_instr,             // Instruction word
    input  logic [P_DATA_WIDTH-1:0]   i_readdata,          // Data read from memory
    output logic                      o_zero,              // ALU zero flag
    output logic [P_DATA_WIDTH-1:0]   o_pc,                // Current program counter
    output logic [P_DATA_WIDTH-1:0]   o_aluresult,         // ALU computation result
    output logic [P_DATA_WIDTH-1:0]   o_writedata          // Data to write to memory
);

    // Internal signals
    logic [P_DATA_WIDTH-1:0] l_pcnext, l_pc4, l_pctarget;  // PC-related signals
    logic [P_DATA_WIDTH-1:0] l_immext;                     // Sign-extended immediate
    logic [P_DATA_WIDTH-1:0] l_src_a, l_src_b;             // ALU operands
    logic [P_DATA_WIDTH-1:0] l_result;                     // Result to write back to register file

    // Program Counter Logic ---------------------------------------------------
    // PC register (state element)
    flopr #(.P_WIDTH(8)) u_pcreg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (l_pcnext),
        .o_q     (o_pc)
    );
    
    // PC incrementer (PC + 4)
    adder #(.P_WIDTH(8)) u_pcadd4 (
        .i_a (o_pc),
        .i_b (4),                // Fixed increment for next instruction
        .o_y (l_pc4)
    );
    
    // Branch target adder (PC + immediate offset)
    adder #(.P_WIDTH(8)) u_pcaddbranch (
        .i_a (o_pc),
        .i_b (l_immext),        // Branch offset from immediate
        .o_y (l_pctarget)
    );
    
    // PC source multiplexer (select between PC+4 and branch target)
    mux2 #(.P_WIDTH(8)) u_pcmux (
        .i_a   (l_pc4),
        .i_b   (l_pctarget),
        .i_sel (i_pcsrc),        // Controlled by branch decision
        .o_y   (l_pcnext)
    );

    // Register File Logic -----------------------------------------------------
    regfile u_rf (
        .i_clk        (i_clk),           // Clock system
        .i_rst_n      (i_rst_n),         // Reset active in Low
        .i_rs1_addr   (i_instr[19:15]),  // Source register 1 address
        .i_rs2_addr   (i_instr[24:20]),  // Source register 2 address
        .i_rd_addr    (i_instr[11:7]),   // Destination register address
        .i_rd_data    (l_result),        // Data to write to register
        .i_reg_write  (i_regwrite),      // Write enable
        .o_rs1_data   (l_src_a),         // Output data for source 1 (to ALU)
        .o_rs2_data   (o_writedata)      // Output data for source 2 (to memory or ALU)
    );

    // Immediate Generation Logic ----------------------------------------------
    extend u_ext (
        .i_instr     (i_instr[31:7]),    // Relevant bits of instruction for immediate
        .i_immsrc    (i_immsrc),         // Control for immediate type (I-type, S-type, etc.)
        .o_immext    (l_immext)          // Sign-extended immediate value
    );

    // ALU Source Selection ---------------------------------------------------
    mux2 u_srcbmux(
        .i_a    (o_writedata),           // Value from register file (rs2)
        .i_b    (l_immext),              // Immediate value
        .i_sel  (i_alusrc),              // Selects between register and immediate
        .o_y    (l_src_b)                // Second operand to ALU
    );

    // ALU Logic --------------------------------------------------------------
    alu u_alu(
        .i_a            (l_src_a),       // First operand (always from rs1)
        .i_b            (l_src_b),       // Second operand (register or immediate)
        .i_alucontrol   (i_alucontrol),  // ALU operation control
        .o_result       (o_aluresult),   // ALU computation result
        .o_zero         (o_zero)         // Zero flag (for branch comparison)
    );

    // Result Selection Logic -------------------------------------------------
    mux3 u_resultmux(
        .i_d0   (o_aluresult),  // ALU result (for R-type/I-type operations)
        .i_d1   (i_readdata),   // Data from memory (for load instructions)
        .i_d2   (l_pc4),        // PC+4 (for jal instructions)
        .i_sel  (i_resultsrc),  // Result source selection
        .o_y    (l_result)      // Final result to write back to register file
    );

endmodule