module hazard_stage (
    input logic i_clk,
        
    // instruction from IF/ID pipeline register
    input logic [31:0] if_id_instr,     
    
    // signals from the decode stage
    input logic i_branch_d,             
    input logic i_jump_d,               
    
    // signals from the execute stage  
    input logic [4:0] i_rs1_addr_e,    
    input logic [4:0] i_rs2_addr_e,    
    input logic [4:0] i_rd_addr_e,      
    input logic       i_regwrite_e,     
    input logic [1:0] i_resultsrc_e,    
    
    // signals from the memory stage
    input logic [4:0] i_rd_addr_m,     
    input logic i_regwrite_m,              

    // signals from the writeback stage
    input logic [4:0] i_rd_addr_w,   
    input logic i_regwrite_w,            

    // branch control signals
    input logic i_pcsrc_e,             
    
    // output signals for pipeline control
    output logic o_stall_f,         
    output logic o_stall_d,            
    output logic o_flush_d,          
    output logic o_flush_e,           
    
    // forwarding signals
    output logic [1:0] o_forward_a_e,  
    output logic [1:0] o_forward_b_e 
);

    // forwarding parameters
    localparam [1:0] NO_FORWARD = 2'b00; 
    localparam [1:0] FORWARD_W  = 2'b01;
    localparam [1:0] FORWARD_M  = 2'b10;   

    // === instruction field extraction ===
    logic [4:0] rs1_addr_d, rs2_addr_d;  // Rs1D, Rs2D
    
    always_comb begin
        rs1_addr_d = if_id_instr[19:15];  // Rs1D
        rs2_addr_d = if_id_instr[24:20];  // Rs2D
    end

    // === load-use hazard detection ===  
    // lwStall = ResultSrcE[0] & ((Rs1D == RdE) | (Rs2D == RdE))
    // ResultSrcE[0] = 1 indica instrução de load
    logic lw_stall;
    
    always_comb begin
        lw_stall = i_resultsrc_e[0] & ((rs1_addr_d == i_rd_addr_e) | (rs2_addr_d == i_rd_addr_e));
    end
    
    // === pipeline control signals ===
    always_comb begin
        // StallF = lwStall  
        // StallD = lwStall
        o_stall_f = lw_stall;
        o_stall_d = lw_stall;
        
        // FlushD = PCSrcE
        // FlushE = lwStall | PCSrcE  
        o_flush_d = i_pcsrc_e;
        o_flush_e = lw_stall | i_pcsrc_e;
    end
    
    // === forwarding logic ===
    
    // forwardAE for Rs1E:
    // if ((Rs1E == RdM) & RegWriteM) & (Rs1E != 0) then ForwardAE = 10
    // else if ((Rs1E == RdW) & RegWriteW) & (Rs1E != 0) then ForwardAE = 01  
    // else ForwardAE = 00
    always_comb begin
        if (((i_rs1_addr_e == i_rd_addr_m) & i_regwrite_m) & (i_rs1_addr_e != 0)) begin
            o_forward_a_e = FORWARD_M;  // 2'b10 - memory (RdM) forward 
        end
        else if (((i_rs1_addr_e == i_rd_addr_w) & i_regwrite_w) & (i_rs1_addr_e != 0)) begin
            o_forward_a_e = FORWARD_W;  // 2'b01 - writeback (RdW) forward
        end
        else begin
            o_forward_a_e = NO_FORWARD; // 2'b00 - without forwarding
        end
    end
    
    // forwardBE for Rs2E:
    // if ((Rs2E == RdM) & RegWriteM) & (Rs2E != 0) then ForwardBE = 10
    // else if ((Rs2E == RdW) & RegWriteW) & (Rs2E != 0) then ForwardBE = 01
    // else ForwardBE = 00  
    always_comb begin
        if (((i_rs2_addr_e == i_rd_addr_m) & i_regwrite_m) & (i_rs2_addr_e != 5'b0)) begin
            o_forward_b_e = FORWARD_M;  // 2'b10 - memory (RdM) forward 
        end
        else if (((i_rs2_addr_e == i_rd_addr_w) & i_regwrite_w) & (i_rs2_addr_e != 5'b0)) begin
            o_forward_b_e = FORWARD_W;  // 2'b01 - writeback (RdW) forward
        end
        else begin
            o_forward_b_e = NO_FORWARD; // 2'b00 - without forwarding
        end
    end

endmodule