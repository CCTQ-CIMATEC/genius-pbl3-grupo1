//------------------------------------------------------------------------------

// Engineer: Ramylla Luiza Barbalho

//------------------------------------------------------------------------------
`ifndef RISCV_AGENT_PKG
`define RISCV_AGENT_PKG

package RISCV_agent_pkg;

    import uvm_pkg::*;

    `include "uvm_macros.svh"

    `include "RISCV_transaction.sv"
    // 2. Sequencer:
    `include "RISCV_sequencer.sv"
    // 3. Monitor e Driver:
    `include "RISCV_monitor.sv"
    `include "RISCV_driver.sv"
    // 4. Agente:
    `include "RISCV_agent.sv"

endpackage : RISCV_agent_pkg

`endif 