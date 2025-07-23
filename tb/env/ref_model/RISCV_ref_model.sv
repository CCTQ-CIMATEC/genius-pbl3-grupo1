// `ifndef RISCV_REF_MODEL 
// `define RISCV_REF_MODEL

// class RISCV_ref_model extends uvm_component;
//   `uvm_component_utils(RISCV_ref_model)

//   // Ports for input and output transactions
//   uvm_analysis_export#(RISCV_transaction) rm_export;
//   uvm_analysis_port#(RISCV_transaction) rm2sb_port;
//   uvm_tlm_analysis_fifo#(RISCV_transaction) rm_exp_fifo;

//   // Shadow register file (x0–x31, x0 always zero)
//   logic [31:0] regfile[32];

//   // Writeback pipeline entry
//   typedef struct {
//     logic [4:0]  rd;
//     logic [31:0] value;
//     bit          we;
//   } wb_info_t;

//   // 5-stage pipeline to model writeback delay
//   wb_info_t writeback_queue[5];

//   // Internal transaction handles
//   RISCV_transaction rm_trans;
//   RISCV_transaction exp_trans;

//   function new(string name = "RISCV_ref_model", uvm_component parent);
//     super.new(name, parent);
//   endfunction

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     rm_export    = new("rm_export", this);
//     rm2sb_port   = new("rm2sb_port", this);
//     rm_exp_fifo  = new("rm_exp_fifo", this);
//     // Initialize regfile and pipeline
//     foreach (regfile[i]) regfile[i] = 32'h0;
//     foreach (writeback_queue[i]) writeback_queue[i] = '{rd: 0, value: 0, we: 0};
//   endfunction

//   function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);
//     rm_export.connect(rm_exp_fifo.analysis_export);
//   endfunction

//   task run_phase(uvm_phase phase);
//     forever begin
//       // Apply writeback from the oldest entry in the queue
//       if (writeback_queue[0].we && writeback_queue[0].rd != 0) begin
//         regfile[writeback_queue[0].rd] = writeback_queue[0].value;
//       end

//       // Shift pipeline forward
//       for (int i = 0; i < 4; i++) begin
//         writeback_queue[i] = writeback_queue[i+1];
//       end
//       writeback_queue[4] = '{rd: 0, value: 0, we: 0};

//       // Wait for a new transaction
//       rm_exp_fifo.get(rm_trans);
//       process_instruction(rm_trans);
//     end
//   endtask

//   task automatic process_instruction(RISCV_transaction input_trans);
//     RISCV_transaction exp_trans_local;
//     bit [6:0] opcode;
//     bit [2:0] funct3;
//     bit [6:0] funct7;
//     bit [4:0] reg1_addr;
//     bit [4:0] reg2_addr;
//     bit [4:0] reg_dest;
//     bit [31:0] rs1, rs2;
//     bit [31:0] imm;
//     wb_info_t wb;

//     exp_trans_local = RISCV_transaction::type_id::create("exp_trans_local");
//     exp_trans_local.copy(input_trans);
//     opcode = input_trans.instr_data[6:0];
//     funct3 = input_trans.instr_data[14:12];
//     funct7 = input_trans.instr_data[31:25];
//     reg1_addr = input_trans.instr_data[19:15];
//     reg2_addr = input_trans.instr_data[24:20];
//     reg_dest = input_trans.instr_data[11:7];
//     imm = {{20{input_trans.instr_data[31]}}, input_trans.instr_data[31:20]};

//     rs1 = regfile[reg1_addr];
//     rs2 = regfile[reg2_addr];
    
//     wb = '{rd: 0, value: 0, we: 0};

