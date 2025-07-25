`ifndef RISCV_XORI_SEQ
`define RISCV_XORI_SEQ

class RISCV_xori_seq extends uvm_sequence#(RISCV_transaction);
  `uvm_object_utils(RISCV_xori_seq)

  function new(string name = "RISCV_xori_seq");
    super.new(name);
  endfunction

  virtual task body();
    RISCV_transaction trans;

    trans = RISCV_transaction::type_id::create("trans");

    // Configuração da instrução XORI x3, x4, 0x3F
    trans.instr_ready = 1'b1;
    trans.instr_data = {12'h03F, 5'd4, 3'b100, 5'd3, 7'b0010011}; // XORI: opcode = 0010011, funct3 = 100
    trans.inst_rd_en = 1'b1;
    trans.inst_ctrl_cpu = 4'b0000;
    trans.inst_addr = 32'h00;

    // Nenhum acesso à memória
    trans.data_ready = 1'b1;
    trans.data_addr = 32'h0;
    trans.data_rd = 32'h0;
    trans.data_rd_en_ma = 0;
    trans.data_wr_en_ma = 0;
    trans.data_wr = 32'h0;

    start_item(trans);
    finish_item(trans);

    `uvm_info(get_name(), $sformatf("Generated XORI instruction: XORI x3, x4, 0x3F | Encoded = 0x%h", trans.instr_data), UVM_LOW)
  endtask
endclass
`endif