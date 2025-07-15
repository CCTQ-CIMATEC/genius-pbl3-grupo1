`ifndef RISCV_MONITOR
`define RISCV_MONITOR

class RISCV_monitor extends uvm_monitor;

  virtual RISCV_interface vif;
  uvm_analysis_port #(RISCV_transaction) mon2sb_port;

  RISCV_transaction transaction_queue[$];

  `uvm_component_utils(RISCV_monitor)

  function new (string name, uvm_component parent);
    super.new(name, parent);
    mon2sb_port = new("mon2sb_port", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual RISCV_interface)::get(this, "", "intf", vif))
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    // Aguarda sair do reset uma vez
    
    wait(vif.reset);
    repeat(1) @(posedge vif.clk);
   
    forever begin
      collect_inputs();   // Coleta entradas (instruções)
      collect_outputs();  // Coleta saídas (resultados)
    end
  endtask : run_phase

  //inputs
 task collect_inputs();
    RISCV_transaction act_trans;

  if (vif.reset) begin
      act_trans = RISCV_transaction::type_id::create("act_trans", this);

      act_trans.instr_ready    = vif.instr_ready;
      act_trans.instr_data     = vif.instr_data;
      act_trans.data_ready     = vif.data_ready;
      act_trans.data_rd        = vif.data_rd;

      transaction_queue.push_back(act_trans);

          //`uvm_info(get_full_name(), $sformatf("Input captured: instr=0x%08h", act_trans.instr_data), UVM_LOW);
    end
endtask : collect_inputs


//outputs
  task collect_outputs();
    RISCV_transaction complete_trans;
    if (vif.reset && vif.instr_data != 0) begin
      repeat(5) @(posedge vif.clk);
       
      complete_trans = transaction_queue.pop_front();

      complete_trans.inst_rd_en      = vif.inst_rd_en;
      complete_trans.inst_ctrl_cpu   = vif.inst_ctrl_cpu;
      complete_trans.inst_addr       = vif.inst_addr;
      complete_trans.data_wr         = vif.data_wr;
      complete_trans.data_addr       = vif.data_addr;
      complete_trans.data_rd_en_ctrl = vif.data_rd_en_ctrl;
      complete_trans.data_rd_en_ma   = vif.data_rd_en_ma;
      complete_trans.data_wr_en_ma   = vif.data_wr_en_ma;
    
      `uvm_info(get_full_name(), $sformatf("Monitor captured complete transaction"), UVM_LOW);
      complete_trans.print();
      
      // Envia para o scoreboard
      mon2sb_port.write(complete_trans);
    end
  endtask : collect_outputs

endclass : RISCV_monitor

`endif
