`ifndef RISCV_LUI_TEST
`define RISCV_LUI_TEST

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_env_pkg::*;

class RISCV_lui_test extends uvm_test;
  `uvm_component_utils(RISCV_lui_test)
  
  RISCV_env env;
  RISCV_lui_seq lui_seq;

  function new(string name = "RISCV_lui_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
    lui_seq = RISCV_lui_seq::type_id::create("lui_seq");
    
    // Configuração de endereços
    uvm_config_db#(int)::set(this, "env.RISCV_agnt.driver", "min_addr", 32'h0000);
    uvm_config_db#(int)::set(this, "env.RISCV_agnt.driver", "max_addr", 32'hFFFF);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Starting LUI instruction test", UVM_LOW)
    
    lui_seq.start(env.RISCV_agnt.sequencer);
    
    #(`NO_OF_TRANSACTIONS * 20);
    phase.drop_objection(this);
    
    `uvm_info(get_type_name(), "LUI instruction test completed", UVM_LOW);
  endtask
endclass

`endif