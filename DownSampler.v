`timescale 1ns/1ps

/*
	Module: DownSampler       "ds.v"
	Function: get data from buf, and downsample the img by 2 for row/col so the 
				size is 25% of original
*/
 
/*
	@din: get row-major data from buf
	@addr: used as enable pin to the buf
	@dout: shows the output
	// since 7500 x 8 bits, so the addr is log2(7500) = 13
*/
 
module DownSampler(	//input [7:0] din,
			input clk,
			input start,
			input rst,
			output [12:0] addr,  // send addr to imagebuffer to retrive data
			output finished
			);
// 7-1 , 10-2 is find the closest %2 number;
parameter row = 75-1, col = 100-2, len = 7500;
 
reg [3:0] test ;
reg [7:0] r, c;
reg [7:0] ro;
reg [7:0] co;
 
// only sample the even-th row and col
//assign valid = (start) && (r<row)&&(r%2==0) && (c<col)&&(c%2==0);
assign valid_r = (start) && (r<row)&&(r%2==0);
assign valid_c = (start) && (c<col)&&(c%2==0);
assign finished = (r>row+1) || (c>col+2);
 
assign addr = ro * (col+2) + co;
/*
always @ * begin
	ro = r;
	co = c;
end
*/
 
always @ * begin
if (!finished) begin
	ro = r;
	co = c;
end
else begin
	ro = 0;
	co = 0;
end
end
 
//state:
 
 
localparam  S0 = 0,
			S1 = 1,  // valid, update row
			S2 = 2,  // valid, update column
			S3 = 3;  // empty
 
// State Reg:
reg [1:0] next_s, curr_s;
 
// followed Cumming registered output style:
always @ (posedge clk) begin
	case (curr_s)
		S0: begin
			r <= 0;
			c <= 0;
			//test <= 0;
		end
		S1: begin
			r <= (c==0)?0:r+2;
			c <= (c<col)?c:0;
			//test <= 1;
		end
		S2: begin
			r <= r;
			c <= c+2;
			//test <= test + 3;
		end
		S3: begin
			r <= 99;
			c <= 100;
			//test <= 19;
		end
	endcase
end
 
// State sync transition
always @ (posedge clk or negedge rst) begin
	if(!rst)
		curr_s <= S0;
	else
		curr_s <= next_s;
end
 
// Conditional state transition
always @ * begin
	next_s = curr_s;
	case (curr_s)
		S0: begin
			if(start) next_s = S1;
			else next_s = S0;
		end
		S1: begin  // outter loop r++;
			if(valid_r) next_s = S2;
			else next_s = S3;
		end
		S2: begin  // inner loop c++; 
			if(valid_c) next_s = S2;
			else next_s = S1;
		end
		S3: begin
			next_s = S3;
		end
	endcase
end
 
endmodule
 
module tb_ds;
 
	reg clk;
	reg start;
	reg rst;
	wire [12:0] addr;
	wire finished;
 
 
DownSampler ds(//din,
			clk,
			start,
			rst,
			addr,  // send addr to imagebuffer to retrive data
			finished
			);
 
always #5 clk = ~clk;
 
 
 
initial begin
	$dumpfile("w.vcd");
	$dumpvars(0, tb_ds);
	//$monitor("addr= %d, time = %g", addr, $time);
	clk = 0;
	rst = 1;
	start = 0;
	#5 rst = 0;
	#1 rst = 1;
	#5 start = 1;
	#9990 $finish;
end
 
endmodule
