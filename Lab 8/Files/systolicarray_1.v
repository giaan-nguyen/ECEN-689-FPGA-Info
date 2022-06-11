`timescale 1ns / 1ps

module systolicarray_1(
clk,
rst,
mi0,
mi1,
mor
    );

parameter size=8;
parameter decimal=4;

input clk,rst;
input[4*size-1:0] mi0;
input[4*size-1:0] mi1;
output reg[4*size-1:0] mor;

wire[4*size-1:0] mo;

always@(posedge clk or negedge rst)begin
    if(~rst)begin
        mor<=0;
    end
    else begin
        mor<=mo;
    end
end

wire[size-1:0] umi1[7:0];
wire[size-1:0] umi2[7:0];
wire[size-1:0] uai[7:0];
wire[size-1:0] uoutmi1[7:0];
wire[size-1:0] uoutmi2[7:0];
wire[size-1:0] uout[7:0];

genvar gi;

generate
    for(gi=0;gi<8;gi=gi+1)begin : genu
        systolicarray_1_unit #(.size(size),.decimal(decimal)) ui(umi1[gi],umi2[gi],uai[gi],uoutmi1[gi],uoutmi2[gi],uout[gi]);
    end
endgenerate

// Start of your code.

// FRONT BOTTOM LEFT: inputs a11, b11, 0
assign umi1[0] = mi0[7:0]; // a11
assign umi2[0] = mi1[7:0]; // b11
assign uai[0] = 0;

// BACK BOTTOM LEFT: inputs uoutmi1[0], b12, 0
assign umi1[1] = uoutmi1[0];
assign umi2[1] = mi1[15:8]; // b12
assign uai[1] = 0;

// FRONT BOTTOM RIGHT: inputs a21, uoutmi2[0], 0
assign umi1[2] = mi0[23:16]; // a21
assign umi2[2] = uoutmi2[0];
assign uai[2] = 0;

// BACK BOTTOM RIGHT: inputs uoutmi1[2], uoutmi2[1], 0
assign umi1[3] = uoutmi1[2];
assign umi2[3] = uoutmi2[1];
assign uai[3] = 0;

// FRONT TOP LEFT: inputs a12, b21, uout[0]
assign umi1[4] = mi0[15:8]; // a12
assign umi2[4] = mi1[23:16]; // b21
assign uai[4] = uout[0];
assign mo[7:0] = uout[4]; 

// BACK TOP LEFT: inputs uoutmi1[4], b22, uout[1]
assign umi1[5] = uoutmi1[4];
assign umi2[5] = mi1[31:24]; // b22
assign uai[5] = uout[1];
assign mo[15:8] = uout[5]; 

// FRONT TOP RIGHT: inputs a22, uoutmi2[4], uout[2]
assign umi1[6] = mi0[31:24]; // a22
assign umi2[6] = uoutmi2[4];
assign uai[6] = uout[2];
assign mo[23:16] = uout[6]; 

// BACK TOP RIGHT: inputs uoutmi1[6], uoutmi2[5], uout[3]
assign umi1[7] = uoutmi1[6];
assign umi2[7] = uoutmi2[5];
assign uai[7] = uout[3];
assign mo[31:24] = uout[7]; 

// End of your code.

endmodule
