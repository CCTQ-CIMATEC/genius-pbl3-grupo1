//------------------------------------------------------------------------------
// UVM agent for adder transactions
//------------------------------------------------------------------------------
// This agent handles the driver, monitor, and sequencer for adder transactions.
//
// Author: Ramylla Luiza Barbalho
// Date  : JUN 2025
//------------------------------------------------------------------------------

`ifndef RISCV_MONITOR

class RISCV_agent extends uvm_agent;



    RISCV_monitor   monitor;

    

    RISCV_driver    driver;

    RISCV_sequencer sequencer;



    // --- Configuração e Registro ---

    `uvm_component_utils(RISCV_agent)



    // --- Construtor Padrão ---

    function new (string name, uvm_component parent);

        super.new(name, parent);

    endfunction : new



    // --- Build Phase ---

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        

        monitor = RISCV_monitor::type_id::create("monitor", this);



        if (is_active == UVM_ACTIVE) begin

            driver    = RISCV_driver::type_id::create("driver", this);

            sequencer = RISCV_sequencer::type_id::create("sequencer", this);

        end

    endfunction : build_phase



    // --- Connect Phase ---

    function void connect_phase(uvm_phase phase);

        if (is_active == UVM_ACTIVE) begin

            // A conexão só é feita se o agente for ATIVO.

            driver.seq_item_port.connect(sequencer.seq_item_export);

        end

    endfunction : connect_phase



endclass : RISCV_agent