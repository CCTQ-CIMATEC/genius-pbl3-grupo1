//------------------------------------------------------------------------------
// Author: Ramylla Bezerra
// Date  : Jul 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SRLI_SEQ 
`define RISCV_SRLI_SEQ 

class RISCV_srli_seq extends uvm_sequence#(RISCV_transaction); 

  `uvm_object_utils(RISCV_srli_seq) 

  rand bit [4:0]  rs1_addr; 
  rand bit [4:0]  rd_addr; 
  rand bit [4:0]  shamt;

  localparam bit [6:0] SRLI_OPCODE = 7'b0010011; 
  localparam bit [2:0] SRLI_FUNCT3 = 3'b101;    
  localparam bit [6:0] SRLI_FUNCT7 = 7'b0100000; 
  constraint c_rd_addr { rd_addr != 5'h0; }
  constraint c_shamt { shamt >= 0; shamt <= 31; }

  function new(string name = "RISCV_srli_seq"); 
    super.new(name);
  endfunction

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin 

      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_addr, rd_addr, shamt)) begin 
        `uvm_fatal(get_type_name(), "SRLI sequence randomization failed!");
      end

      req.instr_data = {
        SRLI_FUNCT7,  // [31:25] 
        shamt,        // [24:20] 
        rs1_addr,     // [19:15]
        SRLI_FUNCT3,  // [14:12]
        rd_addr,      // [11:7]
        SRLI_OPCODE   // [6:0]
      };

      req.instr_name = $sformatf("SRLI x%0d, x%0d, %0d", rd_addr, rs1_addr, shamt); 

      `uvm_info(get_full_name(), $sformatf("Sending SRLI instruction: %s (0x%0h)", req.instr_name, req.instr_data), UVM_LOW); 

      req.print(); 

      finish_item(req); 
    end
  endtask

endclass

`endif
