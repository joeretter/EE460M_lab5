//Pressing the keys on the keyboard changes the color of the vga screen as follows:
//esc key makes the screen black
//s key makes the screen blue
//p key makes the screen brown
//r key makes the screen cyan
//up arrow key makes the screen red
//right arrow key makes the screen magenta
//down arrow key makes the screen yellow
//left arrow key makes the screen white
//These are all the keys used in the snake game
module vga_with_keyboard_input(sys_clk, ps2_clk, ps2_data, vgaRed, vgaGreen, vgaBlue, Hsync, Vsync, is_vis);
input sys_clk, ps2_clk, ps2_data;
output [3:0] vgaRed, vgaGreen, vgaBlue; 
output Hsync, Vsync; 
output [3:0] is_vis; 
wire [10:0] hcount,vcount; 

wire [4:0] scancode1, scancode0;
wire strobe_light;
wire [7:0] color;

assign color = {scancode1[3:0], scancode0[3:0]}; //color is the two hex digits corresponding to the key that was pressed

keyboard_input kbrd(sys_clk, ps2_clk, ps2_data, scancode1, scanconde0, strobe_light);
//vga_top vga_display(sys_clk, color, vgaRed, vgaGreen, vgaBlue, Hsync, Vsync, is_vis, hcount, vcount);
clk_div clk_div_inst(clk, 0, clk_25); 
vga_interface vga_interface_inst(clk_25, color, vgaRed, vgaGreen, vgaBlue, Hsync,Vsync, is_vis,hcount, vcount);

endmodule




//this is the original keyboard input module
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


//below is the original vga code EXCEPT the color case statment is modified to work with the keyboard
//vsync 494 493 dwon 495 up 
//make smaller nubmers 
////////////////////////////////////////////////////////////////////////////

module vga_interface(clk, color, R, G, B, hsync,vsync,is_vis, hcount, vcount);
input clk; //pass in 25MHz clk "pixel clk"
input [7:0] color; //pixel color (1-7)
output [3:0] R, G, B; 
output hsync, vsync; 
output [3:0] is_vis; 
output reg [10:0] hcount,vcount; 


reg hsync, vsync; 
reg [3:0] R, G, B; 
reg [3:0] is_vis; 
//reg vis; //=1 when visible , = 0 when not visible  

initial 
begin 
hcount <=0; 
vcount <=0; 
hsync <=0; 
vsync <=0; 
is_vis <=0; 
end 

always @(posedge clk)
begin 
//horiz
if(hcount == 10'd799) begin hcount <=0; vcount <= vcount +1;end //hcount reach end of row -> inc vcount, reset hcount 10'd799
else begin hcount <= hcount +1; end 
//vert
if(vcount == 10'd524) begin vcount <= 0; end //vcount reached end of pg reset 10'd524


//hsync, vsync 
if((hcount< 658) || (hcount> 754)) hsync <= 1; //658, 754
else hsync <= 0; 

if((vcount< 492) || (vcount> 493)) vsync <= 1; // 492, 493
else vsync <= 0; 

//visible range output R G B values 
if((hcount <= 640) && (vcount <= 480)) //640, 480
begin 

  case (color)
  8'h76: begin R = 0; G = 0; B = 0; is_vis <= 0; end //black, esc key
  
  8'h1B: begin R = 0; G = 0; B = 255; is_vis <= 1; end //blue, s key
  
  8'h4D: begin R = 165; G = 42; B = 42; is_vis <= 2; end //brown, p key
  
  8'h2D: begin R = 0; G = 139; B = 139; is_vis <= 3; end //cyan, r key
  
  8'h75: begin R = 255; G = 0; B = 0; is_vis <= 4; end //red, up arrow
  
  8'h74: begin R = 139; G = 0; B = 139; is_vis <= 5; end // magenta, right arrow
  
  8'h72: begin R = 255; G = 255; B = 0; is_vis <= 6; end //yellow, down arrow
  
  8'h6B: begin R = 255; G = 255; B = 255; is_vis <= 7; end //white, left arrow 
  
  default: begin R = 0; G = 0; B = 0; is_vis <= 8; end //black 
  endcase 

end 
else 
begin R = 0; G = 0; B = 0; is_vis<=0; end  

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

////////////////////////////////////////////////////////////////////////////

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


