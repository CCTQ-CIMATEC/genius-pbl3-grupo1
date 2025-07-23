// RISCV_sltu_seq.sv
`ifndef RISCV_SLTU_SEQ
`define RISCV_SLTU_SEQ

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_env_pkg::*; 

class RISCV_sltu_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_sltu_seq)

  function new(string name = "RISCV_sltu_seq");
    super.new(name);
  endfunction

  rand bit [4:0] rs1;   
  rand bit [4:0] rs2;  
  rand bit [4:0] rd;   

  localparam bit [6:0] SLTU_OPCODE = 7'b0110011; 
  localparam bit [2:0] SLTU_FUNCT3 = 3'b011;   
  localparam bit [6:0] SLTU_FUNCT7 = 7'b0000000; 

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1, rs2, rd))
        `uvm_fatal(get_type_name(), "A randomização falhou para a sequência SLTU!");

      req.instr_ready = 1'b1;
      req.instr_data = {
        SLTU_FUNCT7,
        rs2,
        rs1,
        SLTU_FUNCT3,
        rd,
        SLTU_OPCODE
      };

      req.instr_name = $sformatf("SLTU x%0d, x%0d, x%0d", rd, rs1, rs2);

      `uvm_info(get_full_name(), $sformatf("Enviando instrução SLTU: %s", req.instr_name), UVM_LOW);
      req.print(); 

      finish_item(req);
    end
  endtask

endclass

`endif 
