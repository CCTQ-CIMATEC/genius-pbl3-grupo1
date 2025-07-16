//------------------------------------------------------------------------------
// Author: Ramylla Bezerra
// Date  : Jul 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SLL_SEQ
`define RISCV_SLL_SEQ

class RISCV_sll_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_sll_seq)

  rand bit [4:0]  rs1_addr; 
  rand bit [4:0]  rs2_addr; 
  rand bit [4:0]  rd_addr; 

  localparam bit [6:0] SLL_OPCODE = 7'b0110011; 
  localparam bit [2:0] SLL_FUNCT3 = 3'b001;    
  localparam bit [6:0] SLL_FUNCT7 = 7'b0000000; 

 
  constraint c_rd_addr { rd_addr != 5'h0; }

  function new(string name = "RISCV_sll_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin

      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_addr, rs2_addr, rd_addr)) begin
        `uvm_fatal(get_type_name(), "SLL sequence randomization failed!");
      end

      req.instr_data = {
        SLL_FUNCT7,   // [31:25]
        rs2_addr,     // [24:20]
        rs1_addr,     // [19:15]
        SLL_FUNCT3,   // [14:12]
        rd_addr,      // [11:7]
        SLL_OPCODE    // [6:0]
      };

      req.instr_name = $sformatf("SLL x%0d, x%0d, x%0d", rd_addr, rs1_addr, rs2_addr);

      `uvm_info(get_full_name(), $sformatf("Sending SLL instruction: %s (0x%0h)", req.instr_name, req.instr_data), UVM_LOW);

      req.print(); 

      finish_item(req);
    end
  endtask

endclass

`endif 