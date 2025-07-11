
`ifndef RISCV_STORE_SEQ 
`define RISCV_STORE_SEQ

class RISCV_store_seq extends uvm_sequence#(RISCV_transaction);
   
  `uvm_object_utils(RISCV_store_seq)

  function new(string name = "RISCV_store_seq");
    super.new(name);
  endfunction

  // Fields to be randomized
  rand bit [4:0]  rs1;
  rand bit [4:0]  rs2;
  rand bit [11:0] imm;
  rand bit [2:0]  funct3;

  // Fixed opcode for store instructions
  localparam bit [6:0] STORE_OPCODE = 7'b0100011;

virtual task body();
  repeat(`NO_OF_TRANSACTIONS) begin
    req = RISCV_transaction::type_id::create("req");
    start_item(req);

    if (!randomize(rs1, rs2, imm, funct3) with {
      funct3 inside {3'b000, 3'b001, 3'b010};
    }) 
    `uvm_fatal(get_type_name(), "Randomization failed!");
    
  

    if (funct3 == 3'b010) begin
      imm[1:0] = 2'b00; // Align to 4 bytes
    end
    
    // Build the store instruction (S-type encoding)
    req.instr_ready = 1'b1;
    req.instr_data = {
      imm[11:5], rs2, rs1, funct3, imm[4:0], STORE_OPCODE
    };

    case (funct3)
      3'b000: req.instr_name = $sformatf("SB x%0d, %0d(x%0d)", rs2, imm, rs1);
      3'b001: req.instr_name = $sformatf("SH x%0d, %0d(x%0d)", rs2, imm, rs1);
      3'b010: req.instr_name = $sformatf("SW x%0d, %0d(x%0d)", rs2, imm, rs1);
      default: req.instr_name = "UNKNOWN_STORE";
    endcase

    `uvm_info(get_full_name(), $sformatf("Sending STORE instruction: %s", req.instr_name), UVM_LOW);
    req.print();

    finish_item(req);
    //get_response(rsp);
  end
endtask
   
endclass

`endif
