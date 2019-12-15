always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
       red_r1   <= 0 ;  
       green_r1 <= 0 ;
       blue_r1  <= 0 ;
    end
    else begin
       red_r1   <= red   * 77 ;        //放大后的值
       green_r1 <= green * 150;
       blue_r1  <= blue  * 29 ;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        Gray <= 0;    // 三个数之和
    end
    else begin
        Gray <= red_r1 + green_r1 + blue_r1;        
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
       post_data_in <= 0;  //输出的灰度数据
    end
    else begin
       post_data_in <= { Gray[13:9], Gray[13:8], Gray[13:9] };//将Gray值赋值给RGB三个通道
    end
end

