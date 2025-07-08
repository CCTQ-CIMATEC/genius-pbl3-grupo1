
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
    //import RISCV_scoreboard_pkg::*; 
   // import RISCV_coverage_pkg::*;   

    /*
     * include top environment files.
     * these files contain the class definitions for the environment's main components.
     * they must be included in a logical order to resolve dependencies.
     * ensure these files are properly located relative to this package,
     * or use full paths if necessary during compilation.
     */
    `include "RISCV_coverage.sv"   // class RISCV_coverage
    `include "RISCV_scoreboard.sv" // class RISCV_scoreboard
    `include "RISCV_env.sv"// class RISCV_environment

endpackage

`endif // RISCV_ENV_PKG
