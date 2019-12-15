`timescale 1ns / 1ps

/*读FIFO数据，写入到匹配文件中*/

module left_readFIFO(
	input	clk,
	input	rst,
	
	input		empty,
	input[7:0]	dataFromFIFO,
	input		i_valid,
	input		read_request,
	
	output	reg	readEn,
	
	output wire[7:0]	row1_temp,
	output wire[7:0]	row2_temp,
	output wire[7:0]	row3_temp,
	output wire		o_tempVaild
);
	
reg[19:0]	valid_counts;		//读出的有效数据个数，1280*800最多只需要20位

wire	fullOfShiftRAM;		//用来指示行缓存是否已满
assign	fullOfShiftRAM = ( valid_counts < 768 )	?	0 : 1 ;

reg dataValid;

assign o_tempVaild = fullOfShiftRAM && dataValid;
/********************************************/

/*************************************************************************************************************************/
reg[2:0]		state_2;

always@( posedge clk or negedge rst)	  //也得用状态机，否则没办法将 valid_counts 清零
begin 
	if(!rst)
		begin
			valid_counts <= 0;
			state_2 <= 0;
		end
	else
		begin
			case( state_2 )
				0:
					begin
						if( i_valid )
							begin
								valid_counts <= valid_counts + 1;
								state_2 <= 0;
							end
						else
							begin
								valid_counts <= valid_counts;
								state_2 <= 0;
							end
					end
				default:
					begin
						valid_counts <= 0;
						state_2 <= 0;
					end
			endcase
		end
end 
/********************************************/
always @(posedge clk or negedge rst) 
begin
	if( i_valid )
		dataValid <= 1;
	else
		dataValid <= 0;
end
/********************************************/
reg[3:0]	state;

always@(posedge clk or negedge rst)
begin
	if(!rst)
		begin
			state <= 0;
			readEn <= 1'b0;
		end
	else
		begin
			case(state)
			0:
				begin
					if( !empty )	//表示FIFO中已有数据，开始读取
						begin
							readEn <= 1;
							state <= 1;	
						end
					else
						begin
							readEn	<= 0;
							state <= 0;
						end
				end
			1:		//得到有效数据和数据有效信号
				begin
					if( !fullOfShiftRAM )	//此时行缓存寄存器未满
						begin
							if(	!empty )	//FIFO不空
								begin
									readEn <= 1'b1;
									state <= 1;
								end
							else
								begin
									readEn <= 1'b0;
									state <= 1;
								end
						end
					else //寄存器已满
						begin
							readEn <= 1'b0;
							state <= 2;
						end
				end
			2:
				begin
					if( read_request ) 
						begin
							readEn <= 1'b1;
							state <= 2;
						end
					else 
						begin
							readEn <= 1'b0;
							state <= 2;
						end
				end		
			
			// 4:		//等待请求数据信号
			// 	begin
			// 		if( !frame_end )
			// 			begin
			// 				if( data_requst )
								
			// 				else
			// 					begin
			// 						readEn <= 0;
			// 						o_BRAM_requst <= 0;
			// 						state <= 4;
			// 					end
			// 			end
			// 		else
			// 			begin
			// 				readAddr <= 0;
			// 				readEn <= 0;
			// 				o_BRAM_requst <= 0;
			// 				state <= 0;
			// 			end
			// 	end
			// 5:
			// 	begin

			// 		readEn <= 1'b1;
			// 		o_BRAM_requst <= 0;
			// 		state <= 6;
			// 	end
			// 6:
			// 	begin
			// 		readEn <= 1'b0;
			// 		readAddr <= readAddr + 1;
			// 		o_BRAM_requst <= 0;
			// 		state <= 4;
			// 	end
			// 7:
			// 	begin
			// 		if(1== init_start)	//表示BRAM中已经存好数据，可以开始读取
			// 			begin
			// 				readEn <= 1;
			// 				state <= 5;		//需要跳转到等待状态，，需要保持一个时钟才能输出有效数据
			// 			end
			// 		else		//BRAM中还没存好数据，等待
			// 			begin
			// 				readEn	<= 0;
			// 				state <= 7;
			// 			end
			// 		readAddr <= readAddr;
			// 		dataValid <= 0;
			// 		o_BRAM_requst <= 0;
			default:
				begin
					state <= 0;
					readEn <= 1'b0;
				end
			endcase
		end
end

/****************************************************/
//每次CE上升沿写入一个数据。depth个上升沿后数据输出

shift_BRAM 	shift_3 (		
	.CLK				(clk),  					// input wire CLK
	.D					(dataFromFIFO),      					// input wire [7 : 0] D
	.CE					(i_valid),
	.Q					(row3_temp)     						// output wire [7 : 0] Q
);
shift_BRAM 	shift_2 (
	.CLK				(clk),  				// input wire CLK
	.D					(row3_temp),      				// input wire [7 : 0] D
	.CE					(i_valid),
	.Q					(row2_temp)      					// output wire [7 : 0] Q
);
shift_BRAM 	shift_1 (
	.CLK(clk),  				// input wire CLK
	.D(row2_temp),      				// input wire [7 : 0] D
	.CE(i_valid),
	.Q(row1_temp)     					// output wire [7 : 0] Q
);



endmodule

