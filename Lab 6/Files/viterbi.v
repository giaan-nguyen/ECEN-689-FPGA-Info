`timescale 1ns / 1ps

module viterbi(
clk,
rst,
codein, // input: code word; length: lenin = 10.
state_out, // input: state; length: 2^(k-1)*2*r = 16.
codeout, // output: decoded message; length: lenout = 5.
finish // output: 1 bit flag signal.
    );

parameter r=2; // Number of parity bits in each cycle.
parameter K=3; // Max convolutional window size.
parameter lenin=10; // Length of the input code word.
parameter lenout=5; // Length of the output decoded message.

parameter maskcode=(1<<r)-1; // 11.
parameter maskstate=(1<<(K-1))-1; // 11.
parameter maskpath=(1<<K)-1; // 111. take lower 3 bits.

input clk,rst;
input[lenin-1:0] codein;
input[(1<<(K-1))*2*r-1:0] state_out; // input: state; length: 2^(k-1)*2*r = 16.
output reg[lenout-1:0] codeout;
output reg finish;

reg[r-1:0] code; // code word in each cycle.
wire[(1<<(K-1))*2*r-1:0] dis_path_out; // length: 16.

// Branch Metric Unit
bmu #(.r(r),.K(K)) b0(
clk,
rst,
code,
state_out,
dis_path_out
    );

reg[lenout*K-1:0] paths[(1<<(K-1))-1:0]; //each K: [input dir 0/1: 1bit][last state: (K-1)bits]
// paths: 5*3 * 4

reg[(1<<(K-1))*8-1:0] dis[1:0]; // 4*8
wire[(1<<(K-1))*K-1:0] pmu_path_out;
wire[(1<<(K-1))*8-1:0] pmu_dis_out;

// Path Metric Unit
pmu #(.r(r),.K(K)) p0(
clk,
rst,
dis[1],
dis_path_out,
pmu_path_out,
pmu_dis_out
    );


integer state, count, n, min_state;
always@(posedge clk or negedge rst)begin
    if(~rst)begin
        // Start of your code
        codeout <= 0;
        finish <= 0;
        dis[0][31:24] <= 255; // set highest number for infinity
        dis[0][23:16] <= 255; 
        dis[0][15:8] <= 255;
        dis[0][7:0] <= 0;
        state <= 0;
        count <= 0;
        n <= 1;
        // End of your code
    end
    else begin
        // Start of your code
        case(state)
            0 : begin // start of forward calcs, shift in 2 bits of codein
                    code <= (codein >> (10-2*n));
                    dis[1] <= dis[0];
                    state <= 1;
                end
            1 : begin // counter to wait until pmu output is ready
                    if(count < 4)begin
                        count <= count + 1;
                    end
                    else begin
                        count <= 0;
                        state <= 2;
                    end
                end
            2 : begin
                    dis[0] <= pmu_dis_out; // save pmu dis output
                    paths[n-1] <= pmu_path_out; // save pmu path output
                    if(n < lenout)begin // if length n is not 5, then iterate
                        n <= n + 1;
                        state <= 0;
                    end
                    else begin // otherwise end of forward calcs
                        n <= 0;
                        state <= 3;
                    end
                end
            3 : begin // start backward tracing, find min
                    if((dis[0][31:24] <= dis[0][23:16]) && (dis[0][31:24] <= dis[0][15:8]) && (dis[0][31:24] <= dis[0][7:0]))begin
                        min_state <= 3;
                    end
                    else if((dis[0][23:16] <= dis[0][31:24]) && (dis[0][23:16] <= dis[0][15:8]) && (dis[0][23:16] <= dis[0][7:0]))begin
                        min_state <= 2;
                    end
                    else if((dis[0][15:8] <= dis[0][31:24]) && (dis[0][15:8] <= dis[0][23:16]) && (dis[0][15:8] <= dis[0][7:0]))begin
                        min_state <= 1;
                    end
                    else begin
                        min_state <= 0;
                    end
                    state <= 4;
                end
            4 : begin // decoding using recent pmu_path_out
                    case(min_state)
                        0 : begin
                                min_state <= (pmu_path_out[0]) ? 1 : 0; // check if s0 == 1
                                codeout[n] <= (pmu_path_out[0]) ? 0 : 0;
                            end
                        1 : begin
                                min_state <= (pmu_path_out[3]) ? 3 : 2; // check if s1 == 1
                                codeout[n] <= (pmu_path_out[3]) ? 0 : 0;
                            end
                        2 : begin
                                min_state <= (pmu_path_out[6]) ? 1 : 0; // check if s2 == 1
                                codeout[n] <= (pmu_path_out[6]) ? 1 : 1;
                            end
                        3 : begin
                                min_state <= (pmu_path_out[9]) ? 3 : 2; // check if s3 == 1
                                codeout[n] <= (pmu_path_out[9]) ? 1 : 1;
                            end
                    endcase
                    n <= n + 1;
                    state <= 5;
                end
            5 : begin // decoding using paths
                    if(n < lenout)begin
                        case(min_state)
                            0 : begin
                                    min_state <= (paths[lenout-1-n][0]) ? 1 : 0; // check if s0 == 1
                                    codeout[n] <= (paths[lenout-1-n][0]) ? 0 : 0;
                                end
                            1 : begin
                                    min_state <= (paths[lenout-1-n][3]) ? 3 : 2; // check if s1 == 1
                                    codeout[n] <= (paths[lenout-1-n][3]) ? 0 : 0;
                                end
                            2 : begin
                                    min_state <= (paths[lenout-1-n][6]) ? 1 : 0; // check if s2 == 1
                                    codeout[n] <= (paths[lenout-1-n][6]) ? 1 : 1;
                                end
                            3 : begin
                                    min_state <= (paths[lenout-1-n][9]) ? 3 : 2; // check if s3 == 1
                                    codeout[n] <= (paths[lenout-1-n][9]) ? 1 : 1;
                                end
                        endcase
                        n <= n + 1;
                    end
                    else begin
                        finish <= 1;
                    end
                end
        endcase

        // End of your code


    end
end

endmodule
