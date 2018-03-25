module sorter (reset, clk, weight, grp1, grp2, grp3, grp4, grp5, grp6, currentGrp); 
input reset, clk; 
input wire [11:0] weight; 
output reg [7:0] grp1, grp2, grp3, grp4, grp5, grp6; 
output reg [2:0] currentGrp;  // negative sign? 

reg new_pkg = 0; 
reg new_pkg_b = 0 ; 


initial 
begin 
currentGrp = 3'b0; //negative sign ? 
grp1 = 0; 
grp2 = 0; 
grp3 = 0; 
grp4 = 0; 
grp5 = 0; 
grp6 = 0; 
new_pkg = 1; 
new_pkg_b = 1; 
end 

always @(weight)
begin 

if( weight == 0 ) begin new_pkg = 1; new_pkg_b = 1; currentGrp = 0;  end 


if( (weight != 0 )) //(new_pkg == 1) && should currentGrp update without a 0 in between 
begin 
if ((weight >= 12'd1) && (weight <= 12'd250)) begin currentGrp = 3'd1; new_pkg =0;  end 
else if ((weight >= 12'd251) && (weight <= 12'd500)) begin currentGrp = 3'd2; new_pkg =0; end 
else if ((weight >= 12'd501) && (weight <= 12'd750)) begin currentGrp = 3'd3;  new_pkg =0;end 
else if ((weight >= 12'd751) && (weight <= 12'd1500)) begin currentGrp = 3'd4; new_pkg =0; end 
else if ((weight >= 12'd1501) && (weight <= 12'd2000)) begin currentGrp = 3'd5;  new_pkg =0;end 
else if ((weight > 12'd2000)) begin currentGrp = 3'd6;  new_pkg =0;end 
end 


end 

always @(negedge clk, posedge reset)
begin 
if(reset == 1)
begin 
grp1 <= 0; 
grp2 <= 0; 
grp3 <= 0; 
grp4 <= 0; 
grp5 <= 0; 
grp6 <= 0; 
end 
else if ((new_pkg_b == 1 ) &&(weight >= 12'd1) && (weight <= 12'd250)) begin grp1 <= grp1 + 1; new_pkg_b =0;  end 
else if ((new_pkg_b == 1 ) &&(weight >= 12'd251) && (weight <= 12'd500)) begin grp2 <= grp2 + 1; new_pkg_b =0; end 
else if ((new_pkg_b == 1 ) &&(weight >= 12'd501) && (weight <= 12'd750)) begin grp3 <= grp3 + 1;  new_pkg_b =0;end 
else if ((new_pkg_b == 1 ) &&(weight >= 12'd751) && (weight <= 12'd1500)) begin grp4 <= grp4 + 1; new_pkg_b =0; end 
else if ((new_pkg_b == 1 ) &&(weight >= 12'd1501) && (weight <= 12'd2000)) begin grp5 <= grp5 + 1;  new_pkg_b =0;end 
else if ((new_pkg_b == 1 ) &&(weight > 12'd2000)) begin grp6 <= grp6 + 1;  new_pkg_b =0;end 


end 


endmodule 
