module ID_regFile (
    input          in_clk         ,
    input          in_rst_n       ,
    input          in_regWrite    ,
    input  [4:0]   in_rs_addr     ,
    input  [4:0]   in_rt_addr     ,
    input  [4:0]   in_write_addr  ,
    input  [31:0]  in_write_data  ,

    output [31:0]  out_rs_data    ,
    output [31:0]  out_rt_data    ,
    output [127:0] out_cipherkey  ,
    output [127:0] out_state      
);

reg    [31:0] regFile_data [0:31];
integer       i                  ;

assign out_cipherkey = {regFile_data[16], regFile_data[17], regFile_data[18], regFile_data[19]};
assign out_state     = {regFile_data[20], regFile_data[21], regFile_data[22], regFile_data[23]};
assign out_rs_data = regFile_data[in_rs_addr];
assign out_rt_data = regFile_data[in_rt_addr];


 

always @(posedge in_clk) begin
    if(~in_rst_n) begin
        for(i=0; i<32; i=i+1) regFile_data[i] <= 32'b0;
    end
    else begin
        if(in_regWrite && in_write_addr) regFile_data[in_write_addr] <= in_write_data;      // 需要判断，不能写入$0号寄存器
        else begin
            // out_rs_data <= regFile_data[in_rs_addr];
            // out_rt_data <= regFile_data[in_rt_addr];
        end
    end

end


endmodule