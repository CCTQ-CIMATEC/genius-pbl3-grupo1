/*-----------------------------------------------------------------------------
    PBL3 - RISC-V PIPELINE Processor
    Package file

    File name: cpu_pkg.sv
    Usage: rtl/execute/alu.sv

    Objective:
        Implement 
-----------------------------------------------------------------------------*/

package cpu_pkg;

    typedef enum logic [3:0] {
        ALU_ADD     = 4'b0000, 
        ALU_SLL     = 4'b0001,
        ALU_LT      = 4'b0010,
        ALU_LTU     = 4'b0011,
        ALU_XOR     = 4'b0100, 
        ALU_SRL     = 4'b0101,
        ALU_OR      = 4'b0110,
        ALU_AND     = 4'b0111, 
        ALU_SUB     = 4'b1000, 
        ALU_SRA     = 4'b1001,
        ALU_BPS2    = 4'b1010, 
        ALU_EQUAL   = 4'b1011, 
        ALU_NEQUAL  = 4'b1100, 
        ALU_GT      = 4'b1101, 
        ALU_UNUSED  = 4'b1110, 
        ALU_GTU     = 4'b1111  
    } alu_op_t;

endpackage
