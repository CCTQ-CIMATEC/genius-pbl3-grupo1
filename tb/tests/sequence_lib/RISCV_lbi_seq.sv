`ifndef RISCV_LBI_SEQ
`define RISCV_LBI_SEQ

class RISCV_lbi_seq extends uvm_sequence#(RISCV_transaction);
  `uvm_object_utils(RISCV_lbi_seq)

  function new(string name = "RISCV_lbi_seq");
    super.new(name);
  endfunction

  virtual task body();
    RISCV_transaction trans;

    trans = RISCV_transaction::type_id::create("trans");

    trans.instr_ready = 1'b1;
    trans.instr_data = {12'h0A5, 5'd2, 3'b000, 5'd1, 7'b0010011}; // LBI x1, x2, 0x0A5 (ADDI style)
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

    `uvm_info(get_name(), $sformatf("Generated LBI-like instruction (ADDI): LBI x1, x2, 0x0A5 | Encoded = 0x%h", trans.instr_data), UVM_LOW)
  endtask
endclass

`endif
