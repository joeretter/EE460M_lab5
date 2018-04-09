module game_state_machine(clk_25MHz, clk_5Hz, keycode, new_key_strobe, hcount, vcount, color); 
input clk_25MHz, clk_5Hz, new_key_strobe; 
input [10:0] hcount, vcount; //the clk_25MHz should be the same one used for VGA output
input [7:0] keycode;
output reg [7:0] color; 

reg snake;
reg [2:0] game_state; // 000 = game hasn't started yet, 001 = game is pause, 010 = normal game play, 011 = game over, 100 = start_position
reg [2:0] nxt_game_state; 
reg [1:0] direction, direction_nxt; // 00 = up, 01 = right, 10 = down, 11 = left
reg [10:0] SnakeX [0:3], SnakeY[0: 3]; //stores the X and Y coordinates of each of the 4 blocks that make up the snake 
reg [10:0] SnakeX_nxt [0:3], SnakeY_nxt[0: 3]; 
reg collision; 

parameter [2:0] game_not_started = 3'b000;
parameter [2:0] game_paused = 3'b001;
parameter [2:0] normal_game_play = 3'b010;
parameter [2:0] game_over = 3'b011;
parameter [2:0] start_position = 3'b100;

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

SnakeX_nxt[0] <= 40;
SnakeX_nxt[1] <= 30;
SnakeX_nxt[2] <= 20;
SnakeX_nxt[3] <= 10;
SnakeY_nxt[0] <= 20;
SnakeY_nxt[1] <= 20;
SnakeY_nxt[2] <= 20;
SnakeY_nxt[3] <= 20;

//initial direction
direction <= right; 
//direction_nxt <= right; 
game_state <= game_not_started;
nxt_game_state <= game_not_started; 
collision <= 0; 

end 



