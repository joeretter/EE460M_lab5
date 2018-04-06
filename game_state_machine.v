module game_state_machine(clk_25MHz, clk_5Hz, keycode, new_key_strobe, hcount, vcount, color); 
input clk_25Mhz, clk_5Hz, new_key_strobe, hcount, vcount; //the clk_25MHz should be the same one used for VGA output
input [7:0] keycode;
output color; 

reg snake;
reg [1:0] game_state; // 00 = game hasn't started yet, 01 = game is pause, 10 = normal game play, 11 = game over
reg reset_snake; //resets the snake back to its original position
reg ack_reset; //acknowledges that the snake has been reset back to its original position
reg [1:0] direction; // 00 = up, 01 = right, 10 = down, 11 = left
reg [10:0] SnakeX [0:3], SnakeY[0: 3]; //stores the X and Y coordinates of each of the 4 blocks that make up the snake 
reg [1:0] color; // 00 = white, 01 = blue, 10 = red

`define game_not_started 2'b00
`define game_paused 2'b01
`define normal_game_play 2'b10
`define game_over 2'b11

`define up 2'b00
`define right 2'b01
`define down 2'b10
`define left 2'b11

`define esc_key 8'h76
`define s_key 8'h1B
`define p_key 8'h4D
`define r_key 8'h2D
`define up_arrow_key 8'h75
`define right_arrow_key 8'h74
`define down_arrow_key 8'h72
`define left_arrow_key 8'h6B

`define white 2'b00
`define blue 2'b01
`define red 2'b10


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

//initial direction
direction <= right; 
reset_snake <= 0;
game_state <= game_not_started;

end 


always @(new_key_strobe, collision, ack_reset) //whenever a key is pressed or the snake hits something, update the game state and snake direction
begin
if(new_key_strobe) begin // I think this will create a latch, but it does what we want it to do
	case(game_state)
		game_not_started: begin
			if(keycode == s_key) game_state = normal_game_play;
			else game_state = game_not_started;
		end
		
		normal_game_play: begin
			if(keycode == esc_key) game_state = game_not_started;
			else if(keycode == s_key) reset_snake = 1; 
			else if(keycode == p_key) game_state = game_paused;
			else if(keycode == r_key) game_state = normal_game_play; 
			else if(keycode == up_arrow_key) begin game_state = normal_game_play; direction = up; end
			else if(keycode == right_arrow_key) begin game_state = normal_game_play; direction = right; end
			else if(keycode == down_arrow_key) begin game_state = normal_game_play; direction = down; end
			else if(keycode == left_arrow_key) begin game_state = normal_game_play; direction = left; end
			else game_state = normal_game_play;
		end
		
		game_paused: begin
			if(keycode == esc_key) game_state = game_not_started;
			else if(keycode == s_key) begin game_state = normal_game_play; reset_snake = 1; end
			else if(keycode == p_key) game_state = game_paused;
			else if(keycode == r_key) game_state = normal_game_play; 
			else game_state = game_paused;
		end
			
		game_over: begin
			if(keycode == esc_key) game_state = game_not_started;
			else if(keycode == s_key) begin game_state = normal_game_play; reset_snake = 1; end
			else game_state = game_over;
		end
	endcase
end

if(collision) begin
	game_state = game_over;
end

if(ack_reset) begin
	reset_snake = 0;
end
	
end



// update snake location at 5 FPS
always @(posedge clk_5Hz)
begin 
	if(reset_snake) begin
		SnakeX[0] <= 40; 
		SnakeX[1] <= 30; 
		SnakeX[2] <= 20; 
		SnakeX[3] <= 10; 

		SnakeY[0] <= 20; 
		SnakeY[1] <= 20; 
		SnakeY[2] <= 20; 
		SnakeY[3] <= 20; 
		ack_reset <= 1;
	end
	else begin
		ack_reset <= 0;
		case(direction) //move the snake head based on the direction 
		right: SnakeX[0] <= SnakeX[0] + 10;  
		left: SnakeX[0] <= SnakeX[0] - 10;  
		down: SnakeY[0] <= SnakeY[0] + 10;  
		up: SnakeY[0] <= SnakeY[0] - 10; 
		endcase 
		//move the rest of the snake
		SnakeX[1] <= SnakeX[0];
		SnakeX[2] <= SnakeX[1];
		SnakeX[3] <= SnakeX[2];
		SnakeY[1] <= SnakeY[0];
		SnakeY[2] <= SnakeY[1];
		SnakeY[3] <= SnakeY[2];
		//check for collision
		if((SnakeX[0] == 11'd0) || (SnakeX[0] == 11'd630) || (SnakeY[0] == 11'd0) || (SnakeY[0] == 11'd470)) collision <= 1;
		else collision <= 0;
	end
end 


always @(posedge clk_25Mhz)
begin
	if((hcount > 0 ) && (hcount < 640) && (vcount > 0) && (vcount < 10)) || ((hcount > 0 ) && (hcount<640) && (vcount >470) && (vcount < 480)) || ((hcount > 0 ) && (hcount<10) && (vcount >0) && (vcount < 480)) || ((hcount > 630 ) && (hcount<640) && (vcount >0) && (vcount < 480)))
		color <= red; //if the scanner is at the coordinates of a boundary, make that pixel red
	else if( ((hcount >= SnakeX[0]) && (hcount < (SnakeX[0] + 10)) && (vcount >= SnakeY[0]) && (vcount < (SnakeY[0] +10) )) 
	             || ((hcount >= SnakeX[1]) && (hcount < (SnakeX[1] + 10)) && (vcount >= SnakeY[1]) && (vcount < (SnakeY[1] +10) ))
				 || ((hcount >= SnakeX[2]) && (hcount < (SnakeX[2] + 10)) && (vcount >= SnakeY[2]) && (vcount < (SnakeY[2] +10) ))
				 || ((hcount >= SnakeX[3]) && (hcount < (SnakeX[3] + 10)) && (vcount >= SnakeY[3]) && (vcount < (SnakeY[3] +10) )) )
		color <= blue; //if the scanner is at the coordinates of any of the snake blocks, make that pixel blue
	else 
		color <= white; //otherwise make the pixel white
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
