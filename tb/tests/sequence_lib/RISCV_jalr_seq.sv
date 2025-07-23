`ifndef RISCV_JALR_SEQ
`define RISCV_JALR_SEQ

`include "uvm_macros.svh"
import uvm_pkg::*;
 
class RISCV_jalr_seq extends uvm_sequence#(RISCV_transaction);
 
  `uvm_object_utils(RISCV_jalr_seq)
 
  // Campos que serão randomizados
  rand bit [31:0] rs1_value; 
  rand bit [31:0] pc_value;   // Current PC for JALR calculation
  bit [31:0]      rd_value;   // Output of the instruction (pc + 4)
 
  logic [31:0]  regfile[32];
 
  rand bit [11:0] imm;  
  rand bit [4:0]  rs1_addr;  
  rand bit [4:0]  rd_addr;  
 
  // Constantes fixas para JALR
  localparam bit [6:0] JALR_OPCODE = 7'b1100111;
  localparam bit [2:0] JALR_FUNCT3 = 3'b000;
 
  function new(string name = "RISCV_jalr_seq");
    super.new(name);
  endfunction
 
  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
 
      req = RISCV_transaction::type_id::create("req");
      start_item(req);
 
      if (!randomize(imm, rs1_addr, rd_addr, rs1_value, pc_value)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end
 
      // Construct JALR instruction
      req.instr_data = {
        imm, rs1_addr, JALR_FUNCT3, rd_addr, JALR_OPCODE
      };
 
      req.instr_name = $sformatf("JALR x%0d, %0d(x%0d) |", 
                                rd_addr, $signed(imm), rs1_addr);
 
      `uvm_info(get_full_name(), $sformatf("Generated JALR instruction: %s", req.instr_name), UVM_LOW);
 
      finish_item(req);
    end
  endtask
 
endclass
 
`endif