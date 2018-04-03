module keyboard_display(sys_clk, ps2_clk, ps2_data, strobe_out, a, b, c, d, e, f, g, dp, an);
input sys_clk, ps2_clk, ps2_data;
output strobe_out, a, b, c, d, e, f, g, dp;
output [3:0] an;

wire [4:0] bcd3, bcd2, scancode1, scancode0;
assign bcd3 = 5'h1F; //these two displays will be off
assign bcd2 = 5'h1F;

keyboard_input kbrd_in(sys_clk, ps2_clk, ps2_data, scancode1, scancode0, strobe_out);
seven_seg_display sev_seg(sys_clk, scancode0, scancode1, bcd2, bcd3, a, b, c, d, e, f, g, dp, an);

endmodule
