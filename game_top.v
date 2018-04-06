module game_top(clk, ps2_clk, ps2_data, vgaRed, vgaGreen, vgaBlue, Hsync, Vsync); 
input clk, ps2_clk, ps2_data;
output [3:0] vgaRed, vgaGreen, vgaBlue; 
output Hsync, Vsync;


//wires for unused outputs 
wire [3:0] is_vis; 

//wires for connections needed 
wire clk_25MHz, clk_5Hz; 
wire [10:0] hcount,vcount; 
wire [7:0] color; 
wire new_key_strobe; 
wire [7:0] keycode; 

//clk dividers 
clk_div_5Hz clk_div_5(clk, 0, clk_5Hz);
clk_div clk_div_inst(clk, 0, clk_25MHz); 


//keyboard TODO: change to other file  
//keyboard_display keyboard_display_inst(clk, ps2_clk, ps2_data, strobe_out, a, b, c, d, e, f, g, dp, an); 
game_keyboard game_keyboard_inst(clk, ps2_clk, ps2_data, keycode, new_key_strobe);

//game 
game_state_machine game_state_machine_inst(clk_25MHz, clk_5Hz, keycode, new_key_strobe, hcount, vcount, color);

//vga output 
vga_interface vga_interface_inst(clk_25MHz, color, vgaRed, vgaGreen, vgaBlue, Hsync,Vsync, is_vis, hcount, vcount);



endmodule 




////////////// CLK DIV MODULES ///////////////
//TODO:  clk_5Hz

/////////////////5HZ //////////////////////
module clk_div_5Hz(sys_clk, reset, clk_out_5Hz);
input sys_clk, reset;
output clk_out_5Hz;

reg [31:0] count_5Hz;
reg clk_out_5Hz;


initial
begin  
count_5Hz <= 0;
clk_out_5Hz <= 0;
end 

always @(posedge sys_clk)
begin

 
    count_5Hz <= (count_5Hz + 1) % 10000000;
    if(count_5Hz == 9999999) begin
      clk_out_5Hz <= ~clk_out_5Hz;
    
  end
end
endmodule


/////////////////25MHZ //////////////////////
module clk_div (clk, reset, clk_out);
 
input clk;
input reset;
output clk_out;
 
reg [1:0] r_reg;
wire [1:0] r_nxt;
reg clk_track;
 
initial 
 begin
  r_reg <= 3'b0;
  clk_track <= 1'b0;
 end

always @(posedge clk)
begin
   if (r_nxt == 2'b10)
 	   begin
	     r_reg <= 0;
	     clk_track <= ~clk_track;
	   end
 
  else 
      r_reg <= r_nxt;
end
 
 assign r_nxt = r_reg+1;   	      
 assign clk_out = clk_track;
endmodule


