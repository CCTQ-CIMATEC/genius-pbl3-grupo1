`ifndef RISCV_LH_SEQ
`define RISCV_LH_SEQ

class RISCV_lh_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_lh_seq)

  function new(string name = "RISCV_lh_seq");
    super.new(name);
  endfunction

  // Fields to be randomized
  rand bit [4:0] rs1;    // Base register
  rand bit [4:0] rd;     // Destination register
  rand bit [11:0] imm;   // 12-bit immediate offset

  // Fixed opcode & funct fields for LH instruction (I-type load)
  localparam bit [6:0] LH_OPCODE = 7'b0000011;  // Load opcode
  localparam bit [2:0] LH_FUNCT3 = 3'b001;      // Halfword load function

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1, rd, imm))
        `uvm_fatal(get_type_name(), "Randomization failed!");

      // Build the LH instruction (I-type encoding)
      req.instr_ready = 1'b1;
      req.instr_data = {
        imm, rs1, LH_FUNCT3, rd, LH_OPCODE
      };

      req.instr_name = $sformatf("LH x%0d, %0d(x%0d)", rd, $signed(imm), rs1);

      `uvm_info(get_full_name(), $sformatf("Sending LH instruction: %s", req.instr_name), UVM_LOW);
      req.print();

      finish_item(req);
    end
  endtask

endclass

`endif