`ifndef RISCV_SH_TEST
`define RISCV_SH_TEST

import uvm_pkg::*;
`include "uvm_macros.svh"
import RISCV_env_pkg::*;

class RISCV_sh_test extends uvm_test;
  `uvm_component_utils(RISCV_sh_test)
  
  RISCV_env env;
  RISCV_sh_seq sh_seq;  // Usando a sequência específica para SH

  function new(string name = "RISCV_sh_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_env::type_id::create("env", this);
    sh_seq = RISCV_sh_seq::type_id::create("sh_seq");  // Criando a sequência específica
    
    // Configuração de endereços similar ao SW test
    uvm_config_db#(int)::set(this, "env.RISCV_agnt.driver", "min_addr", 32'h1000);
    uvm_config_db#(int)::set(this, "env.RISCV_agnt.driver", "max_addr", 32'h1FFF);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Starting SH instruction test", UVM_LOW)
    
    sh_seq.start(env.RISCV_agnt.sequencer);
    
    // Tempo de espera ajustado conforme SW test
    #(`NO_OF_TRANSACTIONS * 20);
    phase.drop_objection(this);
    
    `uvm_info(get_type_name(), "SH instruction test completed", UVM_LOW);
  endtask
endclass

`endif