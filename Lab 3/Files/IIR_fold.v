`timescale 1ns / 1ps

module IIR_fold(
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
reg[1:0] state, nextstate;
reg[7:0] add1,add2,mul1,mul2;
wire[7:0] addout,mulout;

reg[7:0] m1,m2,m3,m4,a1,a2,a3; // outputs to multiplier/adder from original
reg[7:0] xin,yout,x1,y1,y2;
  
always@(posedge clk or negedge rst)begin
if(~rst)begin
    add1 <= 0;
    add2 <= 0;
    mul1 <= 0;
    mul2 <= 0;
    state <= 0;
    nextstate <= 0;
    a1 <= 0;
    a2 <= 0;
    a3 <= 0;
    m1 <= 0;
    m2 <= 0;
    m3 <= 0;
    m4 <= 0;
    x1 <= 0;
    y1 <= 0;
    y2 <= 0;
    xin <= 0;
    yout <= 0;
end else begin
    case(state)
    0   : begin
            add1 <= m3;
            add2 <= m4;
            a3 <= addout;
            mul1 <= x;
            mul2 <= a;
            m1 <= mulout;
            nextstate <= 1;
            xin <= x;
            end
    1   : begin
            add1 <= a1;
            add2 <= a3;
            a2 <= addout;
            mul1 <= x1;
            mul2 <= b;
            m2 <= mulout;
            nextstate <= 2;
            x1 <= xin;     
            yout <= addout;
            end
    2   : begin
            add1 <= m1;
            add2 <= m2;
            a1 <= addout;
            mul1 <= y2;
            mul2 <= d;
            m4 <= mulout;
            nextstate <= 3;
            y2 <= y1;
            end
    3   : begin
            add1 <= 0;
            add2 <= 0;
            mul1 <= y1;
            mul2 <= c;
            m3 <= mulout;
            nextstate <= 0;
            y1 <= yout;
            end
    endcase
    state <= nextstate;
end
end

assign addout = add1 + add2; // one adder
multiply m0(mul1,mul2,mulout); // one multiplier

assign y = yout;

//your code here=============

endmodule
