class uvm_clk_rst_agent extends uvm_agent;
   `uvm_component_utils(uvm_clk_rst_agent)
   uvm_clk_rst_cfg cfg;
   virtual uvm_clk_rst_intf uvm_clk_rst_vif[];

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      cfg = uvm_clk_rst_cfg::type_id::create("cfg");
      if(!cfg.randomize()) 
         `uvm_fatal(get_type_name(),"CLK RST CFG RANDOMIZE FAILURE")
      `uvm_info(get_type_name(),$sformatf("NUM CLKS %0d",cfg.num_clks),UVM_NONE)
      uvm_clk_rst_vif = new[cfg.num_clks];   
      for(int clk_idx = 0; clk_idx < cfg.num_clks; clk_idx++) begin
         if(!uvm_config_db#(virtual uvm_clk_rst_intf)::get(this,"",$sformatf("uvm_clk_rst_intf_%0d",clk_idx),uvm_clk_rst_vif[clk_idx]))
            `uvm_fatal(get_type_name(),"DRIVER FAILED TO GET CLK RST INTF")
      end
   endfunction

   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      main();
   endtask

   task main(); 
      for (int clk_idx = 0; clk_idx < cfg.num_clks; clk_idx++) 
         fork
            automatic int clk_jdx = clk_idx;
            clk_gen(clk_jdx);
            reset_gen(clk_jdx);
         join_none
      wait fork;
   endtask

   task automatic reset_gen(int clk_idx);
      int count, on_delay, off_delay;
      on_delay = $urandom_range(10,100);
      `uvm_info(get_type_name(),$sformatf("RESET ASSERTED %0d",clk_idx),UVM_NONE)
      uvm_clk_rst_vif[clk_idx].rstN = 0;
      #(on_delay) uvm_clk_rst_vif[clk_idx].rstN = 1;
      `uvm_info(get_type_name(),$sformatf("RESET DE-ASSERTED %0d",clk_idx),UVM_NONE)         
   endtask

   task clk_gen(int clk_idx);
      `uvm_info(get_type_name(),$sformatf("CLK PERIOD FOR CLK INST %0d %p NS",clk_idx,real'(real'(cfg.clk_period[clk_idx])/2)),UVM_NONE)
      uvm_clk_rst_vif[clk_idx].clk = 0;
      forever #(real'(real'(cfg.clk_period[clk_idx])/2)) uvm_clk_rst_vif[clk_idx].clk =~uvm_clk_rst_vif[clk_idx].clk;
   endtask  
endclass
