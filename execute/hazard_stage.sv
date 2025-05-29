module hazard_stage (
    input logic i_clk,
    input logic i_reset,
    
    // instruction from IF/ID pipeline register
    input logic [31:0] if_id_instr,     // instruction from fetch/decode
    
    // signals from the decode stage
    input logic i_branch_d,             // branch instruction (decode)
    input logic i_jump_d,               // jump instruction (decode)
    
    // signals from the execute stage
    input logic [4:0] i_rd_addr_e,      // destination register address (execute)
    input logic i_regwrite_e,           // register write signal (execute)
    input logic i_memread_e,            // memory read signal (execute)
    
    // signals from the memory stage
    input logic [4:0] i_rd_addr_m,      // destination register address (memory)
    input logic i_regwrite_m,           // register write signal (memory)
    
    // signals from the writeback stage
    input logic [4:0] i_rd_addr_w,      // destination register address (writeback)
    input logic i_regwrite_w,           // register write signal (writeback)
    input logic [31:0] i_result_w,      // data to be written (writeback output)
    
    // branch control signals
    input logic i_branch_taken,         // branch was taken
    input logic i_jump_taken,           // jump was taken
    
    // output signals for pipeline control
    output logic o_stall_f,             // fetch stage stall
    output logic o_stall_d,             // decode stage stall
    output logic o_flush_d,             // decode stage flush
    output logic o_flush_e,             // execute stage flush
    
    // forwarding signals
    output logic [1:0] o_forward_a_e,   // forwarding for operand A (execute)
    output logic [1:0] o_forward_b_e    // forwarding for operand B (execute)
);

    // forwarding parameters
    localparam [1:0] NO_FORWARD = 2'b00;
    localparam [1:0] FORWARD_M = 2'b01;  // forward from memory
    localparam [1:0] FORWARD_W = 2'b10;  // forward from writeback

    // === instruction field extraction ===
    // extract register addresses from the instruction
    logic [4:0] rs1_addr_d, rs2_addr_d, rd_addr_d;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    
    // extract instruction fields
    always_comb begin
        opcode = if_id_instr[6:0];
        rd_addr_d = if_id_instr[11:7];
        funct3 = if_id_instr[14:12];
        rs1_addr_d = if_id_instr[19:15];
        rs2_addr_d = if_id_instr[24:20];
        funct7 = if_id_instr[31:25];
    end
    
    // === memory read detection ===
    // detect load instructions (memory read operations)
    logic is_load_instr;
    
    always_comb begin
        is_load_instr = 1'b0;
        
        // check for load instructions (opcode = 0000011)
        if (opcode == 7'b0000011) begin
            case (funct3)
                3'b000: is_load_instr = 1'b1; // LB (load byte)
                3'b001: is_load_instr = 1'b1; // LH (load halfword)
                3'b010: is_load_instr = 1'b1; // LW (load word)
                3'b100: is_load_instr = 1'b1; // LBU (load byte unsigned)
                3'b101: is_load_instr = 1'b1; // LHU (load halfword unsigned)
                default: is_load_instr = 1'b0;
            endcase
        end
    end

    // data hazard detection (raw)
    logic load_use_hazard;
    logic data_hazard_e;
    logic data_hazard_m;
    
    // control hazard detection
    logic control_hazard;
    
    // === load-use hazard detection ===
    // occurs when a load instruction is immediately followed by an instruction
    // that uses the loaded data
    always_comb begin
        load_use_hazard = 1'b0;
        
        // check if execute stage has a load instruction that writes to a register
        if ((i_memread_e || is_load_instr) && i_rd_addr_e != 5'b0) begin
            if ((i_rd_addr_e == rs1_addr_d) || (i_rd_addr_e == rs2_addr_d)) begin
                load_use_hazard = 1'b1;
            end
        end
    end
    
    // === data hazard detection ===
    // checks for dependencies between instructions
    always_comb begin
        data_hazard_e = 1'b0;
        data_hazard_m = 1'b0;
        
        // hazard with execute stage
        if (i_regwrite_e && i_rd_addr_e != 5'b0) begin
            if ((i_rd_addr_e == rs1_addr_d) || (i_rd_addr_e == rs2_addr_d)) begin
                data_hazard_e = 1'b1;
            end
        end
        
        // hazard with memory stage
        if (i_regwrite_m && i_rd_addr_m != 5'b0) begin
            if ((i_rd_addr_m == rs1_addr_d) || (i_rd_addr_m == rs2_addr_d)) begin
                data_hazard_m = 1'b1;
            end
        end
    end
    
    // === control hazard detection ===
    // occurs with branch and jump instructions
    always_comb begin
        control_hazard = i_branch_taken || i_jump_taken || i_branch_d || i_jump_d;
    end
    
    // === control signal generation ===
    always_comb begin
        // default values
        o_stall_f = 1'b0;
        o_stall_d = 1'b0;
        o_flush_d = 1'b0;
        o_flush_e = 1'b0;
        
        // load-use hazard: stall pipeline
        if (load_use_hazard) begin
            o_stall_f = 1'b1;
            o_stall_d = 1'b1;
            o_flush_e = 1'b1;  // convert instruction to nop
        end
        
        // control hazard: flush incorrect instructions
        if (i_branch_taken || i_jump_taken) begin
            o_flush_d = 1'b1;
            o_flush_e = 1'b1;
        end
        
        // branch prediction miss (simplified)
        if (i_branch_d || i_jump_d) begin
            o_flush_d = 1'b1;  // assume branch not taken as default
        end
    end
    
    // === forwarding logic ===
    // forward a (operand a)
    always_comb begin
        o_forward_a_e = NO_FORWARD;
        
        // forwarding from memory stage (higher priority)
        if (i_regwrite_m && i_rd_addr_m != 5'b0 && i_rd_addr_m == rs1_addr_d) begin
            o_forward_a_e = FORWARD_M;
        end
        // forwarding from writeback stage (lower priority)
        else if (i_regwrite_w && i_rd_addr_w != 5'b0 && i_rd_addr_w == rs1_addr_d) begin
            o_forward_a_e = FORWARD_W;
        end
    end
    
    // forward b (operand b)
    always_comb begin
        o_forward_b_e = NO_FORWARD;
        
        // forwarding from memory stage (higher priority)
        if (i_regwrite_m && i_rd_addr_m != 5'b0 && i_rd_addr_m == rs2_addr_d) begin
            o_forward_b_e = FORWARD_M;
        end
        // forwarding from writeback stage (lower priority)
        else if (i_regwrite_w && i_rd_addr_w != 5'b0 && i_rd_addr_w == rs2_addr_d) begin
            o_forward_b_e = FORWARD_W;
        end
    end

endmodule