`ifndef RISCV_AND_TEST 
`define RISCV_AND_TEST

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_env_pkg::*;

class RISCV_and_test extends uvm_test;

  /*
   * UVM component registration
   */
  `uvm_component_utils(RISCV_and_test)

  RISCV_env env;
  RISCV_and_seq seq;

  /*
   * Constructor
   */
  function new(string name = "RISCV_and_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  /*
   * Build phase: create env and sequence
   */
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
    seq = RISCV_and_seq::type_id::create("seq");
  endfunction : build_phase

  /*
   * Run phase: run AND sequence
   */
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.RISCV_agnt.sequencer);
    phase.drop_objection(this);
    #100;
    $finish;
  endtask : run_phase

endclass : RISCV_and_test

`endif