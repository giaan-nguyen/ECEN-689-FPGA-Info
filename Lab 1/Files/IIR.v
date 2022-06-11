`timescale 1ns / 1ps

module IIR(
clk,
rst,
a,b,c,d,
x,
y
);

input clk,rst;
input[7:0] a,b,c,d;
input[7:0] x;
output[7:0] y;

//your code here=============
reg [7:0] x1,y1,y2; // 8-bit registers for x[n-1], y[n-1], y[n-2]
wire [7:0] mulA, mulB, mulC, mulD;

always@(posedge clk or negedge rst)
    if(!rst)
        begin
            x1 <= 'd0;
            y1 <= 'd0;
            y2 <= 'd0;
        end
    else
        begin
            x1 <= x;
            y1 <= y;
            y2 <= y1;
        end

multiply mA(a, x, mulA);
multiply mB(b, x1, mulB);
multiply mC(c, y1, mulC);
multiply mD(d, y2, mulD);

assign y = mulA + mulB + mulC + mulD;
//your code here=============

endmodule
