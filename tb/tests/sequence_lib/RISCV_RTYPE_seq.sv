
`ifndef RISCV_RTYPE_SEQ 
`define RISCV_RTYPE_SEQ

class RISCV_rtype_seq extends uvm_sequence#(RISCV_transaction);
   
  `uvm_object_utils(RISCV_rtype_seq)

    function new(string name = "RISCV_rtype_seq");
      super.new(name);
    endfunction

    // Fields to be randomized
    rand bit [4:0]  rs1;
    rand bit [4:0]  rs2;
    rand bit [4:0]  rd;
    rand bit [2:0]  funct3;
    rand bit [6:0]  funct7;

    // Fixed opcode for store instructions
    localparam bit [6:0] R_OPCODE = 7'b0110011;

    virtual task body();
      repeat(`NO_OF_TRANSACTIONS) begin
        req = RISCV_transaction::type_id::create("req");
        start_item(req);

        if (!randomize(rs1, rs2, rd, funct3, funct7) with {

          case (funct3)
            3'b000: funct7 inside {7'b0000000, 7'b0100000}; // ADD / SUB
            default: funct7 == 7'b0000000;                  // Fallback to avoid tool warnings
          endcase

        }) `uvm_fatal(get_type_name(), "Randomization failed!");


        req.instr_data = {
          funct7, rs2, rs1, funct3, rd, R_OPCODE
        };

        case (funct3)
          3'b000: req.instr_name = $sformatf("SB x%0d, %0d(x%0d)", rs2, imm, rs1);
          3'b001: req.instr_name = $sformatf("SH x%0d, %0d(x%0d)", rs2, imm, rs1);
          3'b010: req.instr_name = $sformatf("SW x%0d, %0d(x%0d)", rs2, imm, rs1);
          default: req.instr_name = "UNKNOWN_STORE";
        endcase

        `uvm_info(get_full_name(), $sformatf("Sending R-TYPE instruction: %s", req.instr_name), UVM_LOW);
        req.print();

        finish_item(req);
      end
endtask
   
endclass

`endif
