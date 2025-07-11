`ifndef RISCV_DRIVER
`define RISCV_DRIVER

class RISCV_driver extends uvm_driver #(RISCV_transaction);

  RISCV_transaction trans;
  virtual RISCV_interface vif;

  `uvm_component_utils(RISCV_driver)
  uvm_analysis_port#(RISCV_transaction) drv2rm_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual RISCV_interface)::get(this, "", "intf", vif))
      `uvm_fatal("NO_VIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
    drv2rm_port = new("drv2rm_port", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    reset();
    wait(vif.reset);
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      
      req.print();
      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      drv2rm_port.write(rsp);
      seq_item_port.item_done();

      repeat(4) @(posedge vif.clk); //await a little before send a new transactions
    end
  endtask

  /*
   * Task: drive
   * Dirige os sinais da transação para o DUT via interface.
   */
 task drive();
    
    // Drive instruction to DUT
    vif.instr_data <= req.instr_data;
    vif.data_rd    <= req.data_rd;
    
    `uvm_info(get_full_name(), $sformatf("Driving instruction: %s", req.instr_name), UVM_LOW);
endtask


  /*
   * Task: reset
   * Inicializa os sinais de entrada durante o reset.
   */
 task reset();
  @(vif.dr_cb);
  vif.dr_cb.instr_data <= 32'd0;
endtask


endclass

`endif