`timescale 1ns / 1ps

module top_cordic_hyper(

    );

wire clk;
wire memctl;

wire[15:0] memaddraxi;
wire[7:0] memdinaxi;
wire memwenaxi;

reg trigger;

//1st port, controlled by arm or fpga
wire[15:0] memaddra;
wire[7:0] memdina;
wire memwena;
wire[7:0] memdouta;

//2nd port, controlled by fpga
reg[15:0] memaddrb;
reg[7:0] memdinb;
reg memwenb;
wire[7:0] memdoutb;

//fpga controlled memory ports
reg[15:0] memaddrfpga;
reg[7:0] memdinfpga;
reg memwenfpga;

assign memaddra=memctl?memaddraxi:memaddrfpga;
assign memdina=memctl?memdinaxi:memdinfpga;
assign memwena=memctl?memwenaxi:memwenfpga;

datatrans_sys_wrapper mw0
       (.axiclk(clk),
        .memaddr(memaddraxi),
        .memctl(memctl),
        .memdin(memdinaxi),
        .memdout(memdouta),
        .memwen(memwenaxi),
        .triggerin(trigger));

blk_mem_gen_0 b0
  (
      clk,
      memwena,
      memaddra,
      memdina,
      memdouta,
      clk,
      memwenb,
      memaddrb,
      memdinb,
      memdoutb
  );

reg[15:0] x0,y0,z0;
wire[15:0] x,y,z;
reg mode,load;
reg[15:0] xr,yr,zr;

cordic_hyper c0(
clk,
~memctl,
mode,
load,
x0,
y0,
z0,
x,
y,
z
    );
    

reg[7:0] i,j;

reg[7:0] state;

reg[15:0] count;

always@(posedge clk)begin
	if(memctl)begin
	    state<=0;
	    count<=0;
	    trigger<=0;
	    
	    memwenfpga<=0;
	    memaddrfpga<=0;
	    memdinfpga<=0;
	    
	    memwenb<=0;
	    memaddrb<=0;
	    memdinb<=0;
	end 
	else begin
		case(state)
		0:begin
		  load<=1;
		  mode<=0;
		  if(count>=2)begin
		    case(count)
		    2:begin
		      x0<=memdoutb;
		    end
		    3:begin
		      x0<=(memdoutb<<8)|x0;
		    end
		    4:begin
              y0<=memdoutb;
            end
            5:begin
              y0<=(memdoutb<<8)|y0;
            end
            6:begin
              z0<=memdoutb;
            end
            7:begin
              z0<=(memdoutb<<8)|z0;
              state<=state+1;
            end
		    endcase
		  end
		  count<=count+1;
		  memwenb<=0;
          memaddrb<=memaddrb+1;
		end
		1:begin
		  memwenfpga<=0;
          memaddrfpga<=0;
          memdinfpga<=0;
		  memwenb<=0;
          memaddrb<=0;
          memdinb<=0;
          count<=0;
          state<=state+1;
		end
		2:begin
		  load<=0;
		  if(count==11)begin
		    xr=x;
		    yr=y;
		    zr=z;
		    count<=0;
		    state<=state+1;
		    memwenb<=1;
            memaddrb<=11;
            memdinb<=0;
		  end
		  else begin
		    count<=count+1;
		  end
		end
		3:begin
		  case(count)
          0:begin
            memdinb<=xr&16'hff;
          end
          1:begin
            memdinb<=xr>>8;
          end
          2:begin
            memdinb<=yr&16'hff;
          end
          3:begin
            memdinb<=yr>>8;
          end
          4:begin
            memdinb<=zr&16'hff;
          end
          5:begin
            memdinb<=zr>>8;
          end
          7:begin
            state<=state+1;
          end
          endcase
          count<=count+1;
		  memaddrb<=memaddrb+1;
		end
		4:begin
           memwenfpga<=0;
           memaddrfpga<=0;
           memdinfpga<=0;
           memwenb<=0;
           memaddrb<=0;
           memdinb<=0;
           trigger<=1;
		end
		endcase
	end
end

endmodule