//     // ADD instruction (R-type)
//     if (opcode == 7'b0110011) begin
//       exp_trans_local.data_addr = rs1 + rs2;
//       wb = '{rd: reg_dest, value: exp_trans_local.data_addr, we: 1};
//     end
//     // LW instruction (I-type)
//     else if (opcode == 7'b0000011) begin
//       // Não usa o regfile, assume rs1 = 0 (mesmo comportamento do DUT atual)
//       exp_trans_local.data_addr = imm;  // Só o imediato, igual ao que o DUT está fazendo
//       exp_trans_local.data_wr_en_ma = 0;
//       exp_trans_local.data_wr = 0;
//     end
//     // SW instruction (S-type)
//     else if (opcode == 7'b0100011) begin
//       imm = {{20{input_trans.instr_data[31]}}, input_trans.instr_data[31:25], input_trans.instr_data[11:7]};
//       exp_trans_local.data_addr = rs1 + imm;
//       exp_trans_local.data_wr  = rs2;
//       exp_trans_local.data_wr_en_ma  = 1;
//     end
//     // LUI instruction (U-type)
//     else if (opcode == 7'b0110111) begin
//       imm = {input_trans.instr_data[31:12], 12'b0};
//       wb = '{rd: reg_dest, value: imm, we: 1};
//     end
//     // AUIPC instruction (U-type)
//     else if (opcode == 7'b0010111) begin
//       imm = {input_trans.instr_data[31:12], 12'b0};
//       // Usando input_trans.pc que agora está definido na transação
//       wb = '{rd: reg_dest, value: input_trans.pc + imm, we: 1};
//     end
//     else begin
//       `uvm_warning(get_full_name(), $sformatf("Unsupported instruction: 0x%h", input_trans.instr_data));
//     end

//     writeback_queue[4] = wb;
//     rm2sb_port.write(exp_trans_local);
//   endtask

// endclass

// `endif

// `ifndef RISCV_REF_MODEL
// `define RISCV_REF_MODEL

// class RISCV_ref_model extends uvm_component;
//   `uvm_component_utils(RISCV_ref_model)

//   uvm_analysis_export#(RISCV_transaction) rm_export;
//   uvm_analysis_port#(RISCV_transaction) rm2sb_port;
//   uvm_tlm_analysis_fifo#(RISCV_transaction) rm_exp_fifo;

//   // Shadow register file and memory state
//   logic [31:0] regfile[32];
//   logic [31:0] dmem[1024];  // Data memory model
//   int unsigned instruction_count = 0;
  
//   function new(string name = "RISCV_ref_model", uvm_component parent);
//     super.new(name, parent);
//     foreach(regfile[i]) regfile[i] = 0;
//     foreach(dmem[i]) dmem[i] = 0;
//   endfunction

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     rm_export = new("rm_export", this);
//     rm2sb_port = new("rm2sb_port", this);
//     rm_exp_fifo = new("rm_exp_fifo", this);
//   endfunction

//   function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);
//     rm_export.connect(rm_exp_fifo.analysis_export);
//   endfunction

//   task run_phase(uvm_phase phase);
//     forever begin
//       RISCV_transaction tr;
//       rm_exp_fifo.get(tr);
//       instruction_count++;
//       process_instruction(tr);
//     end
//   endtask

//   task process_instruction(RISCV_transaction tr);
//     RISCV_transaction exp_tr = RISCV_transaction::type_id::create("exp_tr");
//     bit [6:0] opcode = tr.instr_data[6:0];
//     bit [2:0] funct3 = tr.instr_data[14:12];
//     bit [4:0] rs1 = tr.instr_data[19:15];
//     bit [4:0] rs2 = tr.instr_data[24:20];
//     bit [11:0] imm = {tr.instr_data[31:25], tr.instr_data[11:7]};
    
//     exp_tr.copy(tr);
    
//     case(opcode)
//       7'b0100011: begin // Store instructions
//         if (rs1 == 0 || rs2 == 0) begin
//           `uvm_warning(get_type_name(),
//             $sformatf("Invalid register x0 used in store instruction [0x%08h]", tr.instr_data))
//           exp_tr.data_wr_en_ma = 1'b0;
//         end
//         else begin
//           case(funct3)
//             3'b010: begin // SW
//               exp_tr.data_wr_en_ma = 1'b1;
//               exp_tr.data_addr = regfile[rs1] + {{20{imm[11]}}, imm};
//               exp_tr.data_wr = regfile[rs2];
              
//               // Update memory model
//               if (exp_tr.data_addr[1:0] != 0) begin
//                 `uvm_error(get_type_name(),
//                   $sformatf("Unaligned SW address: 0x%08h", exp_tr.data_addr))
//               end
//               else begin
//                 dmem[exp_tr.data_addr[31:2]] = exp_tr.data_wr;
//               end
              
//               `uvm_info(get_type_name(), 
//                 $sformatf("SW Model: addr=0x%08h, data=0x%08h, reg[x%0d]=0x%08h", 
//                 exp_tr.data_addr, exp_tr.data_wr, rs1, regfile[rs1]), UVM_HIGH)
//             end
            
