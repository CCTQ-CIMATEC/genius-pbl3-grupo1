`ifndef RISCV_SB_TEST
`define RISCV_SB_TEST

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_env_pkg::*;

class RISCV_sb_test extends uvm_test;
  `uvm_component_utils(RISCV_sb_test)
  
  RISCV_env env;
  RISCV_sb_seq sb_seq;  // Using the specific SB sequence

  function new(string name = "RISCV_sb_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
    sb_seq = RISCV_sb_seq::type_id::create("sb_seq");  // Create specific SB sequence
    
    // Address range configuration matching SW test
    uvm_config_db#(int)::set(this, "env.RISCV_agnt.driver", "min_addr", 32'h1000);
    uvm_config_db#(int)::set(this, "env.RISCV_agnt.driver", "max_addr", 32'h1FFF);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Starting SB instruction test", UVM_LOW)
    
    sb_seq.start(env.RISCV_agnt.sequencer);
    
    // Wait time calculation matching SW test
    #(`NO_OF_TRANSACTIONS * 20);
    phase.drop_objection(this);
    
    `uvm_info(get_type_name(), "SB instruction test completed", UVM_LOW);
  endtask
endclass

`endif