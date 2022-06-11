`timescale 1ns / 1ps

module IIR_unfold(
clk,
rst,
a,b,c,d,
x2k,x2k1,
y2k,y2k1
);

input clk,rst;
input[7:0] a,b,c,d;
input[7:0] x2k,x2k1; // x[2k], x[2k+1]
output[7:0] y2k,y2k1; // y[2k], y[2k+1]

//your code here=============
wire[7:0] a_top,a_bott,b_top,b_bott,c_top,c_bott,d_top,d_bott;
reg[7:0] x2km1; // x[2k-1]
reg[7:0] y2km1,y2km2; // y[2k-1], y[2k-2]

multiply m0(x2k,a,a_top);
multiply m1(x2k1,a,a_bott);
multiply m2(x2km1,b,b_top);
multiply m3(x2k,b,b_bott);
multiply m4(y2km1,c,c_top);
multiply m5(y2k,c,c_bott);
multiply m6(y2km2,d,d_top);
multiply m7(y2km1,d,d_bott);

assign y2k = a_top + b_top + c_top + d_top;
assign y2k1 = a_bott + b_bott + c_bott + d_bott;

always@(posedge clk or negedge rst)begin
if(~rst)begin
    x2km1 <= 0;
    y2km1 <= 0;
    y2km2 <= 0;
end else begin
    x2km1 <= x2k1;
    y2km1 <= y2k1;
    y2km2 <= y2k;
end
end
//your code here=============

endmodule