//             default: begin
//               `uvm_warning(get_type_name(), 
//                 $sformatf("Unsupported store type funct3=%0d [0x%08h]", funct3, tr.instr_data))
//               exp_tr.data_wr_en_ma = 1'b0;
//             end
//           endcase
//         end
//       end
      
//       // Add other instruction types here as needed
      
//       default: begin
//         `uvm_warning(get_type_name(), 
//           $sformatf("Unsupported opcode: 0x%02h [0x%08h]", opcode, tr.instr_data))
//       end
//     endcase
    
//     // Add instruction metadata
//     exp_tr.instr_name = get_instr_name(tr.instr_data);
//     rm2sb_port.write(exp_tr);
//   endtask

//   // Helper function to get instruction name
//   function string get_instr_name(bit [31:0] instr);
//     case (instr[6:0])
//       7'b0100011: begin // Store
//         case (instr[14:12])
//           3'b010: return $sformatf("SW x%0d, %0d(x%0d)", 
//                    instr[24:20], $signed({instr[31:25], instr[11:7]}), instr[19:15]);
//           default: return "UNKNOWN_STORE";
//         endcase
//       end
//       default: return "UNKNOWN";
//     endcase
//   endfunction

//   function void report_phase(uvm_phase phase);
//     `uvm_info(get_type_name(),
//       $sformatf("Reference Model executed %0d instructions", instruction_count), UVM_LOW)
//   endfunction

// endclass

// `endif

//------------------------------------------------------------------------------
// Reference model module for RISCV
//------------------------------------------------------------------------------
// This module defines the reference model for the RISCV verification.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

// `ifndef RISCV_REF_MODEL 
// `define RISCV_REF_MODEL

// class RISCV_ref_model extends uvm_component;
//   `uvm_component_utils(RISCV_ref_model)

//   // Ports for input and output transactions
//   uvm_analysis_export#(RISCV_transaction) rm_export;
//   uvm_analysis_port#(RISCV_transaction) rm2sb_port;
//   uvm_tlm_analysis_fifo#(RISCV_transaction) rm_exp_fifo;

//   // Shadow register file (x0–x31, x0 always zero)
//   logic [31:0] regfile[32];

//   // Writeback pipeline entry
//   typedef struct {
//     logic [4:0]  rd;
//     logic [31:0] value;
//     bit          we;
//   } wb_info_t;

//   // 5-stage pipeline to model writeback delay
//   wb_info_t writeback_queue[5];

//   // Internal transaction handles
//   RISCV_transaction rm_trans;
//   RISCV_transaction exp_trans;

//   function new(string name = "RISCV_ref_model", uvm_component parent);
//     super.new(name, parent);
//   endfunction

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     rm_export    = new("rm_export", this);
//     rm2sb_port   = new("rm2sb_port", this);
//     rm_exp_fifo  = new("rm_exp_fifo", this);
//     // Initialize regfile and pipeline
//     foreach (regfile[i]) regfile[i] = 32'h0;
//     foreach (writeback_queue[i]) writeback_queue[i] = '{rd: 0, value: 0, we: 0};
//   endfunction

//   function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);
//     rm_export.connect(rm_exp_fifo.analysis_export);
//   endfunction

//   task run_phase(uvm_phase phase);
//     forever begin
//       // Apply writeback from the oldest entry in the queue
//       if (writeback_queue[0].we && writeback_queue[0].rd != 0) begin
//         regfile[writeback_queue[0].rd] = writeback_queue[0].value;
//       end

//       // Shift pipeline forward
//       for (int i = 0; i < 4; i++) begin
//         writeback_queue[i] = writeback_queue[i+1];
//       end
//       writeback_queue[4] = '{rd: 0, value: 0, we: 0};

//       // Wait for a new transaction
//       rm_exp_fifo.get(rm_trans);
//       process_instruction(rm_trans);
//     end
//   endtask

//   task automatic process_instruction(RISCV_transaction input_trans);
//   RISCV_transaction exp_trans_local;
//   bit [6:0] opcode;
//   bit [2:0] funct3;
//   bit [6:0] funct7;
//   bit [4:0] reg1_addr;
//   bit [4:0] reg2_addr;
//   bit [4:0] reg_dest;
//   bit [31:0] rs1, rs2;
//   bit [31:0] imm;
//   wb_info_t wb;

