/*-----------------------------------------------------------------------------
    PBL3 - RISC-V Processor
    Data Memory Module

    File name: datamemory.sv
    Usage: rtl/riscv_top.sv
    
    Description:
    A parameterized RAM module with single read/write port and word-addressable access.
-----------------------------------------------------------------------------*/
module data_memory #(
    parameter P_ADDR_WIDTH = 11,
    parameter P_DATA_WIDTH = 32
)(
    input logic                         i_clk,
    input logic                         i_we,
    input logic     [P_ADDR_WIDTH-1:0]  i_addr,
    input logic     [1:0]               i_storetype,
    input logic     [P_DATA_WIDTH-1:0]  i_wdata,
    output logic    [P_DATA_WIDTH-1:0]  o_rdata
);

    logic [P_DATA_WIDTH-1:0] mem_r [0:2**(P_ADDR_WIDTH)-1];
    
    assign o_rdata = mem_r[i_addr];

    always_ff @(posedge i_clk) begin
        if (i_we) begin
            case (i_storetype)
                2'b00: begin // SB
                    // Write only the lower 8 bits
                    mem_r[i_addr][7:0] <= i_wdata[7:0];
                end
                2'b01: begin // SH
                    // Write only the lower 16 bits
                    mem_r[i_addr][15:0] <= i_wdata[15:0];
                end
                default: begin // SW
                    mem_r[i_addr] <= i_wdata;
                end
            endcase
        end
    end

endmodule