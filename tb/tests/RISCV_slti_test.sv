// RISCV_slti_test.sv
`ifndef RISCV_SLTI_TEST
`define RISCV_SLTI_TEST

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_env_pkg::*; 

class RISCV_slti_test extends uvm_test;

  `uvm_component_utils(RISCV_slti_test) 

  RISCV_env env;
  RISCV_slti_seq seq;

  function new(string name = "RISCV_slti_test", uvm_component parent = null); // constructor
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase(uvm_phase phase); // build
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
    seq = RISCV_slti_seq::type_id::create("seq"); 
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.RISCV_agnt.sequencer); 
    phase.drop_objection(this);
    #100; 
    $finish;
  endtask : run_phase

endclass : RISCV_slti_test

`endif
