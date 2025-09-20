`ifndef RISCV_SLT_SEQ
`define RISCV_SLT_SEQ

class RISCV_slt_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_slt_seq)

  function new(string name = "RISCV_slt_seq");
    super.new(name);
  endfunction

  // Fields to be randomized
  rand bit [4:0] rs1;
  rand bit [4:0] rs2;
  rand bit [4:0] rd;

  // Fixed opcode & funct fields for SLT instruction
  localparam bit [6:0] SLT_OPCODE = 7'b0110011;
  localparam bit [2:0] SLT_FUNCT3 = 3'b010;
  localparam bit [6:0] SLT_FUNCT7 = 7'b0000000;

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1, rs2, rd))
        `uvm_fatal(get_type_name(), "Randomization failed!");

      // Build the SLT instruction (R-type encoding)
      req.instr_ready = 1'b1;
      req.instr_data = {
        SLT_FUNCT7, rs2, rs1, SLT_FUNCT3, rd, SLT_OPCODE
      };

      req.instr_name = $sformatf("SLT x%0d, x%0d, x%0d", rd, rs1, rs2);

      `uvm_info(get_full_name(), $sformatf("Sending SLT instruction: %s", req.instr_name), UVM_LOW);
      req.print();

      finish_item(req);
    end
  endtask

endclass

`endif