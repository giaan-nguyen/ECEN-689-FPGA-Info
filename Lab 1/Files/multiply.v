`timescale 1ns / 1ps

module multiply(a,b,c);

parameter width=8;
parameter decimal=4;

input [width-1:0] a,b;
output [width-1:0] c;

wire[width*2-1:0] mul0; // double-width of a.
wire[width*2-1:0] mul1; // double-width of b.
wire[width*2-1:0] ones; // double-width of ones.
wire[width*2-1:0] ab; // intermediate result of a * b.

assign ones=(~0);

//your code here=============
assign mul0[width*2-1:width] = a[width-1];
assign mul0[width-1:0] = a;
assign mul1[width*2-1:width] = b[width-1];
assign mul1[width-1:0] = b;
assign ab = mul0 * mul1;

//your code here=============

assign c=ab[width-1+decimal:decimal];

endmodule
