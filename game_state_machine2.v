module game_state_machine(clk, clk_25MHz, clk_5Hz, keycode, new_key_strobe, hcount, vcount, color); 
input clk, clk_25MHz, clk_5Hz, new_key_strobe; 
input [10:0] hcount, vcount; //the clk_25MHz should be the same one used for VGA output
input [7:0] keycode;
output reg [7:0] color; 

reg snake;
reg [2:0] game_state; // 000 = game hasn't started yet, 001 = game is pause, 010 = normal game play, 011 = game over, 100 = start_position
reg [2:0] nxt_game_state; 
reg [1:0] direction, direction_nxt; // 00 = up, 01 = right, 10 = down, 11 = left
reg [10:0] SnakeX [0:3], SnakeY[0: 3]; //stores the X and Y coordinates of each of the 4 blocks that make up the snake 
reg collision; 

reg [10:0] BombX [0:7], BombY[0: 7];

reg sync_state, sync_state_nxt, strobe_tiny;
reg start_ack, start_flag;

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
///place bombs /// 
BombX[0] <= 200; 
BombX[1] <= 400; 
BombX[2] <= 100; 
BombX[3] <= 200; 
BombX[4] <= 500; 
BombX[5] <= 600; 
BombX[6] <= 300; 
BombX[7] <= 400; 

BombY[0] <= 100; 
BombY[1] <= 200; 
BombY[2] <= 300; 
BombY[3] <= 400; 
BombY[4] <= 100; 
BombY[5] <= 200; 
BombY[6] <= 300; 
BombY[7] <= 400;

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
game_state <= game_not_started;
nxt_game_state <= game_not_started; 
collision <= 0; 

sync_state <= 0; 
start_ack <= 0; 
start_flag <=0; 

end 

//new_key_strobe reduced to single pulse 
always @(new_key_strobe, sync_state)
begin 
case(sync_state)
	0: if(new_key_strobe == 1) begin strobe_tiny = 1;  sync_state_nxt = 1; end 
	   else begin strobe_tiny = 0; sync_state_nxt = 0; end 
	1: if(new_key_strobe == 1) begin strobe_tiny = 0; sync_state_nxt = 1; end 
	   else begin strobe_tiny = 0; sync_state_nxt= 0; end 
endcase
end

always @(posedge clk)
begin 
sync_state <= sync_state_nxt; 
game_state <= nxt_game_state; 
end 


