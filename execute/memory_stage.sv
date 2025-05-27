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

module memory (
    input  logic        i_memwrite,       // Memory write enable
    input  logic [31:0] i_result_m,       // ALU result (memory address)
    input  logic [31:0] i_rs2_data_m,     // Data to write to memory
    input  logic        i_resultsrc_m,    // Select signal for result source
    input  logic [31:0] i_pc4_m,          // PC + 4
    output logic [31:0] o_read_data_w,    // Data read from memory
    output logic [31:0] o_result_w        // Final result for write-back
);
    // Data memory: 256 words of 32-bit
    logic [31:0] data_mem [0:255];

    // Write to memory
    always_ff @(posedge i_memwrite) begin
        data_mem[i_result_m[7:0]] <= i_rs2_data_m;
    end

    // Read from memory
    assign o_read_data_w = data_mem[i_result_m[7:0]];

    // Select between memory data and PC+4
    assign o_result_w = i_resultsrc_m ? o_read_data_w : i_pc4_m;

endmodule
