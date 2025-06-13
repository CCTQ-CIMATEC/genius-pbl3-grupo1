//------------------------------------------------------------------------------
// Package for risc-v environment classes
//------------------------------------------------------------------------------
// This package acts as a central hub, providing a convenient way to compile
// and access all top-level environment classes and their related components.
// it ensures proper compilation order and easy access to verification ip.
//
// author: Glenda Barbosa do Nascimento
// date  : ??????
//------------------------------------------------------------------------------

`ifndef RISCV_ENV_PKG
`define RISCV_ENV_PKG

package RISCV_env_pkg;

    // import the base uvm package.
    import uvm_pkg::*;
    // include uvm macros???????
    //`include "uvm_macros.svh"

    /*
     * importing essential packages for various verification components.
     * these imports make all the classes defined within these packages
     * visible and usable within the RISCV_env_pkg and any module/class
     * that imports RISCV_env_pkg. ensure these packages are compiled
     * before this environment package.
     */
    import RISCV_agent_pkg::*;      // contains RISCV_agent and RISCV_transaction
    import RISCV_ref_model_pkg::*;  // contains RISCV_ref_model
    import RISCV_scoreboard_pkg::*; // assuming this package exists and contains RISCV_scoreboard
    import RISCV_coverage_pkg::*;   // assuming this package exists and contains RISCV_coverage

    /*
     * include top environment files.
     * these files contain the class definitions for the environment's main components.
     * they must be included in a logical order to resolve dependencies.
     * ensure these files are properly located relative to this package,
     * or use full paths if necessary during compilation.
     */
    `include "RISCV_coverage.sv"   // class RISCV_coverage
    `include "RISCV_scoreboard.sv" // class RISCV_scoreboard
    `include "RISCV_environment.sv"// class RISCV_environment

endpackage

`endif // RISCV_ENV_PKG