//   exp_trans_local = RISCV_transaction::type_id::create("exp_trans_local");
//   exp_trans_local.copy(input_trans);
//   opcode = input_trans.instr_data[6:0];
//   funct3 = input_trans.instr_data[14:12];
//   funct7 = input_trans.instr_data[31:25];
//   reg1_addr = input_trans.instr_data[19:15];
//   reg2_addr = input_trans.instr_data[24:20];
//   reg_dest = input_trans.instr_data[11:7];
//   imm = {{20{input_trans.instr_data[31]}}, input_trans.instr_data[31:20]};

//   rs1 = regfile[reg1_addr];
//   rs2 = regfile[reg2_addr];
  
//   wb = '{rd: 0, value: 0, we: 0};

//   // ADD instruction (R-type)
//   if (opcode == 7'b0110011) begin
//     exp_trans_local.data_addr = rs1 + rs2;
//     wb = '{rd: reg_dest, value: exp_trans_local.data_addr, we: 1};
//   end
//   // LW instruction (I-type)
//   else if (opcode == 7'b0000011) begin
//     // Não usa o regfile, assume rs1 = 0 (mesmo comportamento do DUT atual)
//     exp_trans_local.data_addr = imm;  // Só o imediato, igual ao que o DUT está fazendo
//     exp_trans_local.data_wr_en_ma = 0;
//     exp_trans_local.data_wr = 0;
//   end
//   // SW instruction (S-type)
//   else if (opcode == 7'b0100011 ) begin
//     imm = {{20{input_trans.instr_data[31]}}, input_trans.instr_data[31:25], input_trans.instr_data[11:7]};
//     exp_trans_local.data_addr = rs1 + imm;
//     exp_trans_local.data_wr  = rs2;
//     exp_trans_local.data_wr_en_ma  = 1;
//   end
//   else begin
//     `uvm_warning(get_full_name(), $sformatf("Unsupported instruction: 0x%h", input_trans.instr_data));
//   end

//   writeback_queue[4] = wb;
//   rm2sb_port.write(exp_trans_local);
// endtask

// endclass

// `endif


// ------------------------------------------------------------------------------

// `ifndef RISCV_REF_MODEL 
// `define RISCV_REF_MODEL

// class RISCV_ref_model extends uvm_component;
//   `uvm_component_utils(RISCV_ref_model)

//   // Ports for input and output transactions
//   uvm_analysis_export#(RISCV_transaction) rm_export;
//   uvm_analysis_port#(RISCV_transaction) rm2sb_port;
//   uvm_tlm_analysis_fifo#(RISCV_transaction) rm_exp_fifo;

//   // Shadow register file (x0–x31, x0 always zero)
//   logic [31:0] regfile[32];

//   // Writeback pipeline entry
//   typedef struct {
//     logic [4:0]  rd;
//     logic [31:0] value;
//     bit          we;
//   } wb_info_t;

//   // 5-stage pipeline to model writeback delay
//   wb_info_t writeback_queue[5];

//   // Internal transaction handles
//   RISCV_transaction rm_trans;
//   RISCV_transaction exp_trans;

//   function new(string name = "RISCV_ref_model", uvm_component parent);
//     super.new(name, parent);
//   endfunction

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     rm_export    = new("rm_export", this);
//     rm2sb_port   = new("rm2sb_port", this);
//     rm_exp_fifo  = new("rm_exp_fifo", this);
//     // Initialize regfile and pipeline
//     foreach (regfile[i]) regfile[i] = 32'h0;
//     foreach (writeback_queue[i]) writeback_queue[i] = '{rd: 0, value: 0, we: 0};
//   endfunction

//   function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);
//     rm_export.connect(rm_exp_fifo.analysis_export);
//   endfunction

//   task run_phase(uvm_phase phase);
//     forever begin
//       // Apply writeback from the oldest entry in the queue
//       if (writeback_queue[0].we && writeback_queue[0].rd != 0) begin
//         regfile[writeback_queue[0].rd] = writeback_queue[0].value;
//       end

//       // Shift pipeline forward
//       for (int i = 0; i < 4; i++) begin
//         writeback_queue[i] = writeback_queue[i+1];
//       end
//       writeback_queue[4] = '{rd: 0, value: 0, we: 0};

//       // Wait for a new transaction
//       rm_exp_fifo.get(rm_trans);
//       process_instruction(rm_trans);
//     end
//   endtask

