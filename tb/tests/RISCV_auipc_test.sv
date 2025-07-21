`ifndef RISCV_AUIPC_TEST
`define RISCV_AUIPC_TEST

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_env_pkg::*;

class RISCV_auipc_test extends uvm_test;
  `uvm_component_utils(RISCV_auipc_test)
  
  RISCV_env env;
  RISCV_auipc_seq auipc_seq;

  function new(string name = "RISCV_auipc_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
    auipc_seq = RISCV_auipc_seq::type_id::create("auipc_seq");
    
    // Configuração de endereços
    uvm_config_db#(int)::set(this, "env.RISCV_agnt.driver", "min_addr", 32'h0000);
    uvm_config_db#(int)::set(this, "env.RISCV_agnt.driver", "max_addr", 32'hFFFF);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Starting AUIPC instruction test", UVM_LOW)
    
    auipc_seq.start(env.RISCV_agnt.sequencer);
    
    #(`NO_OF_TRANSACTIONS * 20);
    phase.drop_objection(this);
    
    `uvm_info(get_type_name(), "AUIPC instruction test completed", UVM_LOW);
  endtask
endclass

`endif