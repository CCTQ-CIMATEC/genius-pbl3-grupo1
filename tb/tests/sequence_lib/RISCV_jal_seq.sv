`ifndef RISCV_JAL_SEQ
`define RISCV_JAL_SEQ

`include "uvm_macros.svh"
import uvm_pkg::*;
 
class RISCV_jal_seq extends uvm_sequence#(RISCV_transaction);
 
  `uvm_object_utils(RISCV_jal_seq)
 
  rand bit [20:0] imm;           // J-type immediate
  rand bit [4:0]  rd_addr;       // Destination register
 
  localparam bit [6:0] JAL_OPCODE = 7'b1101111;
 
  function new(string name = "RISCV_jal_seq");
    super.new(name);
  endfunction
 
  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
 
      req = RISCV_transaction::type_id::create("req");
      start_item(req);
 
      if (!randomize(imm, rd_addr)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Encode JAL instruction
      req.instr_data = {
        imm,
        rd_addr,         // bits 11–7
        JAL_OPCODE       // bits 6–0
      };

      // Format immediate as signed jump target (<< 1 for real offset)
      req.instr_name = $sformatf("JAL x%0d, %0d", 
                                 rd_addr, $signed(imm));

      `uvm_info(get_full_name(), $sformatf("Generated JAL instruction: %s", req.instr_name), UVM_LOW);
 
      finish_item(req);
    end
  endtask
 
endclass
 
`endif