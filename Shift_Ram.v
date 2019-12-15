reg [5:0]p_11,p_12,p_13;  // 3 * 3 卷积核中的像素点
reg [5:0]p_21,p_22,p_23;
reg [5:0]p_31,p_32,p_33;
reg [8:0]mean_value_add1,mean_value_add2,mean_value_add3;//每一行之和


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        {p_11,p_12,p_13} <= {5'b0,5'b0,5'b0}   ;
        {p_21,p_22,p_23} <= {15'b0,15'b0,15'b0};
        {p_31,p_32,p_33} <= {15'b0,15'b0,15'b0};
    end
    else  begin
     if(per_href_ff0==1&&flag_do==1)begin
        {p_11,p_12,p_13}<={p_12,p_13,row_1};
        {p_21,p_22,p_23}<={p_22,p_23,row_2};
        {p_31,p_32,p_33}<={p_32,p_33,row_3};
     end
     else begin
         {p_11,p_12,p_13}<={5'b0,5'b0,5'b0};
         {p_21,p_22,p_23}<={5'b0,5'b0,5'b0}
         {p_31,p_32,p_33}<={5'b0,5'b0,5'b0}
     end
   end
end



always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        mean_value_add1<=0;
        mean_value_add2<=0;
        mean_value_add3<=0;
    end
    else if(per_href_ff1)begin
        mean_value_add1<=p_11+p_12+p_13;
        mean_value_add2<=p_21+   0   +p_23;
        mean_value_add3<=p_31+p_32+p_33;
    end
end

wire [8:0]mean_value;//8位数之和
wire [5:0]fin_y_data; //平均数，除以8，相当于左移三位。

assign mean_value=mean_value_add1+mean_value_add2+mean_value_add3;
assign fin_y_data=mean_value[8:3];
