`ifndef RISCV_LW_SEQ
`define RISCV_LW_SEQ

class RISCV_lw_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_lw_seq)

  function new(string name = "RISCV_lw_seq");
    super.new(name);
  endfunction

  // Fields to be randomized
  rand bit [4:0] rs1;    // Base register
  rand bit [4:0] rd;     // Destination register
  rand bit [11:0] imm;   // 12-bit immediate offset

  // Fixed opcode & funct fields for LW instruction (I-type load)
  localparam bit [6:0] LW_OPCODE = 7'b0000011;  // Load opcode
  localparam bit [2:0] LW_FUNCT3 = 3'b010;      // Word load function

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1, rd, imm))
        `uvm_fatal(get_type_name(), "Randomization failed!");

      // Build the LW instruction (I-type encoding)
      req.instr_ready = 1'b1;
      req.instr_data = {
        imm, rs1, LW_FUNCT3, rd, LW_OPCODE
      };

      req.instr_name = $sformatf("LW x%0d, %0d(x%0d)", rd, $signed(imm), rs1);

      `uvm_info(get_full_name(), $sformatf("Sending LW instruction: %s", req.instr_name), UVM_LOW);
      req.print();

      finish_item(req);
    end
  endtask

endclass

`endif