//   task automatic process_instruction(RISCV_transaction input_trans);
//     RISCV_transaction exp_trans_local;
//     bit [6:0] opcode;
//     bit [2:0] funct3;
//     bit [6:0] funct7;
//     bit [4:0] reg1_addr;
//     bit [4:0] reg2_addr;
//     bit [4:0] reg_dest;
//     bit [31:0] rs1, rs2;
//     bit [31:0] imm;
//     wb_info_t wb;

//     exp_trans_local = RISCV_transaction::type_id::create("exp_trans_local");
//     exp_trans_local.copy(input_trans);
//     opcode = input_trans.instr_data[6:0];
//     funct3 = input_trans.instr_data[14:12];
//     funct7 = input_trans.instr_data[31:25];
//     reg1_addr = input_trans.instr_data[19:15];
//     reg2_addr = input_trans.instr_data[24:20];
//     reg_dest = input_trans.instr_data[11:7];
//     imm = {{20{input_trans.instr_data[31]}}, input_trans.instr_data[31:20]};

//     rs1 = regfile[reg1_addr];
//     rs2 = regfile[reg2_addr];
    
//     wb = '{rd: 0, value: 0, we: 0};

//     // ADD instruction (R-type)
//     if (opcode == 7'b0110011) begin
//       exp_trans_local.data_addr = rs1 + rs2;
//       wb = '{rd: reg_dest, value: exp_trans_local.data_addr, we: 1};
//     end
//     // LW instruction (I-type)
//     else if (opcode == 7'b0000011) begin
//       // Não usa o regfile, assume rs1 = 0 (mesmo comportamento do DUT atual)
//       exp_trans_local.data_addr = imm;  // Só o imediato, igual ao que o DUT está fazendo
//       exp_trans_local.data_wr_en_ma = 0;
//       exp_trans_local.data_wr = 0;
//     end
//     // SW instruction (S-type)
//     else if (opcode == 7'b0100011) begin
//       imm = {{20{input_trans.instr_data[31]}}, input_trans.instr_data[31:25], input_trans.instr_data[11:7]};
//       exp_trans_local.data_addr = rs1 + imm;
//       exp_trans_local.data_wr  = rs2;
//       exp_trans_local.data_wr_en_ma  = 1;
//     end
//     // LUI instruction (U-type)
//     else if (opcode == 7'b0110111) begin
//       imm = {input_trans.instr_data[31:12], 12'b0};
//       wb = '{rd: reg_dest, value: imm, we: 1};
//     end
//     // AUIPC instruction (U-type)
//     else if (opcode == 7'b0010111) begin
//       imm = {input_trans.instr_data[31:12], 12'b0};
//       // Usando input_trans.pc que agora está definido na transação
//       wb = '{rd: reg_dest, value: input_trans.pc + imm, we: 1};
//     end
//     else begin
//       `uvm_warning(get_full_name(), $sformatf("Unsupported instruction: 0x%h", input_trans.instr_data));
//     end

//     writeback_queue[4] = wb;
//     rm2sb_port.write(exp_trans_local);
//   endtask

// endclass

// `endif



