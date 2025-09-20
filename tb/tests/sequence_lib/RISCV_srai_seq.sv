// RISCV_srai_seq.sv
`ifndef RISCV_SRAI_SEQ
`define RISCV_SRAI_SEQ

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_env_pkg::*; 
class RISCV_srai_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_srai_seq)

  function new(string name = "RISCV_srai_seq");
    super.new(name);
  endfunction

  rand bit [4:0] rs1; 
  rand bit [4:0] rd;    
  rand bit [4:0] shamt; 


  localparam bit [6:0] SRAI_OPCODE = 7'b0010011; 
  localparam bit [2:0] SRAI_FUNCT3 = 3'b101;    
  localparam bit [6:0] SRAI_FUNCT7 = 7'b0100000; 

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);


      if (!randomize(rs1, rd, shamt))
        `uvm_fatal(get_type_name(), "A randomização falhou para a sequência SRAI!");

      
      req.instr_ready = 1'b1;
      req.instr_data = {
        SRAI_FUNCT7, 
        shamt,       
        rs1,
        SRAI_FUNCT3,
        rd,
        SRAI_OPCODE
      };

      req.instr_name = $sformatf("SRAI x%0d, x%0d, %0d", rd, rs1, shamt);

      `uvm_info(get_full_name(), $sformatf("Enviando instrução SRAI: %s", req.instr_name), UVM_LOW);
      req.print(); 

      finish_item(req);
    end
  endtask

endclass

`endif 
