//------------------------------------------------------------------------------
// RISCV_environment.sv
//------------------------------------------------------------------------------
// This uvm environment module serves as the top-level container for all
// verification intellectual property (vip) components related to the risc-v dut.
// it is responsible for instantiating these components (agent, reference model,
// scoreboard, and functional coverage) and establishing their tlm connections,
// creating a complete verification environment.
//
// author: Glenda Barbosa do Nascimento
// date  : ?????
//------------------------------------------------------------------------------

`ifndef RISCV_ENV
`define RISCV_ENV

import uvm_pkg::*;

// import necessary packages for all verification components.
// these imports ensure that the classes declared in these packages are
// visible and can be instantiated within this environment.
import RISCV_agent_pkg::*;      // includes RISCV_agent, RISCV_transaction, etc.
import RISCV_ref_model_pkg::*;  // includes RISCV_ref_model and its package
//import RISCV_scoreboard_pkg::*; // includes RISCV_scoreboard and its package
//import RISCV_coverage_pkg::*;   // includes RISCV_coverage and its package


class RISCV_env extends uvm_env;

    // component declarations: declare handles for all components that will be part of this environment.
    RISCV_agent     riscv_agent_instance;
    RISCV_ref_model riscv_reference_model;
    // note: RISCV_coverage is typically parameterized by the transaction type it covers.
    RISCV_coverage#(RISCV_transaction) functional_coverage;
    RISCV_scoreboard scoreboard_instance;


    // register the environment class with the uvm factory.
    // this is crucial for uvm's factory mechanism, allowing dynamic creation
    // and type overriding of components during the simulation.
    `uvm_component_utils(RISCV_env)

    // constructor: standard uvm component constructor.
    // it performs basic initialization and calls the base class constructor.
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // build phase: called after the constructor.
    // this is the primary phase for instantiating all child components
    // of the environment. components are created using the uvm factory.
    function void build_phase(uvm_phase phase);
        super.build_phase(phase); // calls the base class build_phase

        // create instances of all verification components using the uvm factory.
        // the string argument is the instance name (get_name()), and 'this' sets the parent.
        riscv_agent_instance    = RISCV_agent::type_id::create("riscv_agent_instance", this);
        riscv_reference_model   = RISCV_ref_model::type_id::create("riscv_reference_model", this);
        functional_coverage     = RISCV_coverage#(RISCV_transaction)::type_id::create("functional_coverage", this);
        scoreboard_instance     = RISCV_scoreboard::type_id::create("scoreboard_instance", this);
    endfunction : build_phase

    // connect phase: called after the build phase.
    // this phase is used to establish all tlm (transaction level modeling)
    // connections between the instantiated components.
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase); // calls the base class connect_phase

        // connect monitor's analysis port to scoreboard and reference model's input.
        // the monitor collects data from the dut and broadcasts it.
        // 'riscv_agent_instance.monitor.mon_ap' is the analysis_port in the monitor.
        riscv_agent_instance.monitor.mon2sb_port.connect(scoreboard_instance.monitor_data_in_export);
        riscv_agent_instance.monitor.mon2sb_port.connect(riscv_reference_model.rm_export);

        // connect reference model's output analysis port to scoreboard and coverage.
        // the reference model provides the expected behavior.
        // 'riscv_reference_model.ref_model_ap' is the analysis_port in the ref_model.
        riscv_reference_model.ref_model_ap.connect(scoreboard_instance.reference_data_in_export);
        riscv_reference_model.ref_model_ap.connect(functional_coverage.analysis_export);

        // original connect from your colleague's code - please confirm if this connection is still needed:
        // riscv_agent_instance.driver.drv2rm_port.connect(riscv_reference_model.rm_export);
        // this connection might be redundant if the monitor is already feeding the ref model.
        // it implies the driver is also directly sending transactions to the ref model.
        // confirm with your team whether the driver needs to communicate directly with the ref model,
        // or if all data flow should go through the monitor.
    endfunction : connect_phase

endclass : RISCV_env
// end of class RISCV_environment

`endif // RISCV_ENV