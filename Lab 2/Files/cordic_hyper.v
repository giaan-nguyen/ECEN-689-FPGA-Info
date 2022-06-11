`timescale 1ns / 1ps

module cordic_hyper(
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
// NOTE: hyperbolics start at index 1 since arctanh(0) = inf
parameter N = 8; // N-1 iterations, or N-1 stages
wire[15:0] atanh[0:13];
// table of arctanh(2^-k)
assign atanh[1] = 4500; // atanh(2^-1)
assign atanh[2] = 2092; // atanh(2^-2)
assign atanh[3] = 1029;
assign atanh[4] = 513;
assign atanh[5] = 256;
assign atanh[6] = 128;
assign atanh[7] = 64;
assign atanh[8] = 32;
assign atanh[9] = 16;
assign atanh[10] = 8;
assign atanh[11] = 4;
assign atanh[12] = 2;
assign atanh[13] = 1;

// Q(3,13) --> multiply by 2^13
reg dk[0:N];
integer k = 0; // for looping
reg signed[15:0] xs[0:N], ys[0:N], zs[0:N];

always@(posedge clk or negedge rst)begin
if(!rst)begin
    x <= 0; y <= 0; z <= 0;
    for(k = 1; k <= N; k = k + 1)begin
        xs[k] <= 0; ys[k] <= 0; zs[k] <= 0; dk[k] <= 0;
    end
end else begin
if(load)begin
    x <= x0; y <= y0; z <= z0;
    for(k = 1; k <= N; k = k + 1)begin
        xs[k] <= 0; ys[k] <= 0; zs[k] <= 0; dk[k] <= 0;
    end
end else begin
    xs[1] <= x0;
    ys[1] <= y0;
    zs[1] <= z0;
    dk[1] <= mode ? ~(ys[1][15]) : zs[1][15];

    // if dk is neg, flip the operations. else, keep the same.
    xs[2] <= dk[1] ? (xs[1] - (ys[1] >>> 1)) : (xs[1] + (ys[1] >>> 1));
    ys[2] <= dk[1] ? (ys[1] - (xs[1] >>> 1)) : (ys[1] + (xs[1] >>> 1));
    zs[2] <= dk[1] ? (zs[1] + atanh[1]) : (zs[1] - atanh[1]);
    dk[2] <= mode ? ~(ys[2][15]) : zs[2][15];

    xs[3] <= dk[2] ? (xs[2] - (ys[2] >>> 2)) : (xs[2] + (ys[2] >>> 2));
    ys[3] <= dk[2] ? (ys[2] - (xs[2] >>> 2)) : (ys[2] + (xs[2] >>> 2));
    zs[3] <= dk[2] ? (zs[2] + atanh[2]) : (zs[2] - atanh[2]);
    dk[3] <= mode ? ~(ys[3][15]) : zs[3][15];
    
    xs[4] <= dk[3] ? (xs[3] - (ys[3] >>> 3)) : (xs[3] + (ys[3] >>> 3));
    ys[4] <= dk[3] ? (ys[3] - (xs[3] >>> 3)) : (ys[3] + (xs[3] >>> 3));
    zs[4] <= dk[3] ? (zs[3] + atanh[3]) : (zs[3] - atanh[3]);
    dk[4] <= mode ? ~(ys[4][15]) : zs[4][15];
    
    xs[5] <= dk[4] ? (xs[4] - (ys[4] >>> 4)) : (xs[4] + (ys[4] >>> 4));
    ys[5] <= dk[4] ? (ys[4] - (xs[4] >>> 4)) : (ys[4] + (xs[4] >>> 4));
    zs[5] <= dk[4] ? (zs[4] + atanh[4]) : (zs[4] - atanh[4]);
    dk[5] <= mode ? ~(ys[5][15]) : zs[5][15];
    
    xs[6] <= dk[5] ? (xs[5] - (ys[5] >>> 5)) : (xs[5] + (ys[5] >>> 5));
    ys[6] <= dk[5] ? (ys[5] - (xs[5] >>> 5)) : (ys[5] + (xs[5] >>> 5));
    zs[6] <= dk[5] ? (zs[5] + atanh[5]) : (zs[5] - atanh[5]);
    dk[6] <= mode ? ~(ys[6][15]) : zs[6][15];
    
    xs[7] <= dk[6] ? (xs[6] - (ys[6] >>> 6)) : (xs[6] + (ys[6] >>> 6));
    ys[7] <= dk[6] ? (ys[6] - (xs[6] >>> 6)) : (ys[6] + (xs[6] >>> 6));
    zs[7] <= dk[6] ? (zs[6] + atanh[6]) : (zs[6] - atanh[6]);
    dk[7] <= mode ? ~(ys[7][15]) : zs[7][15];
    
    xs[8] <= dk[7] ? (xs[7] - (ys[7] >>> 7)) : (xs[7] + (ys[7] >>> 7));
    ys[8] <= dk[7] ? (ys[7] - (xs[7] >>> 7)) : (ys[7] + (xs[7] >>> 7));
    zs[8] <= dk[7] ? (zs[7] + atanh[7]) : (zs[7] - atanh[7]);
    dk[8] <= mode ? ~(ys[8][15]) : zs[8][15];
    
    x <= dk[8] ? (xs[8] - (ys[8] >>> 8)) : (xs[8] + (ys[8] >>> 8));
    y <= dk[8] ? (ys[8] - (xs[8] >>> 8)) : (ys[8] + (xs[8] >>> 8));
    z <= dk[8] ? (zs[8] + atanh[8]) : (zs[8] - atanh[8]);
end
end
end
//your code here=============

endmodule
