

`ifndef RISCV_ENV
`define RISCV_ENV

import uvm_pkg::*;
class RISCV_agent extends uvm_agent;

  RISCV_driver     driver;
  RISCV_monitor    monitor;
  RISCV_sequencer  sequencer;

  `uvm_component_utils(RISCV_agent)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    monitor = RISCV_monitor::type_id::create("monitor", this);

    if (is_active == UVM_ACTIVE) begin
      driver    = RISCV_driver::type_id::create("driver", this);
      sequencer = RISCV_sequencer::type_id::create("sequencer", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction

endclass

`endif // RISCV_ENV
