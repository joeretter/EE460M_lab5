module vga_interface(clk, color, R, G, B, hsync,vsync );
input clk; //pass in 25MHz clk "pixel clk"
input [2:0] color; //pixel color (1-7)
output [7:0] R, G, B; 
output hsync, vsync; 

reg [10:0] hcount; 
reg [10:0] vcount; 
reg hsync, vsync; 
reg [7:0] R, G, B; 
//reg vis; //=1 when visible , = 0 when not visible  

initial 
begin 
hcount <=0; 
vcount <=0; 
hsync <=0; 
vsync <=0; 
//vis <=0; 
end 

always @(posedge clk)
begin 
//horiz
if(hcount == 10'd799) begin hcount <=0; vcount <= vcount +1;end //hcount reach end of row -> inc vcount, reset hcount 
else begin hcount <= hcount +1; end 
//vert
if(vcount == 10'd524) begin vcount <= 0; end //vcount reached end of pg reset 
else begin vcount <= vcount; end 

//hsync, vsync 
if((hcount< 659) || (hcount> 755)) hsync <= 1; 
else hsync <= 0; 

if((vcount< 493) || (vcount> 494)) vsync <= 1; 
else vsync <= 0; 

//visible range output R G B values 
if((hcount <= 640) && (vcount <= 480)) 
begin 
  case (color)
  0: begin R = 0; G = 0; B = 0; end //black 
  
  1: begin R = 0; G = 0; B = 255; end //blue 
  
  2: begin R = 165; G = 42; B = 42; end //brown
  
  3: begin R = 0; G = 139; B = 139; end //cyan
  
  4: begin R = 255; G = 0; B = 0; end //red
  
  5: begin R = 139; G = 0; B = 139; end // magenta
  
  6: begin R = 255; G = 255; B = 0; end //yellow
  
  7: begin R = 255; G = 255; B = 255; end //white 
  
  default: begin R = 0; G = 0; B = 0; end //black 
  endcase 

end 
else 
begin R = 0; G = 0; B = 0; end  

end 

endmodule 