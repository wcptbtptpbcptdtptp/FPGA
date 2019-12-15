`timescale 1ns / 1ps


module gs_filter(
                   input             clk      ,
                   input             rst_n    ,
                   input      [7:0]  din      ,
                   input             din_vld  ,
                   input             din_sop  ,
                   input             din_eop  ,
                   
                   output reg [7:0]  dout     ,
                   output reg        dout_vld ,
                   output reg        dout_sop ,
                   output reg        dout_eop     
                   );
            

 parameter        DATA_WIDTH = 8    ;
 parameter        FIRST_MUX  = 16   ;
 
 reg      [FIRST_MUX-1:0]      gs_0    ;
 reg      [FIRST_MUX-1:0]      gs_1    ;
 reg      [FIRST_MUX-1:0]      gs_2    ;
 
 wire     [DATA_WIDTH-1:0]     taps0   ;
 wire     [DATA_WIDTH-1:0]     taps1   ;
 wire     [DATA_WIDTH-1:0]     taps2   ;
 
 reg      [DATA_WIDTH-1:0]     taps0_ff0;
 reg      [DATA_WIDTH-1:0]     taps0_ff1;


 reg      [DATA_WIDTH-1:0]     taps1_ff0;
 reg      [DATA_WIDTH-1:0]     taps1_ff1;

 reg      [DATA_WIDTH-1:0]     taps2_ff0;
 reg      [DATA_WIDTH-1:0]     taps2_ff1;

 reg                           din_vld_ff0;
 reg                           din_vld_ff1;
 reg                           din_vld_ff2;
 
 reg                           din_sop_ff0;
 reg                           din_sop_ff1;
 reg                           din_sop_ff2;
 
 reg                           din_eop_ff0;
 reg                           din_eop_ff1;
 reg                           din_eop_ff2;
 
 
 //对应关系
 // f(x-1,y-1),  f(x,y-1),  f(x+1,y-1) = Line2_ff[1] Line2_ff[0] Line2
 // f(x-1,y+0),  f(x,y+0),  f(x+1,y+0) = Line1_ff[1] Line1_ff[0] Line1
 // f(x-1,y+1),  f(x,y+1),  f(x+1,y+1) = Line0_ff[1] Line0_ff[0] Line0
 
 
 //高斯滤波公式
 // g(x,y)={f(x-1,y-1)+f(x-1,y+1)+f(x+1,y-1)+f(x+1,y+1)+[f(x-1,y)+f(x,y-1)+f(x+1,y)+f(x,y+1)]*2+f(x,y)*4}/16
 //       =(gs_0+gs_1+gs_2)/16
 
 
  always  @(posedge clk or negedge rst_n)begin
   if(rst_n==1'b0)begin
	   din_vld_ff0 <= 0;
		din_vld_ff1 <= 0;
		din_vld_ff2 <= 0;
		din_sop_ff0 <= 0;
		din_sop_ff1 <= 0;
		din_sop_ff2 <= 0;
		din_eop_ff0 <= 0;
		din_eop_ff1 <= 0;
		din_eop_ff2 <= 0;
   end
	else begin
	   din_vld_ff0 <= din_vld      ;
		din_vld_ff1 <= din_vld_ff0  ;
		din_vld_ff2 <= din_vld_ff1  ;
		din_sop_ff0 <= din_sop      ;
		din_sop_ff1 <= din_sop_ff0  ;
		din_sop_ff2 <= din_sop_ff1  ;
		din_eop_ff0 <= din_eop      ;
		din_eop_ff1 <= din_eop_ff0  ;
		din_eop_ff2 <= din_eop_ff1  ;
	end
 end
 
 
 always  @(posedge clk or negedge rst_n)begin
   if(rst_n==1'b0)begin
	   taps0_ff0 <= 0 ;
		taps0_ff1 <= 0 ;
		taps1_ff0 <= 0 ;
		taps1_ff1 <= 0 ;
		taps2_ff0 <= 0 ;
		taps2_ff1 <= 0 ;
	end
	else if(din_vld_ff0)begin
		taps0_ff0 <= taps0     ;
		taps0_ff1 <= taps0_ff0 ;
		taps1_ff0 <= taps1     ;
		taps1_ff1 <= taps1_ff0 ;
		taps2_ff0 <= taps2     ;
		taps2_ff1 <= taps2_ff0 ;   
	end
 end
 
 always  @(posedge clk or negedge rst_n)begin
   if(rst_n==1'b0)begin
	   gs_0 <= 0 ;
	end 
	else if(din_vld_ff1)begin
	   gs_0 <= (taps0_ff1 + taps1_ff1*2 + taps2_ff1);
	end
 end  
 
  always  @(posedge clk or negedge rst_n)begin
   if(rst_n==1'b0)begin
	   gs_1 <= 0 ;
	end 
	else if(din_vld_ff1)begin
	   gs_1 <= (taps0_ff0*2 + taps1_ff0*4 + taps2_ff0*2);
	end
 end  
 
 
  always  @(posedge clk or negedge rst_n)begin
   if(rst_n==1'b0)begin
	   gs_2 <= 0 ;
	end 
	else if(din_vld_ff1)begin
	   gs_2 <= (taps0 + taps1*2 + taps2);
	end
 end  
 
 always  @(posedge clk or negedge rst_n)begin
   if(rst_n==1'b0)begin
	   dout <= 0;
	end
	else if(din_vld_ff2)begin
	   dout <= (gs_0 + gs_1 + gs_2) >> 4 ;
   end 
 end
 
always  @(posedge clk or negedge rst_n)begin
   if(rst_n==1'b0)begin
	   dout_sop <= 0;
	end 
	else if(din_sop_ff2)begin
	   dout_sop <= 1'b1;
	end 
	else begin
	   dout_sop <= 1'b0;
	end 
end 
 
always  @(posedge clk or negedge rst_n)begin
   if(rst_n==1'b0)begin
	   dout_vld <= 0;
	end 
	else if(din_vld_ff2)begin
	   dout_vld <= 1'b1;
	end 
	else begin
	   dout_vld <= 1'b0;
	end 
end 
 
always  @(posedge clk or negedge rst_n)begin
   if(rst_n==1'b0)begin
	   dout_eop <= 0;
	end 
	else if(din_eop_ff2)begin
	   dout_eop <= 1'b1;
	end 
	else begin
	   dout_eop <= 1'b0;
	end 
end 
 
 
 
 
 
 matrix      M_3_3(
	                .clken(din_vld),
	                .clock(clk),
	                .shiftin(din),
	                //.shiftout(dout),
	                .taps0x(taps0),
	                .taps1x(taps1),
	                .taps2x(taps2)
						 );
						 
endmodule

