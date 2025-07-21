// mem_sequencer.sv
// UVM sequencer class for memory transactions


`ifndef RISCV_SEQUENCE_SV
`define RISCV_SEQUENCE_SV

//`include "uvm_macros.svh"
// import uvm_pkg::*;
`include "../RISCV_agent/RISCV_transaction.sv"

class RISCV_sequencer extends uvm_sequencer #(RISCV_transaction);
  `uvm_component_utils(RISCV_sequencer)  // UVM factory registration
  
  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass


`endif  //