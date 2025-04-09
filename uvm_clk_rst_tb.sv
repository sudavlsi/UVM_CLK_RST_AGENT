`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uvm_clk_rst_test.sv"

module uvm_clk_rst_tb();
   localparam NUM_CLKS = 10;
   uvm_clk_rst_intf uvm_clk_rst_intf_inst[NUM_CLKS](.*);

   genvar uvm_clk_rst_idx;
   generate
      for (uvm_clk_rst_idx = 0; uvm_clk_rst_idx < 10; uvm_clk_rst_idx++) begin
         initial begin
            uvm_config_db#(virtual uvm_clk_rst_intf)::set(uvm_root::get(), "*", $sformatf("uvm_clk_rst_intf_%0d", uvm_clk_rst_idx), uvm_clk_rst_intf_inst[uvm_clk_rst_idx]);
         end
      end
   endgenerate

   initial begin
      static string uvm_testname = "uvm_clk_rst_test";
      void'($value$plusargs("+UVM_TESTNAME=%0s", uvm_testname));
      run_test(uvm_testname);
   end

   initial begin
      if ($test$plusargs("DUMP_VCD")) begin
         $dumpfile("run_last/wave.vcd");
         $dumpvars;
      end
   end
endmodule
