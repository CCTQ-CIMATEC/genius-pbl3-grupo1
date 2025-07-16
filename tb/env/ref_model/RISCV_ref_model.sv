`ifndef RISCV_REF_MODEL
`define RISCV_REF_MODEL

class RISCV_ref_model extends uvm_component;
  `uvm_component_utils(RISCV_ref_model)

  uvm_analysis_export#(RISCV_transaction)       rm_export;
  uvm_analysis_port#(RISCV_transaction)         rm2sb_port;
  uvm_tlm_analysis_fifo#(RISCV_transaction)     rm_exp_fifo;

  logic [31:0] regfile[32];
  wb_info_t writeback_queue[5];

  RISCV_transaction rm_trans;
  RISCV_transaction exp_trans;

  function new(string name = "RISCV_ref_model", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rm_export    = new("rm_export", this);
    rm2sb_port   = new("rm2sb_port", this);
    rm_exp_fifo  = new("rm_exp_fifo", this);

    foreach (regfile[i]) regfile[i] = 32'h0;
    foreach (writeback_queue[i]) writeback_queue[i] = '{rd: 0, value: 0, we: 0};
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rm_export.connect(rm_exp_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      if (writeback_queue[0].we && writeback_queue[0].rd != 0)
        regfile[writeback_queue[0].rd] = writeback_queue[0].value;

      for (int i = 0; i < 4; i++)
        writeback_queue[i] = writeback_queue[i+1];
      writeback_queue[4] = '{rd: 0, value: 0, we: 0};

      rm_exp_fifo.get(rm_trans);
      process_andi(rm_trans);
    end
  endtask

  task automatic process_andi(RISCV_transaction input_trans);
    RISCV_transaction exp_trans_local;
    bit [31:0] rs1_val, imm_sext, rd_val;
    bit [4:0]  rs1, rd;
    wb_info_t  wb;

    exp_trans_local = RISCV_transaction::type_id::create("exp_trans_local");
    exp_trans_local.copy(input_trans);

    rs1 = input_trans.instr_data[19:15];
    rd  = input_trans.instr_data[11:7];

    rs1_val = get_forwarded_value(rs1);
    imm_sext = {{20{input_trans.instr_data[31]}}, input_trans.instr_data[31:20]};
    rd_val = rs1_val & imm_sext;

    exp_trans_local.data_addr = rd_val;
    exp_trans_local.data_rd   = rd_val;

    wb = '{rd: rd, value: rd_val, we: 1};

    writeback_queue[4] = wb;
    rm2sb_port.write(exp_trans_local);
  endtask

  function bit [31:0] get_forwarded_value(input bit [4:0] reg_addr);
    if (reg_addr == 0) return 0;
    for (int i = 4; i >= 0; i--)
      if (writeback_queue[i].we && writeback_queue[i].rd == reg_addr)
        return writeback_queue[i].value;
    return regfile[reg_addr];
  endfunction

endclass

`endif
