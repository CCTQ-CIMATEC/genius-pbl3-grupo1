//------------------------------------------------------------------------------
// Author: Ramylla Bezerra
// Date  : Jul 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SLLI_SEQ 
`define RISCV_SLLI_SEQ 

class RISCV_slli_seq extends uvm_sequence#(RISCV_transaction); 

  `uvm_object_utils(RISCV_slli_seq)

  rand bit [4:0]  rs1_addr; 
  rand bit [4:0]  rd_addr;  
  rand bit [4:0]  shamt;   

  localparam bit [6:0] SLLI_OPCODE = 7'b0010011; 
  localparam bit [2:0] SLLI_FUNCT3 = 3'b001;   

  constraint c_rd_addr { rd_addr != 5'h0; }
  constraint c_shamt { shamt >= 0 && shamt <= 31; } 

  function new(string name = "RISCV_slli_seq"); 
    super.new(name);
  endfunction

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin 

      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_addr, rd_addr, shamt)) begin
        `uvm_fatal(get_type_name(), "SLLI sequence randomization failed!"); 
      end

      req.instr_data = {
        5'b0,         // [31:25] 
        shamt,        // [24:20] 
        rs1_addr,     // [19:15]
        SLLI_FUNCT3,  // [14:12]
        rd_addr,      // [11:7]
        SLLI_OPCODE   // [6:0]
      };

      req.instr_name = $sformatf("SLLI x%0d, x%0d, %0d", rd_addr, rs1_addr, shamt); 

      `uvm_info(get_full_name(), $sformatf("Sending SLLI instruction: %s (0x%0h)", req.instr_name, req.instr_data), UVM_LOW); 

      req.print();

      finish_item(req);
    end
  endtask

endclass

`endif