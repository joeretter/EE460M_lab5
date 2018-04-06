module clk_div_5Hz(sys_clk, reset, clk_out_5Hz);
input sys_clk, reset;
output clk_out_5Hz;

reg [31:0] count_5Hz;
reg clk_out_5Hz;

always @(posedge sys_clk)
begin
  if(reset) begin
    count_5Hz <= 0;
    clk_out_5Hz <= 0;
  end
  else begin
    count_5Hz <= (count_5Hz + 1) % 10000000;
    if(count_5Hz == 9999999) begin
      clk_out_5Hz <= ~clk_out_5Hz;
    end
  end
end
endmodule
