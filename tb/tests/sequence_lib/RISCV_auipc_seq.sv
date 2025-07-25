`ifndef RISCV_AUIPC_SEQ 
`define RISCV_AUIPC_SEQ

class RISCV_auipc_seq extends uvm_sequence#(RISCV_transaction);
   
  `uvm_object_utils(RISCV_auipc_seq)

  // Fields to be randomized
  rand bit [4:0]  rd;         // Destination register
  rand bit [19:0] imm20;      // 20-bit immediate value
  rand bit [31:0] pc_value;   // Simulated PC value (critical for AUIPC)

  // Constraints
  constraint auipc_constraints {
    rd inside {[1:31]};       // x1-x31 only
    imm20 dist {
      20'h00000 := 1,
      20'hFFFFF := 1,
      [20'h00001:20'hFFFE] :/ 10
    };
  }

  function new(string name = "RISCV_auipc_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize()) 
        `uvm_fatal(get_type_name(), "Randomization failed for AUIPC instruction!");
    
      // Build the AUIPC instruction (U-type encoding)
      req.instr_ready = 1'b1;
      req.instr_data = {
        imm20, rd, 7'b0010111  // AUIPC opcode
      };

      // Set expected values for reference model
      req.inst_addr = pc_value;
      req.instr_name = $sformatf("AUIPC x%0d, 0x%05h // PC=0x%08h", rd, imm20, pc_value);

      `uvm_info(get_type_name(), 
        $sformatf("Generating AUIPC instruction: %s (Expected result: 0x%08h)", 
        req.instr_name, (pc_value + {imm20, 12'b0})), UVM_HIGH);
      
      finish_item(req);
      
      // Update PC for next instruction (simulate +4 bytes)
      pc_value += 4;
    end
  endtask
   
endclass

`endif