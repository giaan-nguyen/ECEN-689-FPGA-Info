`timescale 1ns / 1ps

module huffmandecode(
clk,
rst,
code,
hufftable,
huffsymbol,
data,
length,
finish
    );
input clk,rst;
input[15:0] code;
input[8*16-1:0] hufftable;
input[8*256-1:0] huffsymbol;
output reg[7:0] data;
output reg[7:0] length;
output reg finish;

wire[7:0] hufftbl[15:0];
assign hufftbl[0] = hufftable[7:0];
assign hufftbl[1] = hufftable[15:8];
assign hufftbl[2] = hufftable[23:16];
assign hufftbl[3] = hufftable[31:24];
assign hufftbl[4] = hufftable[39:32];
assign hufftbl[5] = hufftable[47:40];
assign hufftbl[6] = hufftable[55:48];
assign hufftbl[7] = hufftable[63:56];
assign hufftbl[8] = hufftable[71:64];
assign hufftbl[9] = hufftable[79:72];
assign hufftbl[10] = hufftable[87:80];
assign hufftbl[11] = hufftable[95:88];
assign hufftbl[12] = hufftable[103:96];
assign hufftbl[13] = hufftable[111:104];
assign hufftbl[14] = hufftable[119:112];
assign hufftbl[15] = hufftable[127:120];

wire[7:0] huffsym[255:0];
genvar k;
generate
    for(k = 0; k < 256; k = k+1) begin
        assign huffsym[k] = huffsymbol[(k+1)*8-1:k*8];
    end
endgenerate

integer n; // level number
reg[15:0] upperbound, symcount, index;
reg[1:0] state;
always@(posedge clk or negedge rst)begin
    if(~rst)begin
    // Start of your code ====================================
        finish <= 0;
        data <= 0;
        length <= 0;
        upperbound <= 0;
        symcount <= 0;
        index <= 0;
        n <= 1; // level number
        state <= 0;
    // End of your code ======================================

    end
    else begin
    // Start of your code ====================================
        case(state)
            0 : begin // set up upperbound and symcount
                    upperbound <= upperbound + hufftbl[n-1];
                    symcount <= symcount + hufftbl[n-1];
                    state <= 1;
                end
            1 : begin // check if top n bits is less than upperbound
                    if((code >> (16-n)) < upperbound)begin
                        index <= symcount - upperbound + (code >> (16-n)); // index = symcount - dist
                        state <= 2; 
                    end
                    else begin
                        n <= (n == 16) ? 16 : n+1; // increment (up to 16 bits max)
                        upperbound <= (upperbound << 1); // left shift 
                        state <= 0; // return to setup again
                    end
                end
            2 : begin // finish stuff
                    length <= n;
                    data <= huffsym[index];
                    finish <= 1; // stay in state 1, finish value will trigger a ~rst
                end
        endcase
    // End of your code ======================================    
    end
end

endmodule
