`ifndef RISCV_ORI_SEQ
`define RISCV_ORI_SEQ

`include "uvm_macros.svh"
import uvm_pkg::*;
 
class RISCV_ori_seq extends uvm_sequence#(RISCV_transaction);
 
  `uvm_object_utils(RISCV_ori_seq)
 
  rand bit [11:0] imm;  
  rand bit [4:0]  rs1_addr;  
  rand bit [4:0]  rd_addr;  
 
  // Constantes fixas para ORI
  localparam bit [6:0] ORI_OPCODE = 7'b0010011; // Mesmo opcode de ADDI (I-type)
  localparam bit [2:0] ORI_FUNCT3 = 3'b110;     // Funct3 para ORI
 
  function new(string name = "RISCV_ori_seq");
    super.new(name);
  endfunction
 
  virtual task body();
   // Generate multiple ori transactions
    repeat(`NO_OF_TRANSACTIONS) begin
 
      req = RISCV_transaction::type_id::create("req");
      start_item(req);
 
      if (!randomize(imm, rs1_addr, rd_addr)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end
 
      // Monta a instrução tipo I (ORI)
      req.instr_data = {
       imm, rs1_addr, ORI_FUNCT3, rd_addr, ORI_OPCODE
      };
 
      req.instr_name = $sformatf("ORI x%0d, x%0d, %0d |", rd_addr, rs1_addr, $signed(imm));
 
      `uvm_info(get_full_name(), $sformatf("Generated ORI instruction: %s", req.instr_name), UVM_LOW);
 
      finish_item(req);
    end
  endtask
 
endclass
 
`endif