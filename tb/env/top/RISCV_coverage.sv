
`ifndef RISCV_COVERAGE
`define RISCV_COVERAGE

class RISCV_coverage#(type T = RISCV_transaction) extends uvm_subscriber#(T);

  `uvm_component_utils(RISCV_coverage)

  covergroup sw_cg with function sample(T trans);
    option.per_instance = 1;
    option.name = "riscv_sw_coverage";
    
    // Instruction fields
    cp_opcode: coverpoint trans.instr_data[6:0] {
      bins sw = {7'b0100011};
    }
    
    cp_funct3: coverpoint trans.instr_data[14:12] {
      bins sw    = {3'b010};
      bins other = default;
    }
    
    // Register usage
    cp_rs1: coverpoint trans.instr_data[19:15] {
      bins zero     = {0};
      bins non_zero = {[1:31]};
    }
    
    cp_rs2: coverpoint trans.instr_data[24:20] {
      bins zero     = {0};
      bins non_zero = {[1:31]};
    }
    
    // Address characteristics
    cp_addr_align: coverpoint trans.data_addr[1:0] {
      bins aligned    = {2'b00};
      illegal_bins unaligned = {[1:3]};
    }
    
    // Control signals
    cp_wr_en: coverpoint trans.data_wr_en_ma {
      bins active   = {1'b1};
      bins inactive = {1'b0};
    }
    
    // Cross coverage
    cross_valid_sw: cross cp_opcode, cp_funct3, cp_rs1, cp_rs2 {
      ignore_bins invalid = binsof(cp_opcode.sw) && 
                           binsof(cp_funct3.sw) &&
                           (binsof(cp_rs1.zero) || binsof(cp_rs2.zero));
    }
    
    cross_wr_ops: cross cp_opcode, cp_funct3, cp_wr_en;
  endgroup

  function new(string name = "RISCV_coverage", uvm_component parent);
    super.new(name, parent);
    sw_cg = new();
  endfunction

  function void write(T t);
    if (t.instr_data[6:0] == 7'b0100011) begin
      if (t.instr_data[14:12] == 3'b010) begin // SW
        `uvm_info(get_type_name(), 
          $sformatf("Coverage: SW rs1=x%0d, rs2=x%0d, wr_en=%b, addr=0x%08h", 
          t.instr_data[19:15], t.instr_data[24:20], 
          t.data_wr_en_ma, t.data_addr), 
          UVM_MEDIUM)
          
        sw_cg.sample(t);
      end
      else begin
        `uvm_info(get_type_name(),
          $sformatf("Unsupported store type: funct3=%0d", t.instr_data[14:12]),
          UVM_HIGH)
      end
    end
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),
      $sformatf("Coverage SW Instructions: %0.2f%%", sw_cg.get_inst_coverage()),
      UVM_LOW)
  endfunction

endclass

`endif