class uvm_clk_rst_agent extends uvm_agent;
   `uvm_component_utils(uvm_clk_rst_agent)
   uvm_clk_rst_cfg cfg;
   real average_time_period[];
   real current_time[],prev_time_period[];
   shortreal avg_clk_period[], avg_jitter[],expected_avg_clk_period[],delta[],expected_delta[],delay_range[];

   int  num_posedge_clk[];
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
      uvm_clk_rst_vif     = new[cfg.num_clks];   
      average_time_period = new[cfg.num_clks];
      num_posedge_clk     = new[cfg.num_clks];
      current_time        = new[cfg.num_clks];
      prev_time_period    = new[cfg.num_clks];
      avg_clk_period      = new[cfg.num_clks];
      avg_jitter          = new[cfg.num_clks];
      expected_avg_clk_period = new[cfg.num_clks];
      delta               = new[cfg.num_clks];
      expected_delta      = new[cfg.num_clks];
      delay_range         = new[cfg.num_clks];

      for(int clk_idx = 0; clk_idx < cfg.num_clks; clk_idx++) begin
         if(!uvm_config_db#(virtual uvm_clk_rst_intf)::get(this,"",$sformatf("uvm_clk_rst_intf_%0d",clk_idx),uvm_clk_rst_vif[clk_idx]))
            `uvm_fatal(get_type_name(),"DRIVER FAILED TO GET CLK RST INTF")
      end
   endfunction

   function real generate_random_real(real min, real max);
      real random_value;
      parameter int seed_size = 10;
      bit[seed_size-1:0]   seed;
      seed = $urandom_range(0, 2**seed_size-1);
      random_value = real'(real'(min) + real'(max - min) * real'(seed) / real'(2**seed_size-1));
      //`uvm_info(get_type_name(),$sformatf("RANDOM VALUE %0f %0f %0d %f",min,max,seed,random_value),UVM_NONE)
      return random_value;
   endfunction

   function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);
      for(int clk_idx = 0; clk_idx < cfg.num_clks; clk_idx++) begin
         avg_clk_period[clk_idx]  = cfg.clk_period[clk_idx];
         delta[clk_idx]           = real'(cfg.clk_jitter[clk_idx]) * real'(cfg.clk_period[clk_idx]) /100;   
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
            reset_gen(clk_jdx,1);
         join_none
      wait fork;
   endtask

   task automatic reset_gen(int clk_idx , bit init_reset = 0);

      int count, on_delay, off_delay;
      on_delay = $urandom_range(10,100);
      //`uvm_info(get_type_name(),$sformatf("RESET ASSERTED %0d",clk_idx),UVM_NONE)
      if(cfg.sync_assertion[clk_idx] && !init_reset) begin
         //`uvm_info(get_type_name(),$sformatf("RESET ASSERTION IS SYNC %0d",clk_idx),UVM_NONE)
         @(posedge uvm_clk_rst_vif[clk_idx].clk) uvm_clk_rst_vif[clk_idx].rstN <= 0;
      end
      else begin
         //`uvm_info(get_type_name(),$sformatf("RESET ASSRTION IS ASYNC %0d",clk_idx),UVM_NONE)
         uvm_clk_rst_vif[clk_idx].rstN = 0;
      end


      if(cfg.sync_deassertion[clk_idx]) begin
         //`uvm_info(get_type_name(),$sformatf("RESET DEASSRTION IS SYNC %0d",clk_idx),UVM_NONE)
         @(posedge uvm_clk_rst_vif[clk_idx].clk) uvm_clk_rst_vif[clk_idx].rstN <= 1;
      end
      else begin
         //`uvm_info(get_type_name(),$sformatf("RESET DEASSRTION IS ASYNC %0d",clk_idx),UVM_NONE)
         #(on_delay) uvm_clk_rst_vif[clk_idx].rstN = 1;
      end

      //`uvm_info(get_type_name(),$sformatf("RESET DE-ASSERTED %0d",clk_idx),UVM_NONE)         

   endtask

   task clk_gen(int clk_idx);
      uvm_clk_rst_vif[clk_idx].clk = 0;
      forever begin
         delay_range[clk_idx]    = delta[clk_idx]/2;
         repeat(2) begin
            #(real'(real'(cfg.clk_period[clk_idx])/2) + real'(generate_random_real(-delay_range[clk_idx],delay_range[clk_idx]))) uvm_clk_rst_vif[clk_idx].clk =~uvm_clk_rst_vif[clk_idx].clk;
         end
         current_time[clk_idx] = $realtime;
         num_posedge_clk[clk_idx]++; 
         avg_clk_period[clk_idx] = real'(current_time[clk_idx]) / real'(num_posedge_clk[clk_idx]);
      end
   endtask  
   
   function void report_phase(uvm_phase phase);
     
      super.report_phase(phase);
      for(int clk_idx=0 ; clk_idx<cfg.num_clks ; clk_idx++) begin 
        avg_jitter[clk_idx] = real'((avg_clk_period[clk_idx]  - real'(cfg.clk_period[clk_idx]))/real'(cfg.clk_period[clk_idx])) * 100 ;
        `uvm_info(get_type_name(),$sformatf("CLK PERIOD MONITOR EXPECTED %f ACTUAL %f expected JITTER %0f Total JITTER %0fPercent ",cfg.clk_period[clk_idx]  ,avg_clk_period[clk_idx] ,cfg.clk_jitter[clk_idx],avg_jitter[clk_idx]),UVM_NONE)
      end
   endfunction
endclass