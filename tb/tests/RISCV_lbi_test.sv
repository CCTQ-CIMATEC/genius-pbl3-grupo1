`ifndef RISCV_LBI_TEST
`define RISCV_LBI_TEST

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_seq_list::*;

class RISCV_lbi_test extends uvm_test;
  `uvm_component_utils(RISCV_lbi_test)

  RISCV_env env;

  function new(string name = "RISCV_lbi_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    RISCV_lbi_seq lbi_seq;
    lbi_seq = RISCV_lbi_seq::type_id::create("lbi_seq");

    `uvm_info(get_name(), "Starting LBI test sequence...", UVM_MEDIUM)
    lbi_seq.start(env.RISCV_agent.sequencer);
  endtask

endclass: RISCV_lbi_test

`endif
