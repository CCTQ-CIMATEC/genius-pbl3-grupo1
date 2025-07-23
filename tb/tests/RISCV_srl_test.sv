//------------------------------------------------------------------------------
// Author: Ramylla Bezerra
// Date  : Jul 2025
//---------------------

`ifndef RISCV_SRL_TEST
`define RISCV_SRL_TEST

class RISCV_srl_test extends uvm_test;
  
  `uvm_component_utils(RISCV_srl_test)
  
  RISCV_env env;
  RISCV_srl_seq seq; 
  
  function new(string name = "RISCV_srl_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
    seq = RISCV_srl_seq::type_id::create("seq"); 
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.RISCV_agnt.sequencer); 
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : RISCV_srl_test

`endif 