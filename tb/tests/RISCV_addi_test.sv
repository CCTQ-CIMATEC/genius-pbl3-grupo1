`ifndef RISCV_ADDI_TEST 
`define RISCV_ADDI_TEST

class RISCV_addi_test extends uvm_test;
 
  `uvm_component_utils(RISCV_addi_test)
 
  RISCV_env env;
  RISCV_addi_seq    seq;
 
  function new(string name = "RISCV_addi_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
    seq = RISCV_addi_seq::type_id::create("seq");
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.RISCV_agnt.sequencer);
    phase.drop_objection(this);
  endtask : run_phase
 
endclass : RISCV_addi_test

`endif