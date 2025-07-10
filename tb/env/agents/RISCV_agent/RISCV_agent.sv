`ifndef RISCV_AGENT
`define RISCV_AGENT

class RISCV_agent extends uvm_agent;

    RISCV_driver    driver;
    RISCV_sequencer sequencer;
    RISCV_monitor   monitor;

    `uvm_component_utils(RISCV_agent)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

     function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver = RISCV_driver::type_id::create("driver", this);
    sequencer = RISCV_sequencer::type_id::create("sequencer", this);
    monitor = RISCV_monitor::type_id::create("monitor", this);
  endfunction : build_phase

  /*
   * Connect phase: connect TLM ports and exports (e.g., analysis port/exports)
   */
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction : connect_phase
 
endclass : RISCV_agent

`endif
