`ifndef RISCV_XORI_TEST
`define RISCV_XORI_TEST

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_seq_list::*;

class RISCV_xori_test extends uvm_test;
  `uvm_component_utils(RISCV_xori_test)

  RISCV_env env;

  function new(string name = "RISCV_xori_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    begin 

      // Declara variável local
      RISCV_xori_seq xori_seq;

      // Cria a sequência
      xori_seq = RISCV_xori_seq::type_id::create("xori_seq");

      `uvm_info(get_name(), "Starting XORI sequence...", UVM_MEDIUM)

      // Executa a sequência
      xori_seq.start(env.RISCV_agnt.sequencer);

    end  
  endtask

endclass

`endif