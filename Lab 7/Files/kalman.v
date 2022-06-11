`timescale 1ns / 1ps

module kalman(
clk,
rst,
n,      // Input: Index of the inputs.
u,      // Input: Scalar: Acceleration.
z,      // Input: 1x2 Z Vector; Measurement of x.
x0,     // Initial state of x.
P0,     // Initial state of ve
F,      // Input: 2x2 F Matrix.
B,      // Input: 2x1 B Vector.
Q,      // Input: 2x2 Q Matrix.
H,      // Input: 2x2 H Matrix.
R,      // Input: 2x2 R Matrix.
no,     // Output: n_out.
xo,     // Output: x_out.
outen   // Output: output enable: a flag signal. 
    );

parameter len=2;		// # of input size.
parameter dsize=16;		// Width of each data.
parameter decimal=10;	// Width of fraction.

input clk,rst;
input[dsize-1:0] n;
input[dsize-1:0] u;
input[dsize*len-1:0] z;
input[dsize*len-1:0] x0;
input[dsize*len*len-1:0] P0;
input[dsize*len*len-1:0] F,H,Q,R;
input[dsize*len-1:0] B;
output reg[dsize-1:0] no;
output reg[dsize*len-1:0] xo;
output reg outen;


reg[dsize-1:0] mi[1:0][3:0];
wire[dsize-1:0] mo[3:0];

wire[dsize*2*2-1:0] mmin1;
wire[dsize*2*2-1:0] mmin2;
wire[dsize*2*2-1:0] mmout;

assign mmin1[dsize-1:0]=mi[0][0];            
assign mmin1[2*dsize-1:dsize]=mi[0][1];
assign mmin1[3*dsize-1:2*dsize]=mi[0][2];
assign mmin1[4*dsize-1:3*dsize]=mi[0][3];

assign mmin2[dsize-1:0]=mi[1][0];
assign mmin2[2*dsize-1:dsize]=mi[1][1];
assign mmin2[3*dsize-1:2*dsize]=mi[1][2];
assign mmin2[4*dsize-1:3*dsize]=mi[1][3];

assign mo[0]=mmout[dsize-1:0];
assign mo[1]=mmout[2*dsize-1:dsize];
assign mo[2]=mmout[3*dsize-1:2*dsize];
assign mo[3]=mmout[4*dsize-1:3*dsize];


/////////////////////////////////////////////////////////////////////
//  | mo[0] mo[1] |     | mi[0][0] mi[0][1] |   | mi[1][0] mi[1][1] |
//  | mo[2] mo[3] | =   | mi[0][2] mi[0][3] | x | mi[1][2] mi[1][3] |
/////////////////////////////////////////////////////////////////////
matmul22 #(.size(dsize),.decimal(decimal)) mm0(mmin1,mmin2,mmout);

reg[dsize-1:0] divin;
wire[dsize-1:0] divout;

// divout = 1 / divin.
divider #(.size(dsize),.decimal(decimal)) d0(divin,divout);


// reg[dsize-1:0] nk;
// reg zenk;
reg[dsize*len-1:0] uk,zk,xkm,xkp,yk;    // Vector; Width = 16x2 = 32.
reg[dsize*len*len-1:0] Pkm,Kk,Pkp;      // Matrix; Width = 16x2x2 = 64.

reg[dsize*len*len-1:0] Inv;
integer state;
always@(posedge clk or negedge rst)begin
    if(~rst)begin
        Pkm <= 0; // Pk-
        Pkp <= P0; // Pk+
        Kk <= 0;
        xkm <= 0; // xk-
        xkp <= x0; // xk+
        yk <= 0;
        zk <= z;
        no <= 0;
        xo <= 0;
        Inv <= 0;
        state <= 0;
        outen <= 0;
    end
    else begin
        case(state)
            0 : begin // predicted state estimate: F*xkp
                    mi[0][0] <= F[0];
                    mi[0][1] <= F[1];
                    mi[0][2] <= F[2];
                    mi[0][3] <= F[3];
                    mi[1][0] <= xkp[0];
                    mi[1][1] <= 0;
                    mi[1][2] <= xkp[1];
                    mi[1][3] <= 0;
                    outen <= 0;
                    state <= 1;
                end
            1 : begin // predicted state estimate: xkm = F*xkp + B*u
                    xkm[0] <= mo[0] + B[0]*u;
                    xkm[1] <= mo[2] + B[1]*u;
                    state <= 2;
                end
            2 : begin // predicted error covariance: F*Pkp
                    mi[0][0] <= F[0];
                    mi[0][1] <= F[1];
                    mi[0][2] <= F[2];
                    mi[0][3] <= F[3];
                    mi[1][0] <= Pkp[0];
                    mi[1][1] <= Pkp[1];
                    mi[1][2] <= Pkp[2];
                    mi[1][3] <= Pkp[3];
                    state <= 3;
                end
            3 : begin // predicted error covariance: (F*Pkp)*F^T
                    mi[0][0] <= mo[0];
                    mi[0][1] <= mo[1];
                    mi[0][2] <= mo[2];
                    mi[0][3] <= mo[3];
                    mi[1][0] <= F[0];
                    mi[1][1] <= F[2];
                    mi[1][2] <= F[1];
                    mi[1][3] <= F[3];
                    state <= 4;
                end
            4 : begin // predicted error covariance: Pkm = F*Pkp*F^T + Q
                    Pkm[0] <= mo[0] + Q[0];
                    Pkm[1] <= mo[1] + Q[1];
                    Pkm[2] <= mo[2] + Q[2];
                    Pkm[3] <= mo[3] + Q[3];
                    state <= 5;
                end
            5 : begin // measurement residual: H*xkm
                    mi[0][0] <= H[0];
                    mi[0][1] <= H[1];
                    mi[0][2] <= H[2];
                    mi[0][3] <= H[3];
                    mi[1][0] <= xkm[0];
                    mi[1][1] <= 0;
                    mi[1][2] <= xkm[1];
                    mi[1][3] <= 0;
                    state <= 6;
                end
            6 : begin // measurement residual: yk = z - H*xkm
                    yk[0] <= z[0] - mo[0];
                    yk[1] <= z[1] - mo[2];
                    state <= 7;
                end
            7 : begin // Kalman gain: H*Pkm
                    mi[0][0] <= H[0];
                    mi[0][1] <= H[1];
                    mi[0][2] <= H[2];
                    mi[0][3] <= H[3];
                    mi[1][0] <= Pkm[0];
                    mi[1][1] <= Pkm[1];
                    mi[1][2] <= Pkm[2];
                    mi[1][3] <= Pkm[3];
                    state <= 8;
                end
            8 : begin // Kalman gain: (H*Pkm)*H^T
                    mi[0][0] <= mo[0];
                    mi[0][1] <= mo[1];
                    mi[0][2] <= mo[2];
                    mi[0][3] <= mo[3];
                    mi[1][0] <= H[0];
                    mi[1][1] <= H[2];
                    mi[1][2] <= H[1];
                    mi[1][3] <= H[3];
                    state <= 9;
                end
            9 : begin // Kalman gain: (R + H*Pkm*H^T)
                    Inv[0] <= R[0] + mo[0];
                    Inv[1] <= R[1] + mo[1];
                    Inv[2] <= R[2] + mo[2];
                    Inv[3] <= R[3] + mo[3];
                    state <= 10;
                end
            10: begin // Kalman gain: det((R + H*Pkm*H^T))
                    divin <= Inv[0]*Inv[3] - Inv[1]*Inv[2];
                    Inv[1] <= -Inv[1];
                    Inv[2] <= -Inv[2];
                    state <= 11;
                end
            11: begin // Kalman gain: Inv = (R + H*Pkm*H^T)^-1
                    Inv[0] <= Inv[3] * divout;
                    Inv[1] <= Inv[1] * divout;
                    Inv[2] <= Inv[2] * divout;
                    Inv[3] <= Inv[0] * divout;
                    state <= 12;
                end
            12: begin // Kalman gain: Pkm*H^T
                    mi[0][0] <= Pkm[0];
                    mi[0][1] <= Pkm[1];
                    mi[0][2] <= Pkm[2];
                    mi[0][3] <= Pkm[3];
                    mi[1][0] <= H[0];
                    mi[1][1] <= H[2];
                    mi[1][2] <= H[1];
                    mi[1][3] <= H[3];
                    state <= 13;
                end
            13: begin // Kalman gain: (Pkm*H^T)*Inv
                    mi[0][0] <= mo[0];
                    mi[0][1] <= mo[1];
                    mi[0][2] <= mo[2];
                    mi[0][3] <= mo[3];
                    mi[1][0] <= Inv[0];
                    mi[1][1] <= Inv[1];
                    mi[1][2] <= Inv[2];
                    mi[1][3] <= Inv[3];
                    state <= 14;
                end
            14: begin // Kalman gain: Kk = (Pkm*H^T)*Inv
                    Kk[0] <= mo[0];
                    Kk[1] <= mo[1];
                    Kk[2] <= mo[2];
                    Kk[3] <= mo[3];
                    state <= 15;
                end
            15: begin // updated state estimate: Kk*yk
                    mi[0][0] <= Kk[0];
                    mi[0][1] <= Kk[1];
                    mi[0][2] <= Kk[2];
                    mi[0][3] <= Kk[3];
                    mi[1][0] <= yk[0];
                    mi[1][1] <= 0;
                    mi[1][2] <= yk[1];
                    mi[1][3] <= 0;
                    state <= 16;
                end
            16: begin // updated state estimate: xkp = xkm + Kk*yk
                    xkp[0] <= xkm[0] + mo[0];
                    xkp[1] <= xkm[1] + mo[2];
                    state <= 17;
                end
            17: begin // updated error covariance: Kk*H
                    mi[0][0] <= Kk[0];
                    mi[0][1] <= Kk[1];
                    mi[0][2] <= Kk[2];
                    mi[0][3] <= Kk[3];
                    mi[1][0] <= H[0];
                    mi[1][1] <= H[1];
                    mi[1][2] <= H[2];
                    mi[1][3] <= H[3];
                    state <= 18;
                end
            18: begin // updated error covariance: (I-Kk*H)*Pkm
                    mi[0][0] <= 1 - mo[0];
                    mi[0][1] <= -mo[1];
                    mi[0][2] <= -mo[2];
                    mi[0][3] <= 1 - mo[3];
                    mi[1][0] <= Pkm[0];
                    mi[1][1] <= Pkm[1];
                    mi[1][2] <= Pkm[2];
                    mi[1][3] <= Pkm[3];
                    state <= 19;
                end
            19: begin
                    Pkp[0] <= mo[0];
                    Pkp[1] <= mo[1];
                    Pkp[2] <= mo[2];
                    Pkp[3] <= mo[3];
                    no <= n;
                    xo <= xkp;
                    outen <= 1;
                    state <= 0;
                end
        endcase
    end
end

endmodule
