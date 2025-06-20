`include "uvm_macros.svh"
import uvm_pkg::*;
import uvm_clk_rst_pkg::*;

class uvm_clk_rst_test extends uvm_test;
   `uvm_component_utils(uvm_clk_rst_test)
   uvm_clk_rst_agent agent;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);
      // uvm_top is a constant handle of uvm_root declared in uvm_root.svh file
      uvm_top.set_timeout(1ms / 1ps, 1);  // Override default timeout to 1 milli second
   endfunction : start_of_simulation_phase

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent = uvm_clk_rst_agent::type_id::create("agent", this);
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
   endfunction

   function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
   endfunction

   task main_phase(uvm_phase phase);
      phase.raise_objection(phase);
      super.main_phase(phase);
      `uvm_info(get_type_name(), "#######################", UVM_NONE)
      `uvm_info(get_type_name(), "main phase started", UVM_NONE)
      `uvm_info(get_type_name(), "#######################", UVM_NONE)
      uvm_top.print_topology();
      #100us;
      for(int clk_idx=0; clk_idx < agent.cfg.num_clks ; clk_idx++) begin
         agent.reset_gen(clk_idx);
      end
      #100us;
      
      phase.drop_objection(phase);
   endtask

   function void report_phase(uvm_phase phase);
      uvm_report_server server;
      super.report_phase(phase);
      server = uvm_report_server::get_server();

      if ((server.get_severity_count(UVM_FATAL) + server.get_severity_count(UVM_ERROR)) > 0) begin
         $display(" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ ");
         $display(" $$$$$$$$$       TEST FAILED       $$$$$$$ ");
         $display(" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ ");
      end else begin
         $display(" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ ");
         $display(" $$$$$$$$$       TEST PASSED       $$$$$$$ ");
         $display(" $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ ");
      end
   endfunction

endclass
