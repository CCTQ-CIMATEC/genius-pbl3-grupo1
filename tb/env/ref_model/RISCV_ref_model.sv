`ifndef RISCV_REF_MODEL 
`define RISCV_REF_MODEL

class RISCV_ref_model extends uvm_component;
  `uvm_component_utils(RISCV_ref_model)

  uvm_analysis_export#(RISCV_transaction) rm_export;
  uvm_analysis_port#(RISCV_transaction) rm2sb_port;
  uvm_tlm_analysis_fifo#(RISCV_transaction) rm_exp_fifo;

  logic [31:0] regfile[32];

  typedef struct {
    logic [4:0]  rd;
    logic [31:0] value;
    bit          we;
  } wb_info_t;

  wb_info_t writeback_queue[5];

  RISCV_transaction rm_trans;
  RISCV_transaction exp_trans;

  function new(string name = "RISCV_ref_model", uvm_component parent);
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
      if (writeback_queue[0].we && writeback_queue[0].rd != 0) begin
        regfile[writeback_queue[0].rd] = writeback_queue[0].value;
      end

      for (int i = 0; i < 4; i++) begin
        writeback_queue[i] = writeback_queue[i+1];
      end
      writeback_queue[4] = '{rd: 0, value: 0, we: 0};

      rm_exp_fifo.get(rm_trans);
      process_instruction(rm_trans);
    end
  endtask

  task automatic process_instruction(RISCV_transaction input_trans);
    RISCV_transaction exp_trans_local;
    bit [6:0] opcode;
    bit [2:0] funct3;
    bit [4:0] reg1_addr;
    bit [4:0] reg_dest;
    bit [31:0] rs1;
    bit [31:0] imm;
    wb_info_t wb;

    exp_trans_local = RISCV_transaction::type_id::create("exp_trans_local");
    exp_trans_local.copy(input_trans);

    opcode     = input_trans.instr_data[6:0];
    funct3     = input_trans.instr_data[14:12];
    reg1_addr  = input_trans.instr_data[19:15];
    reg_dest   = input_trans.instr_data[11:7];
    imm        = {{20{input_trans.instr_data[31]}}, input_trans.instr_data[31:20]};
    rs1        = regfile[reg1_addr];
    
    wb = '{rd: 0, value: 0, we: 0};

    // ORI instruction only
    if (opcode == 7'b0010011 && funct3 == 3'b110) begin
      exp_trans_local.data_addr = 32'h0;
      exp_trans_local.data_wr_en_ma = 0;
      exp_trans_local.data_wr = 32'h0;
      wb = '{rd: reg_dest, value: rs1 | imm, we: 1};
    end 
    
   else if (opcode == 7'b0010011 && funct3 == 3'b100) begin
  logic signed [31:0] imm_sext;
  imm_sext = {{20{input_trans.instr_data[31]}}, input_trans.instr_data[31:20]};
  exp_trans_local.data_addr = rs1 ^ imm_sext;
 // exp_trans_local.resultado_esperado = rs1 ^ imm_sext;
  wb = '{rd: reg_dest, value: exp_trans_local.data_addr, we: 1};
end


    else begin
      `uvm_warning(get_full_name(), $sformatf("Unsupported instruction: 0x%h", input_trans.instr_data));
    end

    writeback_queue[4] = wb;
    rm2sb_port.write(exp_trans_local);
  endtask

endclass

`endif
