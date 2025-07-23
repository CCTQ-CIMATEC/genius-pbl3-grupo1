`ifndef RISCV_RTYPE_SEQ 
`define RISCV_RTYPE_SEQ

class RISCV_rtype_seq extends uvm_sequence#(RISCV_transaction);
   
  `uvm_object_utils(RISCV_rtype_seq)

    function new(string name = "RISCV_rtype_seq");
      super.new(name);
    endfunction

    // Fields to be randomized
    rand bit [4:0]  rs1;
    rand bit [4:0]  rs2;
    rand bit [4:0]  rd;
    rand bit [2:0]  funct3;
    rand bit [6:0]  funct7;

    // Fixed opcode for store instructions
    localparam bit [6:0] R_OPCODE = 7'b0110011;

    virtual task body();
      repeat(`NO_OF_TRANSACTIONS) begin
        req = RISCV_transaction::type_id::create("req");
        start_item(req);

        // Inside the body() task of RISCV_rtype_seq
        if (!randomize(rs1, rs2, rd, funct3, funct7) with {
              // ADD/SUB
              (funct3 == 3'b000) -> (funct7 inside {7'b0000000, 7'b0100000});
              //SRL/SRA
              (funct3 == 3'b101) -> (funct7 inside {7'b0000000, 7'b0100000});
              // SLL/XOR/OR/AND
              (funct3 inside {3'b001, 3'b100, 3'b110, 3'b111}) -> (funct7 == 7'b0000000);
          }) `uvm_fatal(get_type_name(), "Randomization failed!");


        req.instr_data = {
          funct7, rs2, rs1, funct3, rd, R_OPCODE
        };

        case (funct3)
            3'b000: req.instr_name = (funct7 == 7'b0000000) ? "ADD" : "SUB";
            3'b001: req.instr_name = "SLL";
            3'b100: req.instr_name = "XOR";
            3'b101: req.instr_name = (funct7 == 7'b0000000) ? "SRL" : "SRA";
            3'b110: req.instr_name = "OR";
            3'b111: req.instr_name = "AND";
            default: req.instr_name = "UNKNOWN";
        endcase

        `uvm_info(get_type_name(), $sformatf("%s x%0d,x%0d,x%0d [0x%08h]", req.instr_name, rd, rs1, rs2, req.instr_data), UVM_HIGH);        
        //req.print();

        finish_item(req);
      end
endtask
   
endclass

`endif
