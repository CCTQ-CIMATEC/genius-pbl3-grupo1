/**
 * PBL3 - RISC-V Pipelined Processor
 * Memory Stage Module
 * 
 * File name: memory_stage.v
 * 
 * Objective:
 *     Implements the memory access stage of a pipelined RISC-V processor.
 *     Handles memory read/write and selects the correct result to forward.
 * 
 * Description:
 *     - Writes data to memory if enabled
 *     - Reads data from memory
 *     - Selects between memory read result or PC+4 as final result
 * 
 * Functional Diagram:
 * 
 *                       +-------------------------+
 *                       |      MEMORY STAGE       |
 *                       |                         |
 *  i_memwrite --->      |                         |
 *  i_result_m ---->     |      DATA MEMORY        |--> o_read_data_w
 *  i_rs2_data_m -->     |                         |
 *                       |                         |
 *                       |   +-----------------+   |
 *  i_resultsrc_m -->    |                         |
                         |                         |--> o_result_w
 *  i_pc4_m -------->    |                         |   
 *                       +-------------------------+
 */

        module memory_stage #(
            parameter P_DATA_WIDTH = 32,
            parameter P_ADDR_WIDTH = 8
)(
            input  logic                      i_clk,                 // clock
            input  logic                      i_mem_we_m,            // memory write enable signal
            input  logic [P_DATA_WIDTH-1:0]   i_alu_result_m,        // address calculated by the ALU (coming from the EX stage)
            input  logic [P_DATA_WIDTH-1:0]   i_write_data_m,        // data to be written to memory
            output logic [P_DATA_WIDTH-1:0]   o_read_data_m          // data read from memory (to be used in the WB stage)

);

            // data memory instance
            datamemory #(
                .P_ADDR_WIDTH(P_ADDR_WIDTH),
                .P_DATA_WIDTH(P_DATA_WIDTH)
            ) u_datamemory (
                .i_clk   (i_clk),
                .i_we    (i_mem_we_m),
                .i_addr  (i_alu_result_m[P_ADDR_WIDTH-1:0]),  
                .i_wdata (i_write_data_m),
                .o_rdata (o_read_data_m)
            );

        endmodule

