`timescale 1ns / 1ps

module IIR_fold_tb(
y
    );

reg clk,rst;
reg[7:0] a,b,c,d;
reg[7:0] x;
reg[7:0] xr;
output reg[7:0] y;
wire[7:0] yo;
//wire[7:0] x1,y1,y2,mul1,mul2,m1,m2,m3,m4,a1,a2,a3,ai1,ai2,mulout,addout;
IIR_fold f0(
clk,
rst,
a,b,c,d,
x,
yo
);

reg[7:0] count;

initial begin
clk=0;
rst=0;
a = 0.5*16; // 0.5
b = 256-1.5*16; // -1.5
c = 2*16; // 2.0
d = 256-16; // -1.0
x=-80;
//xr=0;
count=0;
#3 rst=1;

end

always #1 begin
    clk<=~clk;
end
integer i = -5;
always@(posedge clk)begin
    if(rst)begin
        if((count==0))begin
            if(i<6)begin
                xr<=256+i*16;
                   i<=i+1;
            end
        end
        if(count==3) begin
            count<=0;
            x<=xr;
            y<=yo;
            end
        else begin
            count<=count+1;
            x<=0;
            end
    end
end

endmodule
