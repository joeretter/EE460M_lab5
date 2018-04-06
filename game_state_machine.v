module game_state_machine(clk_25MHz, clk_5Hz, keycode, new_key_strobe, hcount, vcount, color); 
input clk_25MHz, clk_5Hz, new_key_strobe; 
input [10:0] hcount, vcount; //the clk_25MHz should be the same one used for VGA output
input [7:0] keycode;
output reg [7:0] color; 

reg snake;
reg [1:0] game_state; // 00 = game hasn't started yet, 01 = game is pause, 10 = normal game play, 11 = game over
reg [1:0] nxt_game_state; 
reg reset_snake; //resets the snake back to its original position
reg ack_reset; //acknowledges that the snake has been reset back to its original position
reg [1:0] direction, direction_nxt; // 00 = up, 01 = right, 10 = down, 11 = left
reg [10:0] SnakeX [0:3], SnakeY[0: 3]; //stores the X and Y coordinates of each of the 4 blocks that make up the snake 
reg collision; 

parameter [1:0] game_not_started = 2'b00;
parameter [1:0] game_paused = 2'b01;
parameter [1:0] normal_game_play = 2'b10;
parameter [1:0] game_over = 2'b11;

parameter [1:0] up = 2'b01;
parameter [1:0] right = 2'b00;
parameter [1:0] down = 2'b10;
parameter [1:0] left = 2'b11;

parameter [7:0] esc_key = 8'h76;
parameter [7:0] s_key = 8'h1B;
parameter [7:0] p_key = 8'h4D;
parameter [7:0] r_key = 8'h2D;
parameter [7:0] up_arrow_key = 8'h75;
parameter [7:0] right_arrow_key = 8'h74;
parameter [7:0] down_arrow_key = 8'h72;
parameter [7:0] left_arrow_key = 8'h6B;

parameter [7:0] white = 8'b10000000;
parameter [7:0] blue = 8'b00000010;
parameter [7:0] red = 8'b00010000;
parameter [7:0] black = 8'b00100000;

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
direction_nxt <= right; 
reset_snake <= 0;
game_state <= game_not_started;
nxt_game_state <= game_not_started; 
ack_reset <=0; 
collision <= 0; 

end 



always @(new_key_strobe, collision, ack_reset) //whenever a key is pressed or the snake hits something, update the game state and snake direction //, collision, ack_reset
begin

if(new_key_strobe==1) begin 
	case(game_state)
		 game_not_started: begin
				if(keycode == s_key) nxt_game_state = normal_game_play;
				else nxt_game_state = game_not_started;
		end
		
		normal_game_play: begin
		
			if(keycode == esc_key) nxt_game_state = game_not_started;
			else if(keycode == s_key) reset_snake = 1; 
			else if(keycode == p_key) nxt_game_state = game_paused;
			else if(keycode == r_key) nxt_game_state = normal_game_play; 
		
		    if(keycode == up_arrow_key) begin nxt_game_state = normal_game_play;  direction_nxt = up; end
			else if(keycode == right_arrow_key) begin nxt_game_state = normal_game_play; direction_nxt = right; end
			else if(keycode == down_arrow_key) begin nxt_game_state = normal_game_play;  direction_nxt = down; end
			else if(keycode == left_arrow_key) begin nxt_game_state = normal_game_play; direction_nxt = left; end
			else begin nxt_game_state = normal_game_play; direction_nxt = direction; end
		
		end
		
		game_paused: begin
		
			if(keycode == esc_key) nxt_game_state = game_not_started;
			else if(keycode == s_key) begin nxt_game_state = normal_game_play; reset_snake = 1; end
			else if(keycode == p_key) nxt_game_state = game_paused;
			else if(keycode == r_key) nxt_game_state = normal_game_play; 
			else nxt_game_state = game_paused;
		 
		end
			
		game_over: begin
		
			if(keycode == esc_key) nxt_game_state = game_not_started;
			else if(keycode == s_key) begin nxt_game_state = normal_game_play; reset_snake = 1; end
			else nxt_game_state = game_over;
		
		end
	endcase
end

if(collision) begin
	nxt_game_state = game_over;
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
	    if(game_state == normal_game_play)
		begin 
		ack_reset <= 0;
		case(direction) //move the snake head based on the direction 
		left: SnakeX[0] <= SnakeX[0] - 10;  
		down: SnakeY[0] <= SnakeY[0] + 10;  
		up: SnakeY[0] <= SnakeY[0] - 10; 
		right: SnakeX[0] <= SnakeX[0] + 10;   
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
end 


always @(posedge clk_25MHz)
begin 
game_state <= nxt_game_state; 
direction <= direction_nxt; 

if(game_state == game_not_started) begin  color <= black; end 
//else if(game_state == game_over)begin color <= white; end 

else if (game_state ==  normal_game_play)
begin
 if(((hcount > 0 ) && (hcount < 640) && (vcount > 0) && (vcount < 10)) || ((hcount > 0 ) && (hcount<640) && (vcount >470) && (vcount < 480)) || ((hcount > 0 ) && (hcount<10) && (vcount >0) && (vcount < 480)) || ((hcount > 630 ) && (hcount<640) && (vcount >0) && (vcount < 480)))
		begin color <= red; end //if the scanner is at the coordinates of a boundary, make that pixel red
	else if( ((hcount >= SnakeX[0]) && (hcount < (SnakeX[0] + 10)) && (vcount >= SnakeY[0]) && (vcount < (SnakeY[0] +10) )) || ((hcount >= SnakeX[1]) && (hcount < (SnakeX[1] + 10)) && (vcount >= SnakeY[1]) && (vcount < (SnakeY[1] +10) ))|| ((hcount >= SnakeX[2]) && (hcount < (SnakeX[2] + 10)) && (vcount >= SnakeY[2]) && (vcount < (SnakeY[2] +10) )) || ((hcount >= SnakeX[3]) && (hcount < (SnakeX[3] + 10)) && (vcount >= SnakeY[3]) && (vcount < (SnakeY[3] +10) )) )
		begin color <= blue; end  //if the scanner is at the coordinates of any of the snake blocks, make that pixel blue
	else 
		begin color <= white; end  //otherwise make the pixel white

end
end 

endmodule 




