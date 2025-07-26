`ifndef RISCV_LH_TEST 
`define RISCV_LH_TEST

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_env_pkg::*;

class RISCV_lh_test extends uvm_test;

  `uvm_component_utils(RISCV_lh_test)

  RISCV_env env;
  RISCV_lh_seq seq;


  function new(string name = "RISCV_lh_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
    seq = RISCV_lh_seq::type_id::create("seq");
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.RISCV_agnt.sequencer);
    phase.drop_objection(this);
    #100;
    $finish;
  endtask : run_phase

endclass : RISCV_lh_test

`endif