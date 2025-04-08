`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "clk_rst_test.sv"

module clk_rst_tb();
   localparam NUM_CLKS = 10;
   clk_rst_intf clk_rst_intf_inst[NUM_CLKS](.*);

   genvar clk_rst_idx;
   generate
      for (clk_rst_idx = 0; clk_rst_idx < 10; clk_rst_idx++) begin
         initial begin
            uvm_config_db#(virtual clk_rst_intf)::set(uvm_root::get(), "*", $sformatf("clk_rst_intf_%0d", clk_rst_idx), clk_rst_intf_inst[clk_rst_idx]);
         end
      end
   endgenerate

   initial begin
      static string uvm_testname = "clk_rst_test";
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
