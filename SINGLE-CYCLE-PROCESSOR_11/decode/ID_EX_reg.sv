module ID_EX_reg #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
) (
    input logic i_clk,
    input logic i_rst_n,
    
    //from controller
    input logic                     i_regwrite_d,
    input logic [1:0]               i_resultsrc_d,
    input logic                     i_memwrite_d,
    input logic                     i_jump_d,
    input logic                     i_branch_d,
    input logic [2:0]               i_alucrtl_d,
    input logic                     i_alusrc_d,

    //regfile
    input logic [DATA_WIDTH-1:0]    i_rs1_data_d,
    input logic [DATA_WIDTH-1:0]    i_rs2_data_d,
    
    //pc
    input logic [DATA_WIDTH-1:0]    i_pc_d, 

    // instr
    input logic [ADDR_WIDTH-1:0]    i_rs1_addr_d,  
    input logic [ADDR_WIDTH-1:0]    i_rs2_addr_d,
    input logic [ADDR_WIDTH-1:0]    i_rd_addr_d,

    //extend
    input logic [DATA_WIDTH-1:0]    i_immext_d,
    input logic [DATA_WIDTH-1:0]    i_pc4_d,

    //-------OUTPUTS-------

    output logic                     i_regwrite_e,
    output logic [1:0]               i_resultsrc_e,
    output logic                     i_memwrite_e,
    output logic                     i_jump_e,
    output logic                     i_branch_e,
    output logic [2:0]               i_alucrtl_e,
    output logic                     i_alusrc_e,

    output logic [DATA_WIDTH-1:0]    i_rs1_data_e,
    output logic [DATA_WIDTH-1:0]    i_rs2_data_e,

    output logic [DATA_WIDTH-1:0]    i_pc_e, 

    // instr
    output logic [ADDR_WIDTH-1:0]  i_rs1_addr_e,  
    output logic [ADDR_WIDTH-1:0]  i_rs2_addr_e,
    output logic [ADDR_WIDTH-1:0]  i_rd_addr_e,

    //extend
    output logic [DATA_WIDTH-1:0]  i_immext_e,
    output logic [DATA_WIDTH-1:0]  i_pc4_e,

);
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_regwrite_e <= 1'b0;
            o_resultsrc_e <= 2'b00;
            o_memwrite_e <= 1'b0;
            o_jump_e <= 1'b0;
            o_branch_e <= 1'b0;
            o_aluctrl_e <= 3'b000;
            o_alusrc_e <= 1'b0;
            
            o_rs1_data_e <= {DATA_WIDTH{1'b0}};
            o_rs2_data_e <= {DATA_WIDTH{1'b0}};
            o_pc_e <= {DATA_WIDTH{1'b0}};
            
            o_rs1_addr_e <= {ADDR_WIDTH{1'b0}};
            o_rs2_addr_e <= {ADDR_WIDTH{1'b0}};
            o_rd_addr_e <= {ADDR_WIDTH{1'b0}};
            
            o_immext_e <= {DATA_WIDTH{1'b0}};
            o_pc4_e <= {DATA_WIDTH{1'b0}};
        end
        else begin
            o_regwrite_e <= i_regwrite_d;
            o_resultsrc_e <= i_resultsrc_d;
            o_memwrite_e <= i_memwrite_d;
            o_jump_e <= i_jump_d;
            o_branch_e <= i_branch_d;
            o_aluctrl_e <= i_aluctrl_d;
            o_alusrc_e <= i_alusrc_d;
            
            o_rs1_data_e <= i_rs1_data_d;
            o_rs2_data_e <= i_rs2_data_d;
            o_pc_e <= i_pc_d;
            
            o_rs1_addr_e <= i_rs1_addr_d;
            o_rs2_addr_e <= i_rs2_addr_d;
            o_rd_addr_e <= i_rd_addr_d;
            
            o_immext_e <= i_immext_d;
            o_pc4_e <= i_pc4_d;
        end
    end

endmodule