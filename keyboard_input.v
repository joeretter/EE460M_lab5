module keyboard_input(sys_clk, ps2_clk, ps2_data, scancode1, scancode0, strobe_out);

input sys_clk, ps2_clk, ps2_data;
output [4:0] scancode1, scancode0;
output strobe_out;

reg strobe_out, strobing;
reg [4:0] scancode1, scancode0;
reg [21:0] shift_reg; //holds two data frames
reg [23:0] strobe_counter; //keeps track of how long the strobe light is on

single_pulse strobe_pulser(sys_clk, strobing, strobing_pulse);


initial
begin
   strobe_out = 1'b0;
   strobe_counter = 24'h000000;
   strobing = 1'b0;
   scancode1 = 5'h1F;
   scancode0 = 5'h1F;
end


always @(negedge ps2_clk)
begin
   shift_reg <= {ps2_data, shift_reg[21:1]}; //right shift a data bit into the register
end

always @(posedge ps2_clk)
begin
   if(shift_reg[8:1] == 8'hF0) //if the "key up" code has been received
   begin
      scancode1 <= {1'b0, shift_reg[19:16]}; //the first hex digit of the pressed key's scancode
      scancode0 <= {1'b0, shift_reg[15:12]}; // the second hex digit of the pressed key's scancode
      strobing <= 1'b1; 
   end
   else
   begin 
      scancode1 <= scancode1;
      scancode0 <= scancode0;
      strobing <= 1'b0;
   end
end


always @(posedge sys_clk)
begin
   if(strobing_pulse) strobe_counter <= 24'h989680; //100 ms worth of counts
   else if(strobe_counter != 24'h000000) 
   begin
       strobe_counter <= strobe_counter - 1;
       strobe_out <= 1'b1;
   end
   else strobe_out <= 1'b0;
end

endmodule
