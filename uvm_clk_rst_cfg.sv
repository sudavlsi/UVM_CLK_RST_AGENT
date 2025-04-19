class uvm_clk_rst_cfg extends uvm_object;
   `uvm_object_utils(uvm_clk_rst_cfg)
   rand  bit [31:0] num_clks;
   rand  bit [31:0] clk_period[]; //IN TERMS OF NS
   rand  bit        sync_deassertion[],sync_assertion[];
   rand  bit [31:0] clk_jitter[]; //IN TERMS OF PPM
   
   constraint num_clks_cons { num_clks != 0; num_clks <= 1; }

   constraint clk_period_size_cons { clk_period.size()       == num_clks; 
                                     sync_deassertion.size() == num_clks;
                                     sync_assertion.size()   == num_clks;
                                     clk_jitter.size()       == num_clks;
                                   }

   constraint clk_period_cons {
      foreach (clk_period[i]) {
         clk_period[i] != 0;
         clk_period[i] inside {[10:10]};
         clk_jitter[i] inside {[100:300]};
      }
   }

   function new(string name="");
      super.new(name);
   endfunction

endclass
