`ifndef RISCV_SW_TEST 
`define RISCV_SW_TEST

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_env_pkg::*;

class RISCV_sw_test extends uvm_test;
 
  `uvm_component_utils(RISCV_sw_test)
 
  RISCV_env env;
  RISCV_sw_seq sw_seq;
 
  function new(string name = "RISCV_sw_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
 
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
    sw_seq = RISCV_sw_seq::type_id::create("sw_seq");
    
    // Configuração adicional para teste SW
    uvm_config_db#(int)::set(this, "env.RISCV_agnt.driver", "min_addr", 32'h1000);
    uvm_config_db#(int)::set(this, "env.RISCV_agnt.driver", "max_addr", 32'h1FFF);
  endfunction : build_phase
 
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    `uvm_info(get_type_name(), "Starting SW instruction test", UVM_LOW);
    sw_seq.start(env.RISCV_agnt.sequencer);
    
    // Aguarda tempo suficiente para todas as transações serem processadas
    #(`NO_OF_TRANSACTIONS * 20);
    
    phase.drop_objection(this);
    `uvm_info(get_type_name(), "SW instruction test completed", UVM_LOW);
  endtask : run_phase
 
endclass : RISCV_sw_test

`endif