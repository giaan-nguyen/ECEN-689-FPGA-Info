`timescale 1ns / 1ps

module FIR(
clk,
rst,
a,b,c,
x,
y
);

input clk,rst;
input[7:0] a,b,c;
input[7:0] x;
output[7:0] y;

//your code here=============
reg [7:0] x1, x2; // 8-bit registers for x[n-1], x[n-2]
wire [7:0] mulA, mulB, mulC;

always@(posedge clk or negedge rst) // delays using registers
    if(!rst)
        begin
            x1 <= 'd0;
            x2 <= 'd0;
        end
    else
        begin 
            x1 <= x; // where the shifts happen
            x2 <= x1;
        end

multiply mA(a, x, mulA);
multiply mB(b, x1, mulB);
multiply mC(c, x2, mulC);

assign y = mulA + mulB + mulC;
//your code here=============

endmodule
