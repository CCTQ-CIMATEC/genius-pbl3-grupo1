// RISCV_sltiu_seq.sv
`ifndef RISCV_SLTIU_SEQ
`define RISCV_SLTIU_SEQ

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_env_pkg::*; 

class RISCV_sltiu_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_sltiu_seq)

  function new(string name = "RISCV_sltiu_seq");
    super.new(name);
  endfunction

  rand bit [4:0] rs1;   
  rand bit [4:0] rd;    
  rand bit [11:0] imm;  

  localparam bit [6:0] SLTIU_OPCODE = 7'b0010011; 
  localparam bit [2:0] SLTIU_FUNCT3 = 3'b011;    

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1, rd, imm))
        `uvm_fatal(get_type_name(), "A randomização falhou para a sequência SLTIU!");

      req.instr_ready = 1'b1;
      req.instr_data = {
        imm,         
        rs1,
        SLTIU_FUNCT3,
        rd,
        SLTIU_OPCODE
      };

      req.instr_name = $sformatf("SLTIU x%0d, x%0d, %0d", rd, rs1, imm);

      `uvm_info(get_full_name(), $sformatf("Enviando instrução SLTIU: %s", req.instr_name), UVM_LOW);
      req.print(); 

      finish_item(req);
    end
  endtask

endclass

`endif // RISCV_SLTIU_SEQ
