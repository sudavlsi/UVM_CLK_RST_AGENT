class uvm_clk_rst_agent extends uvm_agent;
   `uvm_component_utils(uvm_clk_rst_agent)
   uvm_clk_rst_cfg cfg;
   real average_time_period[];
   real time_period[],prev_time_period[];
   real avg_clk_period[], avg_jitter[],expected_avg_clk_period[];

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
      time_period         = new[cfg.num_clks];
      prev_time_period    = new[cfg.num_clks];
      avg_clk_period      = new[cfg.num_clks];
      avg_jitter          = new[cfg.num_clks];
      expected_avg_clk_period = new[cfg.num_clks];
      for(int clk_idx = 0; clk_idx < cfg.num_clks; clk_idx++) begin
         if(!uvm_config_db#(virtual uvm_clk_rst_intf)::get(this,"",$sformatf("uvm_clk_rst_intf_%0d",clk_idx),uvm_clk_rst_vif[clk_idx]))
            `uvm_fatal(get_type_name(),"DRIVER FAILED TO GET CLK RST INTF")
      end
   endfunction

   function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);
      for(int clk_idx = 0; clk_idx < cfg.num_clks; clk_idx++) begin
         avg_clk_period[clk_idx]          = cfg.clk_period[clk_idx];
         expected_avg_clk_period[clk_idx] = real'(cfg.clk_period[clk_idx]) + real'(cfg.clk_jitter[clk_idx] / 10 ** 6);
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
            //clk_period_monitor(clk_jdx);
         join_none
      wait fork;
   endtask

   task automatic reset_gen(int clk_idx , bit init_reset = 0);

      int count, on_delay, off_delay;
      on_delay = $urandom_range(10,100);
      `uvm_info(get_type_name(),$sformatf("RESET ASSERTED %0d",clk_idx),UVM_NONE)
      if(cfg.sync_assertion[clk_idx] && !init_reset) begin
         `uvm_info(get_type_name(),$sformatf("RESET ASSERTION IS SYNC %0d",clk_idx),UVM_NONE)
         @(posedge uvm_clk_rst_vif[clk_idx].clk) uvm_clk_rst_vif[clk_idx].rstN <= 0;
      end
      else begin
         `uvm_info(get_type_name(),$sformatf("RESET ASSRTION IS ASYNC %0d",clk_idx),UVM_NONE)
         uvm_clk_rst_vif[clk_idx].rstN = 0;
      end


      if(cfg.sync_deassertion[clk_idx]) begin
         `uvm_info(get_type_name(),$sformatf("RESET DEASSRTION IS SYNC %0d",clk_idx),UVM_NONE)
         @(posedge uvm_clk_rst_vif[clk_idx].clk) uvm_clk_rst_vif[clk_idx].rstN <= 1;
      end
      else begin
         `uvm_info(get_type_name(),$sformatf("RESET DEASSRTION IS ASYNC %0d",clk_idx),UVM_NONE)
         #(on_delay) uvm_clk_rst_vif[clk_idx].rstN = 1;
      end

      `uvm_info(get_type_name(),$sformatf("RESET DE-ASSERTED %0d",clk_idx),UVM_NONE)         

   endtask

   task clk_gen(int clk_idx);
      int  int_clk_jitter_by_2;
      real real_clk_period_by_2,real_clk_jitter_by_2;
      bit sign;
      real_clk_period_by_2 = real'(real'(cfg.clk_period[clk_idx])/2);
     
      `uvm_info(get_type_name(),$sformatf("CLK PERIOD FOR CLK INST %0d %0d NS jitter %0d",clk_idx,cfg.clk_period[clk_idx],cfg.clk_jitter[clk_idx]),UVM_NONE)
      uvm_clk_rst_vif[clk_idx].clk = 0;
      int_clk_jitter_by_2  = $urandom_range(0,cfg.clk_jitter[clk_idx]) / 2;
      forever begin
         if(expected_avg_clk_period[clk_idx] > avg_clk_period[clk_idx]) begin
            int_clk_jitter_by_2  = ((expected_avg_clk_period[clk_idx] - avg_clk_period[clk_idx])/2) * 10**6;
            int_clk_jitter_by_2  = $urandom_range(0,int_clk_jitter_by_2);
            sign = 1;
         end
         else begin
            int_clk_jitter_by_2  = ((avg_clk_period[clk_idx] - expected_avg_clk_period[clk_idx])/2) * 10**6;
            int_clk_jitter_by_2  = $urandom_range(0,int_clk_jitter_by_2);
            sign = 0;
         end
         //int_clk_jitter_by_2  = ((expected_avg_clk_period[clk_idx] - avg_clk_period[clk_idx])/2) * 10**6;
         //int_clk_jitter_by_2  = $urandom_range(0,int_clk_jitter_by_2);
         //`uvm_info(get_type_name(),$sformatf("CLK JITTER FOR CLK INST %0d sign %b",int_clk_jitter_by_2,sign),UVM_NONE)  
         //int_clk_jitter_by_2  = $urandom_range(0,int_clk_jitter_by_2);
         real_clk_jitter_by_2 = real'(int_clk_jitter_by_2) * 10**-6;
         if(sign) begin
            real_clk_jitter_by_2 = -real_clk_jitter_by_2;
         end
         //real_clk_jitter_by_2 = real'((real'(cfg.clk_jitter[clk_idx]) / real'(10**6)) * real'(cfg.clk_period[clk_idx]));
         #(real_clk_period_by_2 + real_clk_jitter_by_2) uvm_clk_rst_vif[clk_idx].clk = ~uvm_clk_rst_vif[clk_idx].clk;
         //#(real_clk_period_by_2 - real_clk_jitter_by_2) uvm_clk_rst_vif[clk_idx].clk = ~uvm_clk_rst_vif[clk_idx].clk;
         
         if(uvm_clk_rst_vif[clk_idx].clk == 1) begin
            time_period[clk_idx] = $realtime;
            if(prev_time_period[clk_idx] != 0) begin
               num_posedge_clk[clk_idx]++;
               average_time_period[clk_idx] += time_period[clk_idx] - prev_time_period[clk_idx];
            end
            prev_time_period[clk_idx] = time_period[clk_idx];
         end
         avg_clk_period[clk_idx]  = real'(real'(average_time_period[clk_idx])/real'(num_posedge_clk[clk_idx]));
         avg_jitter[clk_idx]      = real'(  avg_clk_period[clk_idx]  - real'(cfg.clk_period[clk_idx]) ) * 10**6;
      end
   endtask 

   task clk_period_monitor(int clk_idx);
      forever begin
         @(posedge uvm_clk_rst_vif[clk_idx].clk) 
            time_period[clk_idx] = $realtime;
            if(prev_time_period[clk_idx] != 0) begin
               num_posedge_clk[clk_idx]++;
               average_time_period[clk_idx] += time_period[clk_idx] - prev_time_period[clk_idx];
            end
            prev_time_period[clk_idx] = time_period[clk_idx];
      end
   endtask

   function void report_phase(uvm_phase phase);
     
      super.report_phase(phase);
      for(int clk_idx=0 ; clk_idx<cfg.num_clks ; clk_idx++) begin 
        avg_clk_period[clk_idx]  = real'(real'(average_time_period[clk_idx])/real'(num_posedge_clk[clk_idx]));
        avg_jitter[clk_idx]      = real'(  avg_clk_period[clk_idx]  - real'(cfg.clk_period[clk_idx]) ) * 10**6;
        `uvm_info(get_type_name(),$sformatf("CLK PERIOD MONITOR EXPECTED %p ACTUAL %f expected PPM %0d Total PPM %0f expected avg %f",cfg.clk_period[clk_idx]  ,avg_clk_period[clk_idx] ,cfg.clk_jitter[clk_idx],avg_jitter[clk_idx],expected_avg_clk_period[clk_idx]),UVM_NONE)
      end
   endfunction
endclass