always @(new_key_strobe, collision, game_state) //whenever a key is pressed or the snake hits something, update the game state and snake direction //, collision, ack_reset
begin
    case(game_state)
	   game_not_started: begin
	       if(new_key_strobe == 1'b1) begin
				if(keycode == s_key) nxt_game_state = start_position;
				else nxt_game_state = game_not_started;
			end
			else nxt_game_state = game_not_started;	  
		end
		
		start_position: begin
            if(new_key_strobe == 1'b1) begin
			    SnakeX_nxt[0] = 40; 
				SnakeX_nxt[1] = 30; 
				SnakeX_nxt[2] = 20; 
				SnakeX_nxt[3] = 10; 
				SnakeY_nxt[0] = 20; 
				SnakeY_nxt[1] = 20; 
				SnakeY_nxt[2] = 20; 
				SnakeY_nxt[3] = 20; 
			
                if(keycode == esc_key) nxt_game_state = game_not_started;
                else if(keycode == s_key) nxt_game_state = start_position; 
                else if(keycode == p_key) nxt_game_state = game_paused;
                else if(keycode == r_key) nxt_game_state = normal_game_play; 
                        
                else if(keycode == up_arrow_key) begin nxt_game_state = normal_game_play;  direction = up; end
                else if(keycode == right_arrow_key) begin nxt_game_state = normal_game_play; direction = right; end
                else if(keycode == down_arrow_key) begin nxt_game_state = normal_game_play;  direction = down; end
                else if(keycode == left_arrow_key) begin nxt_game_state = normal_game_play; direction = left; end
                else begin nxt_game_state = normal_game_play; direction = right; end
            end
            else begin nxt_game_state = normal_game_play; direction = right; end
        end
		
        normal_game_play: begin
		case(direction) //move the snake head based on the direction 
		      left: SnakeX_nxt[0] = SnakeX[0] - 10;  
		      down: SnakeY_nxt[0] = SnakeY[0] + 10;  
		      up: SnakeY_nxt[0] = SnakeY[0] - 10; 
		      right: SnakeX_nxt[0] = SnakeX[0] + 10;   
		endcase 
		  //move the rest of the snake
		  SnakeX_nxt[1] = SnakeX[0];
		  SnakeX_nxt[2] = SnakeX[1];
		  SnakeX_nxt[3] = SnakeX[2];
		  SnakeY_nxt[1] = SnakeY[0];
		  SnakeY_nxt[2] = SnakeY[1];
		  SnakeY_nxt[3] = SnakeY[2];
		
		
      
            if(new_key_strobe == 1'b1) begin
                if(keycode == esc_key) nxt_game_state = game_not_started;
                //else if(keycode == s_key) nxt_game_state = start_position; 
                else if(keycode == p_key) nxt_game_state = game_paused;
                else if(keycode == r_key) nxt_game_state = normal_game_play; 
            
                else if(keycode == up_arrow_key) begin nxt_game_state = normal_game_play;  direction = up; end
                else if(keycode == right_arrow_key) begin nxt_game_state = normal_game_play; direction = right; end
                else if(keycode == down_arrow_key) begin nxt_game_state = normal_game_play;  direction = down; end
                else if(keycode == left_arrow_key) begin nxt_game_state = normal_game_play; direction = left; end
                else begin nxt_game_state = normal_game_play; direction = direction; end
            end
            else if(collision == 1'b1) nxt_game_state = game_over;
            else nxt_game_state = normal_game_play;
		end
		
		game_paused: begin
		
		SnakeX_nxt[0] = SnakeX[0];
        SnakeX_nxt[1] = SnakeX[1];
        SnakeX_nxt[2] = SnakeX[2];
        SnakeX_nxt[3] = SnakeX[3];
        SnakeY_nxt[0] = SnakeY[0];
        SnakeY_nxt[1] = SnakeY[1];
        SnakeY_nxt[2] = SnakeY[2];
        SnakeY_nxt[3] = SnakeY[3];
		
		
            if(new_key_strobe == 1'b1) begin
                if(keycode == esc_key) nxt_game_state = game_not_started;
                else if(keycode == s_key) begin nxt_game_state = start_position; end
                else if(keycode == p_key) nxt_game_state = game_paused;
                else if(keycode == r_key) nxt_game_state = normal_game_play; 
                else nxt_game_state = game_paused;
            end
            else nxt_game_state = game_paused;
		end
			
		game_over: begin
		
		SnakeX_nxt[0] = SnakeX[0];
        SnakeX_nxt[1] = SnakeX[1];
        SnakeX_nxt[2] = SnakeX[2];
        SnakeX_nxt[3] = SnakeX[3];
        SnakeY_nxt[0] = SnakeY[0];
        SnakeY_nxt[1] = SnakeY[1];
        SnakeY_nxt[2] = SnakeY[2];
        SnakeY_nxt[3] = SnakeY[3];
		
		
            if(new_key_strobe == 1'b1) begin
                if(keycode == esc_key) nxt_game_state = game_not_started;
			    else if(keycode == s_key) nxt_game_state = start_position;
			    else nxt_game_state = game_over;
            end
		    else nxt_game_state = game_over;
        end
        
        default: nxt_game_state = game_not_started;
	endcase
end




// update snake location at 5 FPS
always @(posedge clk_5Hz)
begin 
    game_state <= nxt_game_state; 
    //direction <= direction_nxt; 
	SnakeX[0] <= SnakeX_nxt[0];
    SnakeX[1] <= SnakeX_nxt[1];
    SnakeX[2] <= SnakeX_nxt[2];
    SnakeX[3] <= SnakeX_nxt[3];
    SnakeY[0] <= SnakeY_nxt[0];
    SnakeY[1] <= SnakeY_nxt[1];
    SnakeY[2] <= SnakeY_nxt[2];
    SnakeY[3] <= SnakeY_nxt[3];
	
	
	//check for collision
	if((SnakeX_nxt[0] == 11'd0) || (SnakeX_nxt[0] == 11'd630) || (SnakeY_nxt[0] == 11'd0) || (SnakeY_nxt[0] == 11'd470)) collision = 1;
	else collision = 0;
end 


always @(posedge clk_25MHz)
begin 
if(game_state == game_not_started) begin  color <= black; end 
//else if(game_state == game_over)begin color <= white; end 

else 
begin
 if(((hcount >= 0 ) && (hcount < 640) && (vcount >= 0) && (vcount < 10)) || ((hcount >= 0 ) && (hcount<640) && (vcount >470) && (vcount < 480)) || ((hcount >= 0 ) && (hcount<10) && (vcount >=0) && (vcount < 480)) || ((hcount > 630 ) && (hcount<640) && (vcount >=0) && (vcount < 480)))
		begin color <= red; end //if the scanner is at the coordinates of a boundary, make that pixel red
	else if( ((hcount >= SnakeX[0]) && (hcount < (SnakeX[0] + 10)) && (vcount >= SnakeY[0]) && (vcount < (SnakeY[0] +10) )) || ((hcount >= SnakeX[1]) && (hcount < (SnakeX[1] + 10)) && (vcount >= SnakeY[1]) && (vcount < (SnakeY[1] +10) ))|| ((hcount >= SnakeX[2]) && (hcount < (SnakeX[2] + 10)) && (vcount >= SnakeY[2]) && (vcount < (SnakeY[2] +10) )) || ((hcount >= SnakeX[3]) && (hcount < (SnakeX[3] + 10)) && (vcount >= SnakeY[3]) && (vcount < (SnakeY[3] +10) )) )
		begin color <= blue; end  //if the scanner is at the coordinates of any of the snake blocks, make that pixel blue
	else 
		begin color <= white; end  //otherwise make the pixel white

end
end 

endmodule 




