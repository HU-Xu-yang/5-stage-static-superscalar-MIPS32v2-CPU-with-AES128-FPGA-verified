// Core.v内的EX stage调用
module EX_forward (
    input            in_EXMEM_RegWr     ,
    input            in_MEMWB_RegWr     ,
    input      [4:0] in_EXMEM_rd_idx    ,
    input      [4:0] in_MEMWB_rd_idx    ,
    input      [4:0] in_IDEX_rs_idx     ,
    input      [4:0] in_IDEX_rt_idx     ,
    input            in_ID_I_type_ins   ,

    output reg [1:0] out_forwardA       ,
    output reg [1:0] out_forwardB 
);

always @(*) begin 
        if(in_EXMEM_RegWr && (in_EXMEM_rd_idx != 0) && (in_EXMEM_rd_idx == in_IDEX_rs_idx))      out_forwardA = 2'b01;
        else if(in_MEMWB_RegWr && (in_MEMWB_rd_idx != 0) && (in_MEMWB_rd_idx == in_IDEX_rs_idx)) out_forwardA = 2'b10;
        else                                                                                     out_forwardA = 2'b00;

        if(in_EXMEM_RegWr && (in_EXMEM_rd_idx != 0) && (in_EXMEM_rd_idx == in_IDEX_rt_idx) && ~in_ID_I_type_ins)       // I型指令，rt与rs不能一样
                                                                                                 out_forwardB = 2'b01;
        else if(in_MEMWB_RegWr && (in_MEMWB_rd_idx != 0) && (in_MEMWB_rd_idx == in_IDEX_rt_idx) && ~in_ID_I_type_ins)  // I型指令，rd占用了rt，有时候I型指令rs和rt一样时，会发生冲突，这个通道是不可能为1的
                                                                                                 out_forwardB = 2'b10;
        else                                                                                     out_forwardB = 2'b00;


end

endmodule