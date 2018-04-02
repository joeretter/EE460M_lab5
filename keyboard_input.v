module keyboard_input(sys_clk, ps2_clk, ps2_data, scancode1, scancode0, strobe_out);

input sys_clk, ps2_clk, ps2_data;
output [3:0] scancode1, scancode0;
output strobe_out;

reg strobe_out;
reg [3:0] scancode1, scancode0;
reg [21:0] shift_reg; //holds two data frames
reg [23:0] strobe_counter; //keeps track of how long the strobe light is on


initial
begin
   strobe_out = 1'b0;
   strobe_counter = 24'h000000;
end


always @(negedge ps2_clk)
begin
   shift_reg <= {ps2_data, shift_reg[21:1]}; //right shift a data bit into the register
end


always @(*) //combinational logic
begin
   if(shift_reg[8:1] == 8'hF0) //if the "key up" code has been received
   begin
      scancode1 = shift_reg[19:16]; //the first hex digit of the pressed key's scancode
      scancode0 = shift_reg[15:12]; // the second hex digit of the pressed key's scancode
      strobe_out = 1'b1; 
   end
end


always @(posedge sys_clk)
begin
   if(strobe_out)
   begin
      if(strobe_counter == 24'h989680) //keep the strobe light on until 100 ms has elapsed
      begin
         strobe_counter <= 24'h000000;
         strobe_out <= 1'b0;
      end
      else strobe_counter <= strobe_counter + 1;
   end
end

endmodule
