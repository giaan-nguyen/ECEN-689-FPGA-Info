`timescale 1ns / 1ps

module FIR_tb(
y
    );

reg clk,rst;
reg[7:0] a,b,c;
reg[7:0] x;
output[7:0] y;


FIR f0(
clk,
rst,
a,b,c,
x,
y
);

initial begin
clk=0;
rst=0;
a=0.5*16;//0.5
b=256-1.5*16;//-1.5
c=2*16;//2.0
x=0;
#4 rst=1;
end

always #1 begin
    clk<=~clk;
end

integer n = -5;
always@(posedge clk)begin
    if(rst)begin
        if(n<6)begin
            x <=256 + n*16;
			n <= n + 1;
        end
    end
end

endmodule