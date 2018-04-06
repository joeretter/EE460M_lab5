module game_keyboard(sys_clk, ps2_clk, ps2_data, keycode, strobe_out);

input sys_clk, ps2_clk, ps2_data;
output [7:0] keycode;
output strobe_out;

wire [4:0] key_code1, key_code0;

keyboard_input keyboard(sys_clk, ps2_clk, ps2_data, key_code1, key_code0, strobe_out);
assign keycode = {key_code1[3:0], key_code0[3:0]};

endmodule


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

module AND(a, b, out);
input a, b;
output out;

assign out = a & b;

endmodule

module DFF(clk, d, q, q_bar);
input clk, d;
output q, q_bar;

reg q, q_bar;

always @(posedge clk)
begin
  q <= d;
  q_bar <= ~d;
end

endmodule


module debounce(clk, D, SYNCPRESS);
input clk, D;
output SYNCPRESS;

DFF flop1(clk, D, flop1_Q, unused1);
DFF flop2(clk, flop1_Q, SYNCPRESS, unused2);

endmodule


module single_pulse(clk, press, SP);
input clk, press;
output SP;

debounce debouncer(clk, press, sync_press);
DFF flip_flop(clk, sync_press, unused, q_bar);
AND and_gate(sync_press, q_bar, SP);

endmodule
