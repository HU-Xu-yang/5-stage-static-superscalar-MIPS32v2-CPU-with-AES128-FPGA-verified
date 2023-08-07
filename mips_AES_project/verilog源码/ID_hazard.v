//Core.v在ID stage使用
module ID_hazard (
    input       in_IDEX_MemRd   ,
    input [4:0] in_IDEX_rt_idx  ,
    input [4:0] in_IFID_rs_idx  ,
    input [4:0] in_IFID_rt_idx  ,

    input [1:0] in_IDEX_PCSrc   ,   // for ctrl hazard

    output reg  out_data_hazard ,   // lw-and hazard (lw后跟着一条R指令)
    output reg  out_ctrl_hazard     // beq and bne, j and jal, jr
);

always @(*) begin
    if(in_IDEX_MemRd && (in_IDEX_rt_idx == in_IFID_rs_idx || in_IDEX_rt_idx == in_IFID_rt_idx))
        out_data_hazard = 1;
    else
        out_data_hazard = 0;

    if(in_IDEX_PCSrc != 0)          // PCSrc = 2'b00时表示选择PC+4地址
        out_ctrl_hazard = 1;
    else
        out_ctrl_hazard = 0;
end

endmodule