`timescale 1ns / 1ps

module cordic_tb(
x,y,z
    );

//your code here=============
reg clk,rst;
reg mode,load;
reg[15:0] x0,y0,z0;
output [15:0] x,y,z;

cordic c0(
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
mode=0; // sinh / cosh
#5 
rst=1; // start stuff
load=1; // start loading
#5
load=0; // start calc
#40
rst=0; // reset
#5
rst=1; // start stuff
mode=1; // arctanh
load=1; // start loading
#5
load=0;
end

always #1 begin
    clk<=~clk;
end

always@(posedge clk)begin
    if(!mode)begin // sin and cos
        x0 <= 8192; // cos 0 = 1
        y0 <= 0; // sin 0 = 0
        z0 <= 8579; // target angle of pi/3
    end else begin // arctan
        x0 <= 5793; // cos(z) = sqrt(2)/2
        y0 <= 5793; // sin(z) = sqrt(2)/2
        z0 <= 0;
    end
end

//your code here=============

endmodule
