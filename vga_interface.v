module vga_top(clk,color,ps2_clk, ps2_data, vgaRed, vgaGreen, vgaBlue, Hsync, Vsync, strobe_out, a, b, c, d, e, f, g, dp, an); 
input clk; //pass in 25MHz clk "pixel clk"
input [7:0] color; //pixel color (1-7)
output [3:0] vgaRed, vgaGreen, vgaBlue; 
output Hsync, Vsync; 
wire [3:0] is_vis; 
input ps2_clk, ps2_data;
output strobe_out, a, b, c, d, e, f, g, dp;
output [3:0] an;

wire [10:0] hcount,vcount; 

keyboard_display keyboard_display_inst(clk, ps2_clk, ps2_data, strobe_out, a, b, c, d, e, f, g, dp, an); 
clk_div clk_div_inst(clk, 0, clk_25); 
vga_interface vga_interface_inst(clk_25, color, vgaRed, vgaGreen, vgaBlue, Hsync,Vsync, is_vis, hcount, vcount);

endmodule 
//vsync 494 493 dwon 495 up 
//make smaller nubmers 
////////////////////////////////////////////////////////////////////////////

module vga_interface(clk, color, R, G, B, hsync,vsync,is_vis, hcount, vcount);
input clk; //pass in 25MHz clk "pixel clk"
input [7:0] color; //pixel color (1-7)
output [3:0] R, G, B; 
output hsync, vsync; 
output [3:0] is_vis; 
output reg [10:0] hcount, vcount; 

//reg [10:0] hcount; 
//reg [10:0] vcount; 
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
  8'b00000001: begin R = 0; G = 0; B = 0; is_vis <= 0; end //black 
  
  8'b00000010: begin R = 0; G = 0; B = 255; is_vis <= 1; end //blue 
  
  8'b00000100: begin R = 139; G = 69; B = 19; is_vis <= 2; end //brown
  
  8'b00001000: begin R = 0; G = 139; B = 139; is_vis <= 3; end //cyan
  
  8'b00010000: begin R = 255; G = 0; B = 0; is_vis <= 4; end //red
  
  8'b00100000: begin R = 139; G = 0; B = 139; is_vis <= 5; end // magenta
  
  8'b01000000: begin R = 255; G = 255; B = 0; is_vis <= 6; end //yellow
  
  8'b10000000: begin R = 255; G = 255; B = 255; is_vis <= 7; end //white 
  
  default: begin R = 0; G = 0; B = 0; is_vis <= 8; end //black 
  endcase 

end 
else 
begin R = 0; G = 0; B = 0; is_vis<=0; end  

end 

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
