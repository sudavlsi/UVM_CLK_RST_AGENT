	//import Riscv_defines_tb_pkg::*;
`include "uvm_macros.svh"
import uvm_pkg::*;
class clk_rst_agent extends uvm_agent ;
`uvm_component_utils(clk_rst_agent)
  virtual clk_rst_intf clk_rst_vif[NUM_CLKS];
  int clk_period[NUM_CLKS];

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	 for(int clk_idx=0 ; clk_idx < NUM_CLKS ; clk_idx ++)	begin
    if(!uvm_config_db#(virtual clk_rst_intf)::get(this,"",$sformatf("clk_rst_intf_%0d",clk_idx),clk_rst_vif[clk_idx]))
      `uvm_fatal(get_type_name(),"DRIVER FAILED TO GET AXI MASTER INTF")
	 end 
  endfunction
 
task run_phase(uvm_phase phase);
super.run_phase(phase);
	main();
endtask

task main(); 
//fork
	for (int clk_idx=0 ; clk_idx < NUM_CLKS ; clk_idx++) 
		fork
			clk_gen(clk_idx);
			reset_gen(clk_idx);
		join
	
//join
endtask
   task automatic reset_gen(int clk_idx);
    	int count,on_delay,off_delay;
       on_delay  = $urandom_range(10,100);
     $display("SUDA RST 59");
       clk_rst_vif[clk_idx].rstN = 0;
       #(on_delay) clk_rst_vif[clk_idx].rstN = 1;
     $display("%0tSUDA RST 62",$time);
  endtask
  
//    task uart_reset_gen();
//    	int count,on_delay,off_delay;
//       on_delay  = $urandom_range(10,100);
//       clk_rst_intf.uart_rstN = 0;
//      #(on_delay) clk_rst_intf.uart_rstN = 1;
//  endtask
  
  task clk_gen(int clk_idx);
	 clk_rst_vif[clk_idx].clk = 0;
    forever #(clk_period[clk_idx]/2) clk_rst_vif[clk_idx].clk =~clk_rst_vif[clk_idx].clk;
  endtask  
//	task uart_clk_gen();
//int clk_period,skew;
//clk_period = $urandom_range(2,20);
//skew = $urandom_range(0,9);
//clk_rst_intf.uart_clk = 0;
//#(skew);
//forever #(clk_period/2) clk_rst_intf.uart_clk =~clk_rst_intf.uart_clk;
//
//
//endtask
endclass
