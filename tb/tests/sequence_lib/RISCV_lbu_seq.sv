`ifndef RISCV_LBU_SEQ
`define RISCV_LBU_SEQ

class RISCV_lbu_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_lbu_seq)

  function new(string name = "RISCV_lbu_seq");
    super.new(name);
  endfunction

  // Fields to be randomized
  rand bit [4:0] rs1;    // Base register
  rand bit [4:0] rd;     // Destination register
  rand bit [11:0] imm;   // 12-bit immediate offset

  // Fixed opcode & funct fields for LBU instruction (I-type load)
  localparam bit [6:0] LBU_OPCODE = 7'b0000011;  // Load opcode
  localparam bit [2:0] LBU_FUNCT3 = 3'b100;      // Byte load unsigned function

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1, rd, imm))
        `uvm_fatal(get_type_name(), "Randomization failed!");

      // Build the LBU instruction (I-type encoding)
      req.instr_ready = 1'b1;
      req.instr_data = {
        imm, rs1, LBU_FUNCT3, rd, LBU_OPCODE
      };

      req.instr_name = $sformatf("LBU x%0d, %0d(x%0d)", rd, $signed(imm), rs1);

      `uvm_info(get_full_name(), $sformatf("Sending LBU instruction: %s", req.instr_name), UVM_LOW);
      req.print();

      finish_item(req);
    end
  endtask

endclass

`endif