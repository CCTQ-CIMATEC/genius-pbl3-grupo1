`ifndef RISCV_ANDI_TEST
`define RISCV_ANDI_TEST

class RISCV_andi_test extends uvm_test;

  `uvm_component_utils(RISCV_andi_test)

  RISCV_env env;
  RISCV_andi_seq    seq;

  function new(string name = "RISCV_andi_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
    seq = RISCV_andi_seq::type_id::create("seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.RISCV_agnt.sequencer);
    phase.drop_objection(this);
  endtask

endclass

`endif
