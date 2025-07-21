`ifndef RISCV_SB_SEQ 
`define RISCV_SB_SEQ

class RISCV_sb_seq extends uvm_sequence#(RISCV_transaction);
   
  `uvm_object_utils(RISCV_sb_seq)

  // Fields to be randomized
  rand bit [4:0]  rs1;    // Base register
  rand bit [4:0]  rs2;    // Source register
  rand bit [11:0] imm;    // Immediate offset (12-bit signed)

  // Constraints for valid SB instruction
  constraint sb_constraints {
    rs1 inside {[1:31]};  // x1-x31 only
    rs2 inside {[1:31]};  // x1-x31 only
    // No alignment constraint for bytes
  }

  function new(string name = "RISCV_sb_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize()) 
        `uvm_fatal(get_type_name(), "Randomization failed for SB instruction!");
    
      // Build the SB instruction (S-type encoding)
      req.instr_ready = 1'b1;
      req.instr_data = {
        imm[11:5], rs2, rs1, 3'b000, imm[4:0], 7'b0100011  // SB opcode
      };

      req.instr_name = $sformatf("SB x%0d, %0d(x%0d)", rs2, $signed(imm), rs1);

      `uvm_info(get_type_name(), 
        $sformatf("Sending valid SB instruction: %s", req.instr_name), UVM_HIGH);
      
      finish_item(req);
    end
  endtask
   
endclass

`endif