`timescale 1ns / 1ps

module IIR_unfold_tb(

    );

//your code here=============
reg clk,rst;
reg[7:0] x2k,x2k1,a,b,c,d;
wire[7:0] y2k,y2k1;

IIR_unfold iirU(
clk,
rst,
a,b,c,d,
x2k,x2k1,
y2k,y2k1
);

initial begin
clk = 0;
rst = 0;
a = 0.5*16; // 0.5
b = 256-1.5*16; // -1.5
c = 2*16; // 2.0
d = 256-16; // -1.0
x2k = 0;
x2k1 = 0;
#4 rst = 1;
end

always #1 begin
    clk = ~clk;
end

integer n = -5;
always@(posedge clk)begin
    if(rst)begin
        if(n < 6)begin
            x2k <= 256 + n*16;
            x2k1 <= (n == 5) ? 256 + n*16 : 256 + (n+1)*16;
            n <= n + 2;
        end
    end
end
//your code here=============

endmodule
