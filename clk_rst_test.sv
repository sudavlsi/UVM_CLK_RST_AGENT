`include "uvm_macros.svh"
import uvm_pkg::*;
import clk_rst_pkg::*;

class clk_rst_test extends uvm_test;
   `uvm_component_utils(clk_rst_test)
   clk_rst_agent agent;

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
      agent = clk_rst_agent::type_id::create("agent", this);
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
      phase.drop_objection(phase);
   endtask

endclass
