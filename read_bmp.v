`timescale 1 ns/1 ns

module test_t;
integer fileId, cc,out_file,i;
reg [7:0] bmp_data [0:2000000];
reg clk;
reg [7:0] data;
integer bmp_width, bmp_hight, data_start_index, bmp_size;

 
initial 
begin
  fileId = $fopen("xxxxxxx.bmp","rb");
  out_file = $fopen("xxxxxxx.txt","w+");​
  cc = $fread(bmp_data, fileId);
  bmp_width = {bmp_data[21],bmp_data[20],bmp_data[19],bmp_data[18]};
  bmp_hight = {bmp_data[25],bmp_data[24],bmp_data[23],bmp_data[22]};
  data_start_index = {bmp_data[13],bmp_data[12],bmp_data[11],bmp_data[10]};
  bmp_size = {bmp_data[5],bmp_data[4],bmp_data[3],bmp_data[2]};
  clk =1;
  i=0;
  forever #10 clk=~clk;   
end

 
always@(posedge clk )
  begin
    data<=bmp_data[i];
    i<=i+1;
  end
$fclose(fileId);
$fwrite(out_file,"%d",$bmp_data)​​;
endmodule



