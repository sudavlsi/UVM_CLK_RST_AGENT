interface uvm_clk_rst_intf#( BIT_WIDTH = 1 , NUM_STAGES = 2 );
   logic clk, rstN, sync_rstN;
   logic [BIT_WIDTH - 1 : 0] sync_flop [0 : NUM_STAGES - 1];

   assign sync_rstN = sync_flop[NUM_STAGES - 1];
   
   always@(posedge clk or negedge rstN) begin
      if(!rstN) begin
         sync_flop <= '{default:{BIT_WIDTH{1'b0}}};
      end
      else begin
         sync_flop[0] <= 1;

         for(int i = 0; i < NUM_STAGES - 1; i++) begin
            sync_flop[i + 1] <= sync_flop[i];
         end
      end
   end

endinterface
