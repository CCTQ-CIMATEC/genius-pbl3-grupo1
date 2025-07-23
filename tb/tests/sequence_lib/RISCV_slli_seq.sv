`ifndef RISCV_SLLI_SEQ
`define RISCV_SLLI_SEQ

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_env_pkg::*; 

class RISCV_slli_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_slli_seq)

  function new(string name = "RISCV_slli_seq");
    super.new(name);
  endfunction

  rand bit [4:0] rs1;   
  rand bit [4:0] rd;   
  rand bit [4:0] shamt; 

  localparam bit [6:0] SLLI_OPCODE = 7'b0110011; 
  localparam bit [2:0] SLLI_FUNCT3 = 3'b001;   
  localparam bit [6:0] SLLI_FUNCT7 = 7'b0000000; 
  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1, rd, shamt))
        `uvm_fatal(get_type_name(), "Randomization failed for SLLI sequence!");

      req.instr_ready = 1'b1;
      req.instr_data = {
        SLLI_FUNCT7, 
        shamt,       
        rs1,
        SLLI_FUNCT3,
        rd,
        SLLI_OPCODE
      };

      req.instr_name = $sformatf("SLLI x%0d, x%0d, %0d", rd, rs1, shamt);

      `uvm_info(get_full_name(), $sformatf("Sending SLLI instruction: %s", req.instr_name), UVM_LOW);
      req.print();

      finish_item(req);
    end
  endtask

endclass

`endif 
