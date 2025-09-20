`ifndef RISCV_SH_SEQ 
`define RISCV_SH_SEQ

class RISCV_sh_seq extends uvm_sequence#(RISCV_transaction);
   
  `uvm_object_utils(RISCV_sh_seq)

  // Fields to be randomized
  rand bit [4:0]  rs1;    // Base register
  rand bit [4:0]  rs2;    // Source register
  rand bit [11:0] imm;    // Immediate offset (12-bit signed)

  // Constraints for valid SH instruction
  constraint sh_constraints {
    rs1 inside {[1:31]};  // x1-x31 only
    rs2 inside {[1:31]};  // x1-x31 only
    imm[0] == 1'b0;       // Halfword-aligned (LSB = 0)
  }

  function new(string name = "RISCV_sh_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize()) 
        `uvm_fatal(get_type_name(), "Randomization failed for SH instruction!");
    
      // Build the SH instruction (S-type encoding)
      req.instr_ready = 1'b1;
      req.instr_data = {
        imm[11:5], rs2, rs1, 3'b001, imm[4:0], 7'b0100011  // SH opcode
      };

      req.instr_name = $sformatf("SH x%0d, %0d(x%0d)", rs2, $signed(imm), rs1);

      `uvm_info(get_type_name(), 
        $sformatf("Sending valid SH instruction: %s", req.instr_name), UVM_HIGH);
      
      finish_item(req);
    end
  endtask
   
endclass

`endif