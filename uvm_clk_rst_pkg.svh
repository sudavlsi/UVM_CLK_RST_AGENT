`ifndef CLK_RST_PKG
   `define CLK_RST_PKG
   package uvm_clk_rst_pkg;
      timeunit 1ns;
      timeprecision 1ns;
      import uvm_pkg::*;
      `include "uvm_macros.svh"
      `include "uvm_clk_rst_cfg.sv"
      `include "uvm_clk_rst_agent.sv"
   endpackage
`endif
