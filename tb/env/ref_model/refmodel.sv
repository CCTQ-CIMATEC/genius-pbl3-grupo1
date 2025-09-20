//------------------------------------------------------------------------------
// Enhanced Reference model module for RISCV RV32I
//------------------------------------------------------------------------------
// This module defines an enhanced reference model for RISCV verification
// supporting pipeline stalls and a subset of RV32I instructions.
//
// Supported Instructions:
// R-type: ADD, SUB, AND, OR, XOR, SLT, SLL, SRL
// I-type: ADDI, ANDI, ORI
// S-type: SW, SH, SB
//
// Author: Enhanced by Claude
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_REF_MODEL
`define RISCV_REF_MODEL

class RISCV_ref_model extends uvm_component;
  `uvm_component_utils(RISCV_ref_model)

  // Ports for input and output transactions
  uvm_analysis_export#(RISCV_transaction) rm_export;
  uvm_analysis_port#(RISCV_transaction) rm2sb_port;
  uvm_tlm_analysis_fifo#(RISCV_transaction) rm_exp_fifo;

  // Shadow register file (x0–x31, x0 always zero)
  logic [31:0] regfile[32];

  // Pipeline stage tracking
  typedef struct {
    logic [4:0]  rd;           // Destination register
    logic [31:0] value;        // Value to write back
    bit          we;           // Write enable
    int          cycles_left;  // Cycles until writeback
  } wb_info_t;

  // Pipeline entries (support up to 8 outstanding instructions)
  wb_info_t writeback_queue[$];
  
  // Stall detection
  bit pipeline_stalled;
  int stall_cycles_remaining;

  // Internal transaction handles
  RISCV_transaction rm_trans;
  RISCV_transaction exp_trans;

  function new(string name = "RISCV_ref_model", uvm_component parent);
    super.new(name, parent);
    pipeline_stalled = 0;
    stall_cycles_remaining = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rm_export    = new("rm_export", this);
    rm2sb_port   = new("rm2sb_port", this);
    rm_exp_fifo  = new("rm_exp_fifo", this);
    
    // Initialize regfile (x0 is always 0)
    foreach (regfile[i]) regfile[i] = 32'h0;
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rm_export.connect(rm_exp_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      // Process writeback queue every cycle
      process_writeback_queue();
      
      // Handle pipeline stalls
      if (pipeline_stalled) begin
        stall_cycles_remaining--;
        if (stall_cycles_remaining <= 0) begin
          pipeline_stalled = 0;
        end
        #1; // Wait one cycle
        continue;
      end

      // Try to get a new transaction (non-blocking)
      if (rm_exp_fifo.try_get(rm_trans)) begin
        process_instruction(rm_trans);
      end
      
      #1; // Advance one cycle
    end
  endtask

  // Process writeback queue each cycle
  function void process_writeback_queue();
    int i = 0;
    
    // Process all entries in the queue
    while (i < writeback_queue.size()) begin
      writeback_queue[i].cycles_left--;
      
      // If ready for writeback
      if (writeback_queue[i].cycles_left <= 0) begin
        if (writeback_queue[i].we && writeback_queue[i].rd != 0) begin
          regfile[writeback_queue[i].rd] = writeback_queue[i].value;
          `uvm_info(get_full_name(), 
                   $sformatf("Writeback: x%0d = 0x%08h", 
                            writeback_queue[i].rd, writeback_queue[i].value), 
                   UVM_DEBUG)
        end
        writeback_queue.delete(i);
      end else begin
        i++;
      end
    end
  endfunction

  // Check for hazards and determine if stall is needed
  function bit check_hazards(bit [4:0] rs1, bit [4:0] rs2);
    foreach (writeback_queue[i]) begin
      if (writeback_queue[i].we && 
          (writeback_queue[i].rd == rs1 || writeback_queue[i].rd == rs2) &&
          writeback_queue[i].rd != 0) begin
        return 1; // Hazard detected
      end
    end
    return 0; // No hazard
  endfunction

  task automatic process_instruction(RISCV_transaction input_trans);
    RISCV_transaction exp_trans_local;
    bit [6:0]   opcode;
    bit [2:0]   funct3;
    bit [6:0]   funct7;
    bit [4:0]   rs1_addr, rs2_addr, rd_addr;
    bit [31:0]  rs1_val, rs2_val;
    bit [31:0]  imm_i, imm_s;
    bit [31:0]  result;
    wb_info_t   wb;
    bit         needs_writeback;
    int         execution_cycles;

    // Create expected transaction
    exp_trans_local = RISCV_transaction::type_id::create("exp_trans_local");
    exp_trans_local.copy(input_trans);

    // Decode instruction
    opcode   = input_trans.instr_data[6:0];
    funct3   = input_trans.instr_data[14:12];
    funct7   = input_trans.instr_data[31:25];
    rs1_addr = input_trans.instr_data[19:15];
    rs2_addr = input_trans.instr_data[24:20];
    rd_addr  = input_trans.instr_data[11:7];

    // Sign-extend immediates
    imm_i = {{20{input_trans.instr_data[31]}}, input_trans.instr_data[31:20]};
    imm_s = {{20{input_trans.instr_data[31]}}, 
             input_trans.instr_data[31:25], input_trans.instr_data[11:7]};

    // Check for data hazards
    if (check_hazards(rs1_addr, rs2_addr)) begin
      pipeline_stalled = 1;
      stall_cycles_remaining = 2; // Typical stall duration
      `uvm_info(get_full_name(), "Pipeline stall due to data hazard", UVM_DEBUG)
      return;
    end

    // Get register values
    rs1_val = regfile[rs1_addr];
    rs2_val = regfile[rs2_addr];

    // Initialize defaults
    needs_writeback = 0;
    execution_cycles = 1; // Most instructions take 1 cycle
    wb = '{rd: 0, value: 0, we: 0, cycles_left: 0};

    case (opcode)
      // R-type instructions (0110011)
      7'b0110011: begin
        needs_writeback = 1;
        case (funct3)
          3'b000: begin // ADD/SUB
            if (funct7[5]) begin
              result = rs1_val - rs2_val; // SUB
              `uvm_info(get_full_name(), 
                       $sformatf("SUB: x%0d = x%0d - x%0d = 0x%08h - 0x%08h = 0x%08h", 
                                rd_addr, rs1_addr, rs2_addr, rs1_val, rs2_val, result), 
                       UVM_DEBUG)
            end else begin
              result = rs1_val + rs2_val; // ADD
              `uvm_info(get_full_name(), 
                       $sformatf("ADD: x%0d = x%0d + x%0d = 0x%08h + 0x%08h = 0x%08h", 
                                rd_addr, rs1_addr, rs2_addr, rs1_val, rs2_val, result), 
                       UVM_DEBUG)
            end
          end
          3'b111: result = rs1_val & rs2_val;  // AND
          3'b110: result = rs1_val | rs2_val;  // OR
          3'b100: result = rs1_val ^ rs2_val;  // XOR
          3'b010: result = ($signed(rs1_val) < $signed(rs2_val)) ? 1 : 0; // SLT
          3'b001: result = rs1_val << rs2_val[4:0]; // SLL
          3'b101: result = rs1_val >> rs2_val[4:0]; // SRL
          default: `uvm_error(get_full_name(), $sformatf("Unsupported R-type funct3: %b", funct3))
        endcase
        exp_trans_local.data_addr = result;
      end

      // I-type instructions (0010011)
      7'b0010011: begin
        needs_writeback = 1;
        case (funct3)
          3'b000: result = rs1_val + imm_i;    // ADDI
          3'b111: result = rs1_val & imm_i;    // ANDI
          3'b110: result = rs1_val | imm_i;    // ORI
          default: `uvm_error(get_full_name(), $sformatf("Unsupported I-type funct3: %b", funct3))
        endcase
        exp_trans_local.data_addr = result;
        `uvm_info(get_full_name(), 
                 $sformatf("I-type: x%0d = x%0d op 0x%08h = 0x%08h", 
                          rd_addr, rs1_addr, imm_i, result), 
                 UVM_DEBUG)
      end

      // S-type instructions (0100011) - Store
      7'b0100011: begin
        needs_writeback = 0; // Stores don't write to registers
        exp_trans_local.data_addr = rs1_val + imm_s;
        exp_trans_local.data_wr = rs2_val;
        exp_trans_local.data_wr_en_ma = 1;
        
        case (funct3)
          3'b010: begin // SW
            `uvm_info(get_full_name(), 
                     $sformatf("SW: MEM[0x%08h] = 0x%08h", exp_trans_local.data_addr, rs2_val), 
                     UVM_DEBUG)
          end
          3'b001: begin // SH
            exp_trans_local.data_wr = rs2_val & 32'h0000FFFF;
            `uvm_info(get_full_name(), 
                     $sformatf("SH: MEM[0x%08h] = 0x%04h", exp_trans_local.data_addr, rs2_val[15:0]), 
                     UVM_DEBUG)
          end
          3'b000: begin // SB
            exp_trans_local.data_wr = rs2_val & 32'h000000FF;
            `uvm_info(get_full_name(), 
                     $sformatf("SB: MEM[0x%08h] = 0x%02h", exp_trans_local.data_addr, rs2_val[7:0]), 
                     UVM_DEBUG)
          end
          default: `uvm_error(get_full_name(), $sformatf("Unsupported S-type funct3: %b", funct3))
        endcase
      end

      default: begin
        `uvm_fatal(get_full_name(), 
                  $sformatf("Unsupported instruction opcode: 0x%02h, full instruction: 0x%08h", 
                           opcode, input_trans.instr_data))
      end
    endcase

    // Queue writeback if needed
    if (needs_writeback && rd_addr != 0) begin
      wb.rd = rd_addr;
      wb.value = result;
      wb.we = 1;
      wb.cycles_left = execution_cycles + 2; // Pipeline delay
      writeback_queue.push_back(wb);
    end

    // Send expected transaction to scoreboard
    rm2sb_port.write(exp_trans_local);
    
    `uvm_info(get_full_name(), 
             $sformatf("Processed instruction: 0x%08h", input_trans.instr_data), 
             UVM_DEBUG)
  endtask

  // Debug function to print register file state
  function void print_regfile();
    `uvm_info(get_full_name(), "=== Register File State ===", UVM_LOW)
    for (int i = 0; i < 32; i++) begin
      if (regfile[i] != 0 || i == 0) begin
        `uvm_info(get_full_name(), $sformatf("x%02d = 0x%08h", i, regfile[i]), UVM_LOW)
      end
    end
    `uvm_info(get_full_name(), "=========================", UVM_LOW)
  endfunction

endclass

`endif