//------------------------------------------------------------------------------
// RISCV_scoreboard.sv
//------------------------------------------------------------------------------
// This UVM scoreboard is responsible for verifying the functional correctness
// of the RISC-V DUT by comparing its actual outputs (from the monitor)
// against the expected behavior (from the reference model).
//
// Author: Glenda Barbosa do Nascimento
// Date  : ????
//------------------------------------------------------------------------------

`ifndef RISCV_SCOREBOARD
`define RISCV_SCOREBOARD

// import necessary uvm packages and transaction types
// this makes uvm classes and your custom transaction visible
import uvm_pkg::*;
import RISCV_agent_pkg::*;     // assuming RISCV_transaction is defined within this package
import RISCV_ref_model_pkg::*; // assuming this package exists for types related to the reference model

class RISCV_scoreboard extends uvm_scoreboard;

    // component registration with the uvm factory
    // this macro allows the uvm factory to create instances of this scoreboard
    // and enables features like type overriding for flexible testing.
    `uvm_component_utils(RISCV_scoreboard)

    // analysis exports - these are the ports through which the scoreboard
    // will receive transactions from other components (monitor and reference model).
    // they act as entry points for data flow into the scoreboard.
    uvm_analysis_export#(RISCV_transaction) monitor_data_in_export;   // receives actual transactions from the monitor
    uvm_analysis_export#(RISCV_transaction) reference_data_in_export; // receives expected transactions from the reference model

    // uvm_tlm_analysis_fifos - these act as buffers to temporarily store
    // the transactions received via the analysis exports. they ensure that
    // the scoreboard can process transactions asynchronously as they arrive.
    uvm_tlm_analysis_fifo#(RISCV_transaction) monitor_fifo;   // fifo for actual data from the monitor
    uvm_tlm_analysis_fifo#(RISCV_transaction) reference_fifo; // fifo for expected data from the reference model

    // variables to hold the current transactions being compared
    // these will store the transactions popped from the fifos for processing.
    RISCV_transaction current_actual_trans;
    RISCV_transaction current_expected_trans;

    // a simple counter to track the number of mismatches found during comparison.
    // while uvm also tracks errors via its report server, a local counter can be useful.
    int mismatch_count = 0;

    // constructor: standard uvm component constructor.
    // it's called when an instance of the scoreboard is created.
    function new(string name, uvm_component parent);
        super.new(name, parent); // calls the base class (uvm_scoreboard) constructor
    endfunction

    // build phase: called after construction.
    function void build_phase(uvm_phase phase);
        super.build_phase(phase); // calls the base class build_phase

        // create instances of the fifos
        monitor_fifo   = new("monitor_fifo", this);
        reference_fifo = new("reference_fifo", this);

        // create instances of the analysis exports
        monitor_data_in_export   = new("monitor_data_in_export", this);
        reference_data_in_export = new("reference_data_in_export", this);
    endfunction

    // connect phase: called after the build phase.
    // in this phase, we connect the analysis exports to the analysis_export ports of the fifos.
    // this establishes the data paths for transactions to flow into the fifos.
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase); // calls the base class connect_phase

        // connect the scoreboard's exports to the fifos' analysis_export ports.
        // this is how transactions written to the exports (from monitor/ref_model)
        // end up in these fifos.
        monitor_data_in_export.connect(monitor_fifo.analysis_export);
        reference_data_in_export.connect(reference_fifo.analysis_export);
    endfunction

    // run phase: this is where the main activity of the scoreboard occurs.
    // it runs concurrently with the simulation.
    virtual task run_phase(uvm_phase phase);
        // the forever loop ensures the scoreboard continuously monitors and compares transactions.
        forever begin
            // retrieve an actual transaction from the monitor's fifo.
            // the 'get' method blocks until a transaction is available in the fifo.
            monitor_fifo.get(current_actual_trans);
            // important: check for null to handle potential issues if the fifo is not properly managed.
            if (current_actual_trans == null) begin
                `uvm_fatal(get_full_name(), "received null transaction from monitor fifo. simulation might be stopping unexpectedly.")
            end

            // retrieve an expected transaction from the reference model's fifo.
            // this also blocks until a transaction is available.
            reference_fifo.get(current_expected_trans);
            // similar null check for the expected transaction.
            if (current_expected_trans == null) begin
                `uvm_fatal(get_full_name(), "received null transaction from reference fifo. simulation might be stopping unexpectedly.")
            end

            // call the dedicated task to perform the comparison between the actual and expected transactions.
            perform_transaction_comparison(current_actual_trans, current_expected_trans);
        end
    endtask

    // perform_transaction_comparison task: handles the actual comparison logic.
    // this task takes both the actual (from dut) and expected (from ref model) transactions
    // and checks if their fields match according to the verification criteria.
    task perform_transaction_comparison(RISCV_transaction actual_tr, RISCV_transaction expected_tr);
        string comparison_details; // a variable for building detailed comparison messages (not fully used in this snippet)
        bit current_match = 1;     // flag to track if the current pair of transactions matches

        // log information about the transactions being compared.
        // this is very useful for debugging, especially when mismatches occur.
        `uvm_info(get_full_name(), $sformatf("--- comparing transactions ---\nactual:\n%s\nexpected:\n%s", actual_tr.sprint(), expected_tr.sprint()), UVM_HIGH)

        // comparison of risc-v instruction/memory data fields.
        if (actual_tr.instr_data !== expected_tr.instr_data) begin
            // if a mismatch is found, log an uvm_error. uvm will automatically count these errors.
            `uvm_error(get_full_name(), $sformatf("instr_data mismatch! expected: 0x%08x, actual: 0x%08x", expected_tr.instr_data, actual_tr.instr_data));
            current_match = 0; // set mismatch flag for this transaction pair
        end
        if (actual_tr.data_mem_address !== expected_tr.data_mem_address) begin
            `uvm_error(get_full_name(), $sformatf("data_addr mismatch! expected: 0x%08x, actual: 0x%08x", expected_tr.data_mem_address, actual_tr.data_mem_address));
            current_match = 0;
        end
        if (actual_tr.data_mem_write_data !== expected_tr.data_mem_write_data) begin
            `uvm_error(get_full_name(), $sformatf("data_write mismatch! expected: 0x%08x, actual: 0x%08x", expected_tr.data_mem_write_data, actual_tr.data_mem_write_data));
            current_match = 0;
        end
        if (actual_tr.data_mem_write_enable !== expected_tr.data_mem_write_enable) begin
            `uvm_error(get_full_name(), $sformatf("data_write_enable mismatch! expected: %0b, actual: %0b", expected_tr.data_mem_write_enable, actual_tr.data_mem_write_enable));
            current_match = 0;
        end

        // --- specific comparison logic for the game outputs ---
        // these checks verify if the dut's simon game outputs (leds, buzzer)
        // match the expected outputs from the reference model.
        // 'event_type' field helps to identify if the transaction represents a simon led change.
        if (actual_tr.event_type == "SIMON_LED_CHANGE" && expected_tr.event_type == "SIMON_LED_CHANGE") begin
            if (actual_tr.simon_led_state_actual !== expected_tr.simon_led_state_expected) begin
                `uvm_error(get_full_name(), $sformatf("simon_led_state mismatch! expected: %0h, actual: %0h",
                                                      expected_tr.simon_led_state_expected, actual_tr.simon_led_state_actual));
                current_match = 0;
            end else begin
                `uvm_info(get_full_name(), $sformatf("simon_led_state match: %0h", actual_tr.simon_led_state_actual), UVM_LOW);
            end
        end

        // similar check for the simon game's buzzer state.
        if (actual_tr.event_type == "SIMON_BUZZER_CHANGE" && expected_tr.event_type == "SIMON_BUZZER_CHANGE") begin
            if (actual_tr.simon_buzzer_state_actual !== expected_tr.simon_buzzer_state_expected) begin
                `uvm_error(get_full_name(), $sformatf("simon_buzzer_state mismatch! expected: %0b, actual: %0b",
                                                      expected_tr.simon_buzzer_state_expected, actual_tr.simon_buzzer_state_actual));
                current_match = 0;
            end else begin
                `uvm_info(get_full_name(), $sformatf("simon_buzzer_state match: %0b", actual_tr.simon_buzzer_state_actual), UVM_LOW);
            end
        end
        // end of game specific comparison ---

        // if any mismatch was found for this transaction pair, increment the total mismatch count.
        if (!current_match) begin
            mismatch_count++;
            `uvm_error(get_full_name(), "transaction comparison failed for this pair of transactions.");
        end else begin
            // if no mismatches, log a success message for this pair.
            `uvm_info(get_full_name(), "transaction comparison passed for this pair of transactions.", UVM_LOW);
        end
    endtask

    // report phase: executed at the end of the simulation.
    // this phase provides a summary of the verification results.
    function void report_phase(uvm_phase phase);
        // retrieve the total number of errors reported by the uvm report server.
        // this is a global count of all uvm_error and uvm_fatal messages.
        int total_errors = uvm_report_server::get_server().get_severity_count(UVM_ERROR);

        // check if any errors were found (either globally or by our local counter).
        if (total_errors == 0 && mismatch_count == 0) begin
            // display a success message in green.
            $write("%c[7;32m",27); // ansi escape code for green background
            $display("-------------------------------------------------");
            $display("------ info : test case passed successfully -----");
            $display("-------------------------------------------------");
            $write("%c[0m",27);    // reset text color
        end else begin
            // display a failure message in red, including the total mismatches.
            $write("%c[7;31m",27); // ansi escape code for red background
            $display("---------------------------------------------------");
            $display("------ error : test case failed ------------------");
            $display($sformatf("------ total mismatches detected: %0d -------", mismatch_count));
            $display("---------------------------------------------------");
            $write("%c[0m",27);    // reset text color
        end
    endfunction

endclass

`endif // RISCV_SCOREBOARD