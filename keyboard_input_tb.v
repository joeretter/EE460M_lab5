//this simulates pressing 'a' and releasing it quickly
// so the input will be '1C' (key press) 'F0' (key up) '1C' (scan code)
// and then pressing the 'z' and releasing it quickly some time later
// so the input will be '1A' (key press) 'F0' (key up) '1A' (scan code)
module keyboard_input_tb();

reg sys_clk, ps2_clk, ps2_data;
//sys_clk runs with period 10ns
//ps2_clk runs with period 40us = 40000ns

wire [3:0] scancode1, scancode0;
wire strobe_out;

initial begin
sys_clk = 1'b0;
ps2_clk = 1'b1;
forever #5 sys_clk = ~sys_clk;
end

always @(negedge ps2_data) begin //ps2_clk is started by the start bit of ps2_data
#10000
ps2_clk = 1'b0;
repeat(21) #20000 ps2_clk = ~ps2_clk; //ps2_clk runs for the duration of a data frame
end

initial begin 
ps2_data = 1'b1; //initial
#100
//'1C'
ps2_data = 1'b0; //start
#40000
ps2_data = 1'b0; //data0
#40000
ps2_data = 1'b0; //data1
#40000
ps2_data = 1'b1; //data2
#40000
ps2_data = 1'b1; //data3
#40000
ps2_data = 1'b1; //data4
#40000
ps2_data = 1'b0; //data5
#40000
ps2_data = 1'b0; //data6
#40000
ps2_data = 1'b0; //data7
#40000
ps2_data = 1'b0; //parity
#40000
ps2_data = 1'b1; //stop
#40000

//'F0'
ps2_data = 1'b0; //start
#40000
ps2_data = 1'b0; //data0
#40000
ps2_data = 1'b0; //data1
#40000
ps2_data = 1'b0; //data2
#40000
ps2_data = 1'b0; //data3
#40000
ps2_data = 1'b1; //data4
#40000
ps2_data = 1'b1; //data5
#40000
ps2_data = 1'b1; //data6
#40000
ps2_data = 1'b1; //data7
#40000
ps2_data = 1'b0; //parity
#40000
ps2_data = 1'b1; //stop
#40000

//'1C'
ps2_data = 1'b0; //start
#40000
ps2_data = 1'b0; //data0
#40000
ps2_data = 1'b0; //data1
#40000
ps2_data = 1'b1; //data2
#40000
ps2_data = 1'b1; //data3
#40000
ps2_data = 1'b1; //data4
#40000
ps2_data = 1'b0; //data5
#40000
ps2_data = 1'b0; //data6
#40000
ps2_data = 1'b0; //data7
#40000
ps2_data = 1'b0; //parity
#40000
ps2_data = 1'b1; //stop

#200000000

//'1A'
ps2_data = 1'b0; //start
#40000
ps2_data = 1'b0; //data0
#40000
ps2_data = 1'b1; //data1
#40000
ps2_data = 1'b0; //data2
#40000
ps2_data = 1'b1; //data3
#40000
ps2_data = 1'b1; //data4
#40000
ps2_data = 1'b0; //data5
#40000
ps2_data = 1'b0; //data6
#40000
ps2_data = 1'b0; //data7
#40000
ps2_data = 1'b0; //parity
#40000
ps2_data = 1'b1; //stop
#40000

//'F0'
ps2_data = 1'b0; //start
#40000
ps2_data = 1'b0; //data0
#40000
ps2_data = 1'b0; //data1
#40000
ps2_data = 1'b0; //data2
#40000
ps2_data = 1'b0; //data3
#40000
ps2_data = 1'b1; //data4
#40000
ps2_data = 1'b1; //data5
#40000
ps2_data = 1'b1; //data6
#40000
ps2_data = 1'b1; //data7
#40000
ps2_data = 1'b0; //parity
#40000
ps2_data = 1'b1; //stop
#40000

//'1A'
ps2_data = 1'b0; //start
#40000
ps2_data = 1'b0; //data0
#40000
ps2_data = 1'b1; //data1
#40000
ps2_data = 1'b0; //data2
#40000
ps2_data = 1'b1; //data3
#40000
ps2_data = 1'b1; //data4
#40000
ps2_data = 1'b0; //data5
#40000
ps2_data = 1'b0; //data6
#40000
ps2_data = 1'b0; //data7
#40000
ps2_data = 1'b0; //parity
#40000
ps2_data = 1'b1; //stop

#200000000

$finish;
end

keyboard_input kbrd(sys_clk, ps2_clk, ps2_data, scancode1, scancode0, strobe_out);

endmodule






