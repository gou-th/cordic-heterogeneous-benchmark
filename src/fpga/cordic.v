`timescale 1ns / 1ps
module cordic(
    input clk,
    input rst,
    input btn,
    input signed [15:0] angle_in,
    output [15:0] led_out
);
//using 16-bit signed fixed point
//the sine and cosine value outputs
wire signed [15:0] sin_out;
wire signed [15:0] cos_out;
localparam signed [15:0] K=16'd9949;  // inital gain (K=0.60725) scaled by 2^14

reg signed [15:0] gamma [0:15]; //pre-computer arctan table = arctan(2^-i) * 2^14
initial begin
  gamma[0]=16'd12868;
  gamma[1]=16'd7596;
  gamma[2] =16'd4014;
  gamma[3]=16'd2037;
  gamma[4]=16'd1023;
  gamma[5]=16'd512;
  gamma[6]=16'd256;
  gamma[7]=16'd128;
  gamma[8]=16'd64;
  gamma[9]=16'd32;
  gamma[10]=16'd16;
  gamma[11]=16'd8;
  gamma[12]=16'd4;
  gamma[13]=16'd2;
  gamma[14]=16'd1;
  gamma[15]=16'd0;
end

//pipeline registers for cos (x), sine(y) and error angle(z)
reg signed [15:0] x [0:16];
reg signed [15:0] y [0:16];
reg signed [15:0] z [0:16];

//Stage 0 - Initial values 
always @(posedge clk or posedge rst) begin 
    if (rst) begin
        x[0]<=16'd0;
        y[0]<=16'd0;
        z[0]<=16'd0;
    end else begin
        x[0]<=K;
        y[0]<=16'd0;
        z[0]<=angle_in;
    end
end

//Stage 1-16
genvar i;
generate 
    for (i=0; i<16;i=i+1) begin
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                x[i+1]<=16'd0;
                y[i+1]<=16'd0;
                z[i+1]<=16'd0;
            end else begin
                if (z[i][15]==1'b1) begin          //sign bit of Z
                //rotate clockwise 
                    x[i+1]<=x[i]+(y[i]>>>i);
                    y[i+1]<=y[i]-(x[i]>>>i);
                    z[i+1]<=z[i]+gamma[i];
                end else begin
                //rotate anti-clockwise
                    x[i+1]<=x[i]-(y[i]>>>i);
                    y[i+1]<=y[i]+(x[i]>>>i);
                    z[i+1]<=z[i]-gamma[i];
                end
             end
         end
     end
endgenerate

assign cos_out=x[16];
assign sin_out=y[16];     

assign led_out=btn?sin_out:cos_out;                                  

endmodule