module hazard_stage (
    input logic i_clk,
    input logic i_reset,
    
    // signals from the decode stage
    input logic [4:0] i_rs1_addr_d,     // source register 1 address (decode)
    input logic [4:0] i_rs2_addr_d,     // source register 2 address (decode)
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
        
        if (i_memread_e && i_rd_addr_e != 5'b0) begin
            if ((i_rd_addr_e == i_rs1_addr_d) || (i_rd_addr_e == i_rs2_addr_d)) begin
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
            if ((i_rd_addr_e == i_rs1_addr_d) || (i_rd_addr_e == i_rs2_addr_d)) begin
                data_hazard_e = 1'b1;
            end
        end
        
        // hazard with memory stage
        if (i_regwrite_m && i_rd_addr_m != 5'b0) begin
            if ((i_rd_addr_m == i_rs1_addr_d) || (i_rd_addr_m == i_rs2_addr_d)) begin
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
        
        // forwarding from memory stage
        if (i_regwrite_m && i_rd_addr_m != 5'b0 && i_rd_addr_m == i_rs1_addr_d) begin
            o_forward_a_e = FORWARD_M;
        end
        // forwarding from writeback stage (lower priority)
        else if (i_regwrite_w && i_rd_addr_w != 5'b0 && i_rd_addr_w == i_rs1_addr_d) begin
            o_forward_a_e = FORWARD_W;
        end
    end
    
    // forward b (operand b)
    always_comb begin
        o_forward_b_e = NO_FORWARD;
        
        // forwarding from memory stage
        if (i_regwrite_m && i_rd_addr_m != 5'b0 && i_rd_addr_m == i_rs2_addr_d) begin
            o_forward_b_e = FORWARD_M;
        end
        // forwarding from writeback stage (lower priority)
        else if (i_regwrite_w && i_rd_addr_w != 5'b0 && i_rd_addr_w == i_rs2_addr_d) begin
            o_forward_b_e = FORWARD_W;
        end
    end

endmodule