//------------------------------------------------------------------------------
// Reference model module for RISCV
//------------------------------------------------------------------------------
// This module defines the reference model for the RISCV verification.
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
  
  // Program counter
  logic [31:0] pc;

  // Writeback pipeline entry
  typedef struct {
    logic [4:0]  rd;
    logic [31:0] value;
    bit          we;
  } wb_info_t;

  // 5-stage pipeline to model writeback delay
  wb_info_t writeback_queue[5];

  // Internal transaction handles
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
    // Initialize regfile and pipeline
    foreach (regfile[i]) regfile[i] = 32'h0;
    foreach (writeback_queue[i]) writeback_queue[i] = '{rd: 0, value: 0, we: 0};
    pc = 32'h0;
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rm_export.connect(rm_exp_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      // Apply writeback from the oldest entry in the queue

      pc = pc + 4;      
      
      if (writeback_queue[0].we && writeback_queue[0].rd != 0) begin
          `uvm_info(get_full_name(), $sformatf("\n\n Writing back: x%0d = 0x%08x\n\n", 
                    writeback_queue[0].rd, writeback_queue[0].value), UVM_MEDIUM)
        regfile[writeback_queue[0].rd] = writeback_queue[0].value;
      end

      // Shift pipeline forward
      for (int i = 0; i < 4; i++) begin
        writeback_queue[i] = writeback_queue[i+1];
      end
      writeback_queue[4] = '{rd: 0, value: 0, we: 0};

      // Wait for a new transaction
      rm_exp_fifo.get(rm_trans);
      process_instruction(rm_trans);
    end
  endtask

  task automatic process_instruction(RISCV_transaction input_trans);
    RISCV_transaction exp_trans_local;
    bit [6:0] opcode;
    bit [2:0] funct3;
    bit [6:0] funct7;
    bit [4:0] reg1_addr;
    bit [4:0] reg2_addr;
    bit [4:0] reg_dest;
    bit [31:0] rs1, rs2;
    bit [31:0] imm_i, imm_s, imm_sb, imm_u, imm_uj;
    bit [31:0] result;
    bit [31:0] mem_addr;
    bit        branch_taken;
    wb_info_t wb;

    exp_trans_local = RISCV_transaction::type_id::create("exp_trans_local");
    exp_trans_local.copy(input_trans);
    
    // Decode instruction fields
    opcode    = input_trans.instr_data[6:0];
    funct3    = input_trans.instr_data[14:12];
    funct7    = input_trans.instr_data[31:25];
    reg1_addr = input_trans.instr_data[19:15];
    reg2_addr = input_trans.instr_data[24:20];
    reg_dest  = input_trans.instr_data[11:7];

    // Get register values
    rs1 = (reg1_addr == 0) ? 32'h0 : regfile[reg1_addr];
    rs2 = (reg2_addr == 0) ? 32'h0 : regfile[reg2_addr];
    
    // Decode immediate values for different instruction types
    imm_i   = {{20{input_trans.instr_data[31]}}, input_trans.instr_data[31:20]};
    imm_s   = {{20{input_trans.instr_data[31]}}, input_trans.instr_data[31:25], input_trans.instr_data[11:7]};
    imm_sb  = {{19{input_trans.instr_data[31]}}, input_trans.instr_data[31], input_trans.instr_data[7], input_trans.instr_data[30:25], input_trans.instr_data[11:8], 1'b0};
    imm_u   = {input_trans.instr_data[31:12], 12'h0};
    imm_uj  = {{11{input_trans.instr_data[31]}}, input_trans.instr_data[31], input_trans.instr_data[19:12], input_trans.instr_data[20], input_trans.instr_data[30:21], 1'b0};
    
    // Initialize writeback info
    wb = '{rd: 0, value: 0, we: 0};
    branch_taken = 0;
    
    // Initialize memory interface defaults
    exp_trans_local.data_wr_en_ma = 0;
    exp_trans_local.data_wr = 0;

    case (opcode)
      // R-type instructions (0110011)
      7'b0110011: begin
        wb.rd = reg_dest;
        wb.we = 1;
        case (funct3)
          3'b000: begin // ADD/SUB
            if (funct7 == 7'b0000000) wb.value = rs1 + rs2;        // ADD
            else if (funct7 == 7'b0100000) wb.value = rs1 - rs2;   // SUB
          end
          3'b001: wb.value = rs1 << rs2[4:0];                      // SLL
          3'b100: wb.value = rs1 ^ rs2;                            // XOR
          3'b101: begin // SRL/SRA
            if (funct7 == 7'b0000000) wb.value = rs1 >> rs2[4:0];          // SRL
            else if (funct7 == 7'b0100000) wb.value = $signed(rs1) >>> rs2[4:0]; // SRA
          end
          3'b110: wb.value = rs1 | rs2;                            // OR
          3'b111: wb.value = rs1 & rs2;                            // AND
        endcase
        exp_trans_local.data_addr = wb.value;
      end

      // I-type Load instructions (0000011)
      7'b0000011: begin
        mem_addr = rs1 + imm_i;
        exp_trans_local.data_addr = mem_addr;
        exp_trans_local.data_wr_en_ma = 0;
        wb.rd = reg_dest;
        wb.we = 1;
        case (funct3)
          3'b000: wb.value = {{24{exp_trans_local.data_rd[7]}}, exp_trans_local.data_rd[7:0]};   // LB (sign-extend byte)
          3'b001: wb.value = {{16{exp_trans_local.data_rd[15]}}, exp_trans_local.data_rd[15:0]}; // LH (sign-extend halfword)
          3'b010: wb.value = exp_trans_local.data_rd;                                            // LW (full word)
          3'b100: wb.value = {24'h0, exp_trans_local.data_rd[7:0]};                             // LBU (zero-extend byte)
          3'b101: wb.value = {16'h0, exp_trans_local.data_rd[15:0]};                            // LHU (zero-extend halfword)
        endcase
      end

      // I-type ALU instructions (0010011)
      7'b0010011: begin
        wb.rd = reg_dest;
        wb.we = 1;
        case (funct3)
          3'b000: wb.value = rs1 + imm_i;                                    // ADDI
          3'b001: wb.value = rs1 << imm_i[4:0];                             // SLLI
          3'b100: wb.value = rs1 ^ imm_i;                                    // XORI
          3'b101: begin // SRLI/SRAI
            if (funct7 == 7'b0000000) wb.value = rs1 >> imm_i[4:0];                // SRLI
            else if (funct7 == 7'b0100000) wb.value = $signed(rs1) >>> imm_i[4:0]; // SRAI
          end
          3'b110: wb.value = rs1 | imm_i;                                    // ORI
          3'b111: wb.value = rs1 & imm_i;                                    // ANDI
        endcase
        exp_trans_local.data_addr = wb.value;
      end

      // I-type JALR instruction (1100111)
      7'b1100111: begin
        wb.rd = reg_dest;
        wb.we = 1;
        wb.value = pc + 4;  // Return address
        pc = (rs1 + imm_i) & ~32'h1; // Jump target (clear LSB)
        exp_trans_local.data_addr = wb.value;
      end

      // S-type Store instructions (0100011)
      7'b0100011: begin
        mem_addr = rs1 + imm_s;
        exp_trans_local.data_addr = mem_addr;
        exp_trans_local.data_wr_en_ma = 1;
        case (funct3)
          3'b000: exp_trans_local.data_wr = {24'h0, rs2[7:0]};   // SB
          3'b001: exp_trans_local.data_wr = {16'h0, rs2[15:0]};  // SH
          3'b010: exp_trans_local.data_wr = rs2;                 // SW
        endcase
      end

      // SB-type Branch instructions (1100011)
      7'b1100011: begin
        case (funct3)
          3'b000: branch_taken = (rs1 == rs2);                                    // BEQ
          3'b001: branch_taken = (rs1 != rs2);                                    // BNE
          3'b100: branch_taken = ($signed(rs1) < $signed(rs2));                  // BLT
          3'b101: branch_taken = ($signed(rs1) >= $signed(rs2));                 // BGE
          3'b110: branch_taken = (rs1 < rs2);                                     // BLTU (unsigned)
          3'b111: branch_taken = (rs1 >= rs2);                                   // BGEU (unsigned)
        endcase
        if (branch_taken) pc = pc + imm_sb;
        else pc = pc + 4;
        exp_trans_local.data_addr = pc;
      end

      // U-type LUI instruction (0110111)
      7'b0110111: begin
        wb.rd = reg_dest;
        wb.we = 1;
        wb.value = imm_u;  // Load Upper Immediate
        exp_trans_local.data_addr = wb.value;
      end

      // U-type AUIPC instruction (0010111)
      7'b0010111: begin
        wb.rd = reg_dest;
        wb.we = 1;
        wb.value = input_trans.pc + imm_u;  // Add Upper Immediate to PC
        exp_trans_local.data_addr = wb.value;
      end

      // UJ-type JAL instruction (1101111)
      7'b1101111: begin
        wb.rd = reg_dest;
        wb.we = 1;
        wb.value = pc + 4;  // Return address
        pc = pc + imm_uj;   // Jump target
        exp_trans_local.data_addr = wb.value;
      end

      default: begin
        `uvm_fatal(get_full_name(), $sformatf("\nUnsupported instruction opcode: 0x%h (full instruction: 0x%h)\n", opcode, input_trans.instr_data));
      end
    endcase

    // Queue the writeback operation
    writeback_queue[0] = wb;
    
    // Send expected transaction to scoreboard
    rm2sb_port.write(exp_trans_local);
  endtask

  // Helper function to sign-extend values
  function automatic logic [31:0] sign_extend(logic [31:0] value, int width);
    case (width)
      8:  return {{24{value[7]}}, value[7:0]};
      16: return {{16{value[15]}}, value[15:0]};
      default: return value;
    endcase
  endfunction

endclass

`endif