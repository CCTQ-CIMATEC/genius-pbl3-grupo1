`ifndef RISCV_and_SEQ 
`define RISCV_and_SEQ

class RISCV_and_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_and_seq)

  function new(string name = "RISCV_and_seq");
    super.new(name);
  endfunction

  // Fields to be randomized
  rand bit [4:0] rs1;
  rand bit [4:0] rs2;
  rand bit [4:0] rd;

  // Fixed opcode & funct fields for AND instruction
  localparam bit [6:0] AND_OPCODE = 7'b0110011;
  localparam bit [2:0] AND_FUNCT3 = 3'b111;
  localparam bit [6:0] AND_FUNCT7 = 7'b0000000;

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1, rs2, rd)) 
        `uvm_fatal(get_type_name(), "Randomization failed!");

      // Build the AND instruction (R-type encoding)
      req.instr_ready = 1'b1;
      req.instr_data = {
        AND_FUNCT7, rs2, rs1, AND_FUNCT3, rd, AND_OPCODE
      };

      req.instr_name = $sformatf("AND x%0d, x%0d, x%0d", rd, rs1, rs2);

      `uvm_info(get_full_name(), $sformatf("Sending AND instruction: %s", req.instr_name), UVM_LOW);
      req.print();

      finish_item(req);
    end
  endtask

endclass

`endif