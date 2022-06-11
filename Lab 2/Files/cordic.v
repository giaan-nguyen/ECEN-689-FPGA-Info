`timescale 1ns / 1ps

module cordic(
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

input clk,rst;
input mode,load;
input[15:0] x0,y0,z0;
output reg[15:0] x,y,z;

//your code here=============
parameter N = 7; // N iterations, or N stages
wire[15:0] atan[0:13];
// table of arctan(2^-k)
assign atan[0] = 6434; // atan(2^0)
assign atan[1] = 3798; // atan(2^-1)
assign atan[2] = 2007; // atan(2^-2)
assign atan[3] = 1019;
assign atan[4] = 511;
assign atan[5] = 256;
assign atan[6] = 128;
assign atan[7] = 64;
assign atan[8] = 32;
assign atan[9] = 16;
assign atan[10] = 8;
assign atan[11] = 4;
assign atan[12] = 2;
assign atan[13] = 1;

// Q(3,13) --> multiply by 2^13
reg dk[0:N];
integer k = 0; // for looping
reg signed[15:0] xs[0:N], ys[0:N], zs[0:N];

always@(posedge clk or negedge rst)begin
if(!rst)begin
    x <= 0; y <= 0; z <= 0;
    for(k = 0; k <= N; k = k + 1)begin
        xs[k] <= 0; ys[k] <= 0; zs[k] <= 0; dk[k] <= 0;
    end
end else begin
if(load)begin
    x <= x0; y <= y0; z <= z0;
    for(k = 0; k <= N; k = k + 1)begin
        xs[k] <= 0; ys[k] <= 0; zs[k] <= 0;
    end
end else begin
    xs[0] <= x0;
    ys[0] <= y0;
    zs[0] <= z0;
    dk[0] <= mode ? ~(ys[0][15]) : zs[0][15]; 
    // if mode=1, set inverse sign of yk. else, set regular sign of zk. 

    // if dk is neg, flip the operation signs. else, keep the same.
    xs[1] <= dk[0] ? (xs[0] + (ys[0] >>> 0)) : (xs[0] - (ys[0] >>> 0));
    ys[1] <= dk[0] ? (ys[0] - (xs[0] >>> 0)) : (ys[0] + (xs[0] >>> 0));
    zs[1] <= dk[0] ? (zs[0] + atan[0]) : (zs[0] - atan[0]);
    dk[1] <= mode ? ~(ys[1][15]) : zs[1][15];

    xs[2] <= dk[1] ? (xs[1] + (ys[1] >>> 1)) : (xs[1] - (ys[1] >>> 1));
    ys[2] <= dk[1] ? (ys[1] - (xs[1] >>> 1)) : (ys[1] + (xs[1] >>> 1));
    zs[2] <= dk[1] ? (zs[1] + atan[1]) : (zs[1] - atan[1]);
    dk[2] <= mode ? ~(ys[2][15]) : zs[2][15];

    xs[3] <= dk[2] ? (xs[2] + (ys[2] >>> 2)) : (xs[2] - (ys[2] >>> 2));
    ys[3] <= dk[2] ? (ys[2] - (xs[2] >>> 2)) : (ys[2] + (xs[2] >>> 2));
    zs[3] <= dk[2] ? (zs[2] + atan[2]) : (zs[2] - atan[2]);
    dk[3] <= mode ? ~(ys[3][15]) : zs[3][15];
    
    xs[4] <= dk[3] ? (xs[3] + (ys[3] >>> 3)) : (xs[3] - (ys[3] >>> 3));
    ys[4] <= dk[3] ? (ys[3] - (xs[3] >>> 3)) : (ys[3] + (xs[3] >>> 3));
    zs[4] <= dk[3] ? (zs[3] + atan[3]) : (zs[3] - atan[3]);
    dk[4] <= mode ? ~(ys[4][15]) : zs[4][15];
    
    xs[5] <= dk[4] ? (xs[4] + (ys[4] >>> 4)) : (xs[4] - (ys[4] >>> 4));
    ys[5] <= dk[4] ? (ys[4] - (xs[4] >>> 4)) : (ys[4] + (xs[4] >>> 4));
    zs[5] <= dk[4] ? (zs[4] + atan[4]) : (zs[4] - atan[4]);
    dk[5] <= mode ? ~(ys[5][15]) : zs[5][15];
    
    xs[6] <= dk[5] ? (xs[5] + (ys[5] >>> 5)) : (xs[5] - (ys[5] >>> 5));
    ys[6] <= dk[5] ? (ys[5] - (xs[5] >>> 5)) : (ys[5] + (xs[5] >>> 5));
    zs[6] <= dk[5] ? (zs[5] + atan[5]) : (zs[5] - atan[5]);
    dk[6] <= mode ? ~(ys[6][15]) : zs[6][15];
    
    xs[7] <= dk[6] ? (xs[6] + (ys[6] >>> 6)) : (xs[6] - (ys[6] >>> 6));
    ys[7] <= dk[6] ? (ys[6] - (xs[6] >>> 6)) : (ys[6] + (xs[6] >>> 6));
    zs[7] <= dk[6] ? (zs[6] + atan[6]) : (zs[6] - atan[6]);
    dk[7] <= mode ? ~(ys[7][15]) : zs[7][15];
    
    x <= dk[7] ? (xs[7] + (ys[7] >>> 7)) : (xs[7] - (ys[7] >>> 7));
    y <= dk[7] ? (ys[7] - (xs[7] >>> 7)) : (ys[7] + (xs[7] >>> 7));
    z <= dk[7] ? (zs[7] + atan[7]) : (zs[7] - atan[7]);
end
end
end

//your code here=============
endmodule
