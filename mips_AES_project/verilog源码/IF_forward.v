//Core.v在IF stage使用。增加此旁路，以解决reg做不到既读又写的问题
module IF_forward (
    input        in_MEMWB_RegWr     ,
    input  [4:0] in_MEMWB_rd_idx    ,
    input  [4:0] in_IFID_rs_idx     ,
    input  [4:0] in_IFID_rt_idx     ,

    output       out_Mem_forwardA   ,
    output       out_Mem_forwardB 
);

assign out_Mem_forwardA = (in_MEMWB_RegWr && (in_MEMWB_rd_idx != 0) && (in_MEMWB_rd_idx == in_IFID_rs_idx)) ? 1 : 0;
assign out_Mem_forwardB = (in_MEMWB_RegWr && (in_MEMWB_rd_idx != 0) && (in_MEMWB_rd_idx == in_IFID_rt_idx)) ? 1 : 0;

endmodule