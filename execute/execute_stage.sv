/**
    PBL3 - RISC-V Pipeline Processor
    Execute Stage (EX) Module
    File name: execute_stage.sv
    Objective:
        Implement the execute stage of the RISC-V pipeline processor.
        Handles ALU operations, branch condition evaluation, and address calculations.
    Specification:
        - Integrates ALU for arithmetic/logic operations
        - Calculates branch/jump target addresses
        - Evaluates branch conditions
        - Handles immediate value selection
        - Supports forwarding inputs from later pipeline stages
        - Generates control signals for next stages
    Functional Diagram:
                     +------------------------+
                     |                        |
    rs1_data ------> |                        |
    rs2_data ------> |                        |----> alu_result
    imm_data ------> |      EXECUTE STAGE     |----> branch_taken
    pc_current ----->|                        |----> target_addr
    alucontrol ----->|                        |----> zero_flag
    alusrc --------->|                        |
    branch --------->|                        |
    jump ----------> |                        |
                     +------------------------+
**/
//----------------------------------------------------------------------------- 
//  Execute Stage Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps

module execute_stage (
    // Data inputs from ID/EX pipeline register
    input  logic [31:0] i_rs1_data_e,    // Register source 1 data
    input  logic [31:0] i_rs2_data_e,    // Register source 2 data
    input  logic [31:0] i_immext_e,      // Immediate value (sign-extended)
    input  logic [31:0] i_pc_e,          // Current PC value
    input  logic [31:0] i_pc4_e,         // PC+4 value
    
    // Address inputs for forwarding logic
    input  logic [4:0]  i_rs1_addr_e,    // RS1 address
    input  logic [4:0]  i_rs2_addr_e,    // RS2 address
    input  logic [4:0]  i_rd_addr_e,     // RD address
    
    // Control signals from ID/EX pipeline register
    input  logic [2:0]  i_aluctrl_e,     // ALU operation control (3-bit from your decode)
    input  logic        i_alusrc_e,      // ALU source select (0=reg, 1=imm)
    input  logic        i_branch_e,      // Branch instruction flag
    input  logic        i_jump_e,        // Jump instruction flag
    input  logic        i_regwrite_e,    // Register write enable
    input  logic        i_memwrite_e,    // Memory write enable
    input  logic [1:0]  i_resultsrc_e,   // Result source select
    
    // Forwarding inputs (from MEM and WB stages)
    input  logic [31:0] i_forward_mem,   // Forwarded data from MEM stage
    input  logic [31:0] i_forward_wb,    // Forwarded data from WB stage
    input  logic [1:0]  i_forward_a,     // Forward control for operand A
    input  logic [1:0]  i_forward_b,     // Forward control for operand B
    
    // Outputs to EX/MEM pipeline register
    output logic [31:0] o_alu_result,    // ALU computation result
    output logic [31:0] o_rs2_data,      // RS2 data (for store operations)
    output logic [31:0] o_target_addr,   // Branch/jump target address
    output logic        o_zero_flag,     // ALU zero flag
    
    // Pass-through control signals
    output logic        o_regwrite_m,    // Register write enable to MEM
    output logic        o_memwrite_m,    // Memory write enable to MEM
    output logic [1:0]  o_resultsrc_m,   // Result source to MEM
    output logic [4:0]  o_rd_addr_m,     // RD address to MEM
    output logic [31:0] o_pc4_m          // PC+4 to MEM
);

    // Internal signals
    logic [31:0] alu_operand_a;          // ALU input A (after forwarding)
    logic [31:0] alu_operand_b;          // ALU input B (after forwarding/mux)
    logic [31:0] rs1_forwarded;          // RS1 after forwarding
    logic [31:0] rs2_forwarded;          // RS2 after forwarding
    logic [3:0]  alu_control_extended;   // Extended ALU control signal

    //-------------------------------------------------------------------------
    // Forwarding Logic for Operand A (RS1)
    //-------------------------------------------------------------------------
    always_comb begin
        case (i_forward_a)
            2'b00:   rs1_forwarded = i_rs1_data_e;    // No forwarding
            2'b01:   rs1_forwarded = i_forward_wb;    // Forward from WB stage
            2'b10:   rs1_forwarded = i_forward_mem;   // Forward from MEM stage
            default: rs1_forwarded = i_rs1_data_e;
        endcase
    end

    //-------------------------------------------------------------------------
    // Forwarding Logic for Operand B (RS2)
    //-------------------------------------------------------------------------
    always_comb begin
        case (i_forward_b)
            2'b00:   rs2_forwarded = i_rs2_data_e;    // No forwarding
            2'b01:   rs2_forwarded = i_forward_wb;    // Forward from WB stage
            2'b10:   rs2_forwarded = i_forward_mem;   // Forward from MEM stage
            default: rs2_forwarded = i_rs2_data_e;
        endcase
    end

    //-------------------------------------------------------------------------
    // ALU Input Selection
    //-------------------------------------------------------------------------
    assign alu_operand_a = rs1_forwarded;
    
    // ALU Source B Multiplexer (register or immediate)
    assign alu_operand_b = i_alusrc_e ? i_immext_e : rs2_forwarded;
    
    // Extend 3-bit ALU control to 4-bit for your ALU
    assign alu_control_extended = {1'b0, i_aluctrl_e};

    //-------------------------------------------------------------------------
    // ALU Instantiation
    //-------------------------------------------------------------------------
    alu alu_inst (
        .i_a          (alu_operand_a),
        .i_b          (alu_operand_b),
        .i_alucontrol (alu_control_extended),
        .o_result     (o_alu_result),
        .o_zero       (o_zero_flag)
    );

    //-------------------------------------------------------------------------
    // Branch/Jump Target Address Calculation
    //-------------------------------------------------------------------------
    assign o_target_addr = i_pc_e + i_immext_e;

    //-------------------------------------------------------------------------
    // Pass RS2 data for store operations
    //-------------------------------------------------------------------------
    assign o_rs2_data = rs2_forwarded;
    
    //-------------------------------------------------------------------------
    // Pass-through control signals to EX/MEM pipeline register
    //-------------------------------------------------------------------------
    assign o_regwrite_m  = i_regwrite_e;
    assign o_memwrite_m  = i_memwrite_e;
    assign o_resultsrc_m = i_resultsrc_e;
    assign o_rd_addr_m   = i_rd_addr_e;
    assign o_pc4_m       = i_pc4_e;

endmodule