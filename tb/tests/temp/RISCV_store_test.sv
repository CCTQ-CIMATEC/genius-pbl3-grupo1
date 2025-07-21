

`ifndef RISCV_STORE_TEST 
`define RISCV_STORE_TEST

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_env_pkg::*;

class RISCV_store_test extends uvm_test;
 
  /*
   * Declare component utilities for the test-case
   */
  `uvm_component_utils(RISCV_store_test)
 
  RISCV_env env;
  RISCV_store_seq   seq;
 
  /*
   * Constructor: new
   * Initializes the test with a given name and parent component.
   */
  function new(string name = "RISCV_store_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
 
  /*
   * Build phase: Instantiate environment and sequence
   * This phase constructs the environment and sequence components.
   */
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
    seq = RISCV_store_seq::type_id::create("seq");
  endfunction : build_phase
 
  
  // Adicione no build_phase:
    function void build_phase(uvm_phase phase);
      if(!uvm_config_db#(bit[2:0])::get(this, "", "funct3", funct3))
        funct3 = 3'b010; // Default SW
    endfunction
  endclass


  /*
   * Run phase: Start the sequence on the agent’s sequencer
   * This phase starts the sequence, which generates and sends transactions to the DUT.
   */
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.RISCV_agnt.sequencer);
    phase.drop_objection(this);
   #100;
  $finish;
  endtask : run_phase
 
endclass : RISCV_store_test

`endif












