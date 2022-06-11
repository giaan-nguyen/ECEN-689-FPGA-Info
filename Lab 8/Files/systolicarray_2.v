`timescale 1ns / 1ps

module systolicarray_2(
clk,
rst,
mi0,
mi1,
mo
    );

parameter size=8;
parameter decimal=4;

input clk,rst;
//  |0.5 1 |   |1 2|
//  |1  0.5| x |3 4| 
input[4*size-1:0] mi0;//  mi0 = [8][16][16][8] = [0.5][1][1][0.5].
input[4*size-1:0] mi1;//  mi1 = [16][32][48][64] = [1][2][3][4].
output[4*size-1:0] mo;


wire[size-1:0] umi1[3:0];
wire[size-1:0] umi2[3:0];
wire[size-1:0] uoutmi1[3:0];
wire[size-1:0] uoutmi2[3:0];
wire[size-1:0] uout[3:0];
reg[size-1:0] a0,a1,b0,b1;

genvar gi;
generate
    for(gi=0;gi<4;gi=gi+1)begin : genu
        systolicarray_2_unit #(.size(size),.decimal(decimal)) ui(clk,rst,umi1[gi],umi2[gi],0,uoutmi1[gi],uoutmi2[gi],uout[gi]);
    end
endgenerate

// TOP LEFT
assign umi1[0] = a0;
assign umi2[0] = b0;

// TOP RIGHT
assign umi1[1] = a1;
assign umi2[1] = uoutmi2[0];

// BOTTOM LEFT
assign umi1[2] = uoutmi1[0];
assign umi2[2] = b1;

// BOTTOM RIGHT
assign umi1[3] = uoutmi1[1];
assign umi2[3] = uoutmi2[2];

// OUTPUTS
assign mo[7:0] = uout[0];
assign mo[15:8] = uout[2];
assign mo[23:16] = uout[1];
assign mo[31:24] = uout[3];
 
integer n,state;
always@(posedge clk or negedge rst)begin
    if(~rst)begin
    // Start of your code.
        a0 <= 0;
        a1 <= 0;
        b0 <= 0;
        b1 <= 0;
        state <= 0;
    // End of your code.
    end
    else begin
    // Start of your code.
        case(state)
            0 : begin // load in a11 & b11
                    a0 <= mi0[7:0];
                    b0 <= mi1[7:0];
                    state <= 1;
                end
            1 : begin // load in a12 & b21, a21 & b12
                    a0 <= mi0[15:8];
                    a1 <= mi0[23:16];
                    b0 <= mi1[23:16];
                    b1 <= mi1[15:8];
                    state <= 2;
                end
            2 : begin // load in a22 & b22
                    a0 <= 0;
                    a1 <= mi0[31:24];
                    b0 <= 0;
                    b1 <= mi1[31:24];
                    state <= 3;
                end
            3 : begin
                    // wait
                    a1 <= 0;
                    b1 <= 0;
                    state <= 4;
                end
            4 : begin
                    // outputs ready
                    state <= 4;
                end
        endcase
        // End of your code.
    end
end

endmodule
