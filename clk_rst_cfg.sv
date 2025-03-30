class clk_rst_cfg extends uvm_object;
	`uvm_object_utils(clk_rst_cfg)
	rand  bit [31:0] num_clks;
	rand  bit [31:0] clk_period[]; //IN TERMS OF NS
	
	constraint num_clks_cons{num_clks != 0; num_clks <= 10 ;}

	constraint clk_period_size_cons{clk_period.size() == num_clks;}

	constraint clk_period_cons {
											foreach (clk_period[i]) {
												clk_period[i] != 0;
												clk_period[i] inside {[1:100]};
												} 
											 }

function new(string name="");
super.new(name);
endfunction

endclass
