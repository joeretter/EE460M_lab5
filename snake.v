module snake_top(clk,data, vgaRed, vgaGreen, vgaBlue, Hsync, Vsync); 
input clk; 
input data; //size?
output [3:0] vgaRed, vgaGreen, vgaBlue; 
output  Hsync, Vsync; 
wire clk_25; 

//kecode, new_key_strobe 
snake snake_inst(clk, keycode, new_key_strobe, hcount, vcount, color); 
clk_div clk_div_inst(clk, 0, clk_25); 
vga_interface vga_interface_inst(clk_25, color, vgaRed, vgaGreen, vgaBlue, Hsync,Vsync, is_vis, hcount, vcount);

endmodule 

////////////////////////////SNAKE////////////////////////////////////

module snake(clk, keycode, new_key_strobe, hcount, vcount, color); 
input clk, keycode, new_key_strobe, hcount, vcount; 
output color; 

reg snake, bound; // apple  
reg [10:0] SnakeX [0:64], SnakeY[0: 48]; // snake is as big as it can be in x and y directions, each location in the array stores the coordinate to draw the upper left corner of that square SnakeX[0] is the head of the snake  


initial 
begin 
//put snake in starting location 
SnakeX[0] <= 40; 
SnakeX[1] <= 30; 
SnakeX[2] <= 20; 
SnakeX[3] <= 10; 

SnakeY[0] <= 20; 
SnakeY[1] <= 20; 
SnakeY[2] <= 20; 
SnakeY[3] <= 20; 

//initial direction ?

end 

// change direction of snake 
always @(posedge clk)
begin 
case(direction)
0: SnakeX <= SnakeX + 10; right 
1: SnakeX <= SnakeX - 10; left 
2: SnakeY <= SnakeY + 10; down 
3: SnakeY <= SnakeY - 10; up
endcase 


end 


//bound = 1 defines ten pixel boundary around the edge of the board, used for collision detection define 4 regions: top, bottom, left, right 
always @(posedge clk)
begin 
bound <= ((hcount > 0 ) && (hcount < 640) && (vcount > 0) && (vcount < 10)) || ((hcount > 0 ) && (hcount<640) && (vcount >479) && (vcount < 480)) || ((hcount > 0 ) && (hcount<10) && (vcount >0) && (vcount < 480)) || ((hcount > 639 ) && (hcount<640) && (vcount >0) && (vcount < 480));
end 

//only draw snake pixels within the bound of the snake: go through snakeX and snakeY array and draw 
//a green box in every location within the bounds  for loop ? 
always @(posedge clk)
begin 
if((SnakeX >= hcount) && ((SnakeX + 10) < hcount )) snake_x <= 1; 
if((SnakeY >= vcount) && ((SnakeY + 10) < vcount )) snake_y <= 1;   
snake <= snake_x && snake_y; 
end 

// colors to output on the screen
always@(snake, apple, bound)
begin 
if(snake) color <= 1 ; 
//else if(apple) color <= 2 ;
else if(bound) color <= 3 ; 
else color <= 4; 
end 



endmodule 





//////////////////////////CLK DIV///////////////////////////////////////////////////////////////////////
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
