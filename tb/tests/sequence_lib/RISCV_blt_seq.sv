`ifndef RISCV_BLT_SEQ
`define RISCV_BLT_SEQ

`include "uvm_macros.svh"
import uvm_pkg::*;
 
class RISCV_blt_seq extends uvm_sequence#(RISCV_transaction);
 
  `uvm_object_utils(RISCV_blt_seq)
 
  rand bit [12:0] imm;  
  rand bit [4:0]  rs1_addr;  
  rand bit [4:0]  rs2_addr;  
 
  localparam bit [6:0] BLT_OPCODE = 7'b1100011;
  localparam bit [2:0] BLT_FUNCT3 = 3'b100;
 
  function new(string name = "RISCV_blt_seq");
    super.new(name);
  endfunction
 
  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
 
      req = RISCV_transaction::type_id::create("req");
      start_item(req);
 
      if (!randomize(imm, rs1_addr, rs2_addr)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end
 
      req.instr_data = {
        imm[12],         // bit 31
        imm[10:5],       // bits 30–25
        rs2_addr,        // bits 24–20
        rs1_addr,        // bits 19–15
        BLT_FUNCT3,      // bits 14–12
        imm[4:1],        // bits 11–8
        imm[11],         // bit 7
        BLT_OPCODE       // bits 6–0
      };

      req.instr_name = $sformatf("BLT x%0d, x%0d, %0d", 
                                 rs1_addr, rs2_addr, $signed({imm[12], imm[11], imm[10:5], imm[4:1], 1'b0}));

      `uvm_info(get_full_name(), $sformatf("Generated BLT instruction: %s", req.instr_name), UVM_LOW);
 
      finish_item(req);
    end
  endtask
 
endclass
 
`endif
