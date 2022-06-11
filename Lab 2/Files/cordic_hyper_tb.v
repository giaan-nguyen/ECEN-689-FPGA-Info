`timescale 1ns / 1ps

module cordic_hyper_tb(
x,y,z
    );

//your code here=============
reg clk,rst;
reg mode,load;
reg[15:0] x0,y0,z0;
output [15:0] x,y,z;

cordic_hyper c0(
clk,
rst,
mode,
load,
x0,
y0,
z0,
x,
y,
z
);

initial begin
clk=0;
rst=0;
load=0;
mode=0; // sin / cos
#5 
rst=1; // start stuff
load=1; // start loading
#5
load=0; // start calc
#40
rst=0; // reset
#5
rst=1; // start stuff
mode=1; // arctan
load=1; // start loading
#5
load=0;
end

always #1 begin
    clk<=~clk;
end

always@(posedge clk)begin
    if(!mode)begin // sinh and cosh
        x0 <= 8192; // cosh 0 = 1
        y0 <= 0; // sinh 0 = 0
        z0 <= 8192; // target z of 1
    end else begin // arctanh
        x0 <= 12641; // cosh(1) = 1.543
        y0 <= 9627; // sinh(1) = 0.955
        z0 <= 0;
    end
end
//your code here=============

endmodule