always @(strobe_tiny, collision, game_state, keycode, start_ack) //whenever a key is pressed or the snake hits something, update the game state and snake direction //, collision, ack_reset
begin
    case(game_state)
	   game_not_started: begin 
           start_flag =0; 
           direction_nxt = right; 
	       if(new_key_strobe == 1'b1) begin
				if(keycode == s_key) nxt_game_state = start_position;
				else nxt_game_state = game_not_started;
			end
			else nxt_game_state = game_not_started;	  
		end
		
		start_position: if(start_ack == 0) begin nxt_game_state = start_position; start_flag = 1; end 
            /*if(new_key_strobe == 1'b1) begin
                if(keycode == esc_key) nxt_game_state = game_not_started;
                else if(keycode == s_key) nxt_game_state = start_position; 
                else if(keycode == p_key) nxt_game_state = game_paused;
                else if(keycode == r_key) nxt_game_state = normal_game_play; 
                        
                else if(keycode == up_arrow_key) begin nxt_game_state = normal_game_play; if((direction == right) || (direction == left)) direction_nxt = up; else direction_nxt = direction; end
                else if(keycode == right_arrow_key) begin nxt_game_state = normal_game_play; if((direction == up) || (direction == down)) direction_nxt = right; else direction_nxt = direction; end
                else if(keycode == down_arrow_key) begin nxt_game_state = normal_game_play; if((direction == right) || (direction == left)) direction_nxt = down; else direction_nxt = direction; end
                else if(keycode == left_arrow_key) begin nxt_game_state = normal_game_play; if((direction == up) || (direction == down)) direction_nxt = left; else direction_nxt = direction; end
                else begin nxt_game_state = normal_game_play; direction_nxt = right; end*/
            
            else begin nxt_game_state = normal_game_play; direction_nxt = right; start_flag = 0; end
        
		
        normal_game_play: begin
      
            if(new_key_strobe == 1'b1) begin
                if(keycode == esc_key) nxt_game_state = game_not_started;
                //else if(keycode == s_key) nxt_game_state = start_position; 
                else if(keycode == p_key) nxt_game_state = game_paused;
                else if(keycode == r_key) nxt_game_state = normal_game_play; 
            
                else if(keycode == up_arrow_key) begin nxt_game_state = normal_game_play; if((direction == right) || (direction == left)) direction_nxt = up; else  direction_nxt = direction; end
                else if(keycode == right_arrow_key) begin nxt_game_state = normal_game_play; if((direction == up) || (direction == down)) direction_nxt = right; else direction_nxt = direction; end
                else if(keycode == down_arrow_key) begin nxt_game_state = normal_game_play; if((direction == right) || (direction == left)) direction_nxt = down; else direction_nxt = direction; end
                else if(keycode == left_arrow_key) begin nxt_game_state = normal_game_play; if((direction == up) || (direction == down)) direction_nxt = left; else direction_nxt = direction; end
                else begin nxt_game_state = normal_game_play; direction_nxt = direction; end
            end
            else if(collision == 1'b1) nxt_game_state = game_over;
            else nxt_game_state = normal_game_play;
		end
		
		game_paused: begin
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

   direction <= direction_nxt; 
    
    if(game_state == start_position) begin
         SnakeX[0] <= 40; 
         SnakeX[1] <= 30; 
         SnakeX[2] <= 20; 
         SnakeX[3] <= 10; 
         SnakeY[0] <= 20; 
         SnakeY[1] <= 20; 
         SnakeY[2] <= 20; 
         SnakeY[3] <= 20; 
		 start_ack <= 1; 
    end
	else if(game_state == normal_game_play) begin 
		start_ack <= 0; 
		  case(direction_nxt) //move the snake head based on the direction 
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
		  if((SnakeX[0] == 11'd10) || (SnakeX[0] == 11'd620) || (SnakeY[0] == 11'd10) || (SnakeY[0] == 11'd460)) collision <= 1;
		  else collision <= 0;
    end
    else if((game_state == game_paused) ) begin 
        SnakeX[0] <= SnakeX[0];
        SnakeX[1] <= SnakeX[1];
        SnakeX[2] <= SnakeX[2];
        SnakeX[3] <= SnakeX[3];
        SnakeY[0] <= SnakeY[0];
        SnakeY[1] <= SnakeY[1];
        SnakeY[2] <= SnakeY[2];
        SnakeY[3] <= SnakeY[3];
    end
	else if(game_state == game_over ) begin
	    start_ack <= 0; 
		direction <= right; 
        SnakeX[0] <= SnakeX[0];
        SnakeX[1] <= SnakeX[1];
        SnakeX[2] <= SnakeX[2];
        SnakeX[3] <= SnakeX[3];
        SnakeY[0] <= SnakeY[0];
        SnakeY[1] <= SnakeY[1];
        SnakeY[2] <= SnakeY[2];
        SnakeY[3] <= SnakeY[3];
    end
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
	if( ((hcount >= BombX[0]) && (hcount < (BombX[0] + 10)) && (vcount >= BombY[0]) && (vcount < (BombY[0] +10) )) || ((hcount >= BombX[1]) && (hcount < (BombX[1] + 10)) && (vcount >= BombY[1]) && (vcount < (BombY[1] +10) ))|| ((hcount >= BombX[2]) && (hcount < (BombX[2] + 10)) && (vcount >= BombY[2]) && (vcount < (BombY[2] +10) )) || ((hcount >= BombX[3]) && (hcount < (BombX[3] + 10)) && (vcount >= BombY[3]) && (vcount < (BombY[3] +10) )) )
		begin color <= black; end 
		
	else 
	if( ((hcount >= BombX[4]) && (hcount < (BombX[4] + 10)) && (vcount >= BombY[4]) && (vcount < (BombY[4] +10) )) || ((hcount >= BombX[5]) && (hcount < (BombX[5] + 10)) && (vcount >= BombY[5]) && (vcount < (BombY[5] +10) ))|| ((hcount >= BombX[6]) && (hcount < (BombX[6] + 10)) && (vcount >= BombY[6]) && (vcount < (BombY[6] +10) )) || ((hcount >= BombX[7]) && (hcount < (BombX[7] + 10)) && (vcount >= BombY[7]) && (vcount < (BombY[7] +10) )) )
		begin color <= black; end 
	else 
		begin color <= white; end  //otherwise make the pixel white

end
end 

endmodule 




