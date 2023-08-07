module ID_core (
    input        in_clk             ,
    input        in_rst_n           ,
    input        in_regWrite        ,
    input [4:0]  in_w_rd_addr       ,
    input [31:0] in_instruct        ,
    input [31:0] in_write_data      ,
    input [31:0] in_PC_addr         ,
    input        in_data_hazard     ,        // lw-and hazard (lw后跟着一条R指令)
    input        in_ctrl_hazard     ,        // beq and bne, j and jal, jr

    input        in_IF_forwardA     ,
    input        in_IF_forwardB     ,
    input [31:0] in_forward_data    ,

    input [4:0]  in_EX_out_rd_idx   ,
    input [31:0] in_EX_out_AluOut   ,

    output [31:0]  out_PC_addr       ,       	// = in_PC_addr
    output [31:0]  out_branch_PC_addr,       // for beq, bne
    output [31:0]  out_jump_PC_addr  ,       // for j, jal
    output [31:0]  out_jr_PC_addr    ,       // for jr

    output [31:0]  out_rs_data       ,
    output [31:0]  out_rt_data       ,
    output [31:0]  out_imm_extend    ,       // 无符号和有符号扩展，lui的扩展（16位的imm放到高16位）

    output [4:0]   out_ins_shamt     ,       // 移位运算的移位数

    output [4:0]   out_ins_rs_idx    ,
    output [4:0]   out_ins_rt_idx    ,       // I-type指令的写入地址是rt
    output [4:0]   out_ins_rd_idx    ,       // R-type指令的写入地址是rd
                                             		// jr指令将PC指向$31，这个地址在EX级指定

    output [1:0]   out_ctrl_PCSrc    ,       // 控制PC地址选择的多选器信号，PC自增地址、beq和bne地址、jr跳转地址、j和jal跳转地址
    output [1:0]   out_ctrl_RegDst   ,       // 0 for ID_EX_rd_idx, 1 for IDEX_rt_idx, 2 for $31(in EX stage)(jal instruction)
    output reg     out_ctrl_RegWr    ,       
    output         out_ctrl_AluSrc1  ,       // 0 for rs_data, 1 for shamt (only for sll, srl)
    output         out_ctrl_AluSrc2  ,       // 0 for rt_data, 1 for immediate(signed or zero extended)
    output reg     out_ctrl_MemWr    ,       
    output         out_ctrl_MemRd    ,       
    output         out_ctrl_LuiOp    ,       		// 1: 需要将imm16放到高16位
    output [3:0]   out_ctrl_AluFun   ,       
    output         out_ctrl_MemToReg ,       // alu输出 与 PC+8(jal需要将PC+8的值写回寄存器$31)、mem输出 （PC+8也是通过alu运算的，所以两个通道就行了）
    output         out_I_type_ins    ,

    output [127:0] out_cipherkey     ,
    output [127:0] out_state         
);

wire [4:0]   ins_rs_idx     ;
wire [4:0]   ins_rt_idx     ;
wire [4:0]   ins_rd_idx     ;
wire [15:0]  ins_imm16      ;
reg  [31:0]  zero_ext_imm   ;
reg  [31:0]  sign_ext_imm   ;
wire [31:26] ins_31_26      ;
wire [5:0]   ins_5_0        ;
wire [1:0]   tmp_ctrl_PC_op ;
reg  [1:0]   tmp_ctrl_PCSrc ;
wire [25:0]  ins_jump_addr  ;
wire         tmp_ctrl_RegWr ;
wire         tmp_ctrl_MemWr ;

// for IF forward wire
wire [31:0]  tmp_reg_rs_data;
wire [31:0]  tmp_reg_rt_data;

wire [31:0]  tmp_beq_rs_data;
wire [31:0]  tmp_beq_rt_data;

wire [31:0]  tmp_bne_rs_data;
wire [31:0]  tmp_bne_rt_data;

wire         tmp_beq_flag   ;
wire         tmp_bne_flag   ;
wire         tmp_j_jal_flag ;
wire         tmp_jr_flag    ;
wire         ext_op         ;    // 这个控制信号是在本级使用的

assign tmp_beq_rs_data = ((out_ctrl_AluFun[0] == 1) && (in_EX_out_rd_idx == ins_rs_idx) ) ? in_EX_out_AluOut : out_rs_data;
assign tmp_beq_rt_data = ((out_ctrl_AluFun[0] == 1) && (in_EX_out_rd_idx == ins_rt_idx) ) ? in_EX_out_AluOut : out_rt_data;

assign tmp_beq_flag    = (out_ctrl_AluFun[0] == 1) && (tmp_beq_rs_data == tmp_beq_rt_data);

assign tmp_bne_rs_data = ((out_ctrl_AluFun[0] == 0) && (in_EX_out_rd_idx == ins_rs_idx) ) ? in_EX_out_AluOut : out_rs_data;
assign tmp_bne_rt_data = ((out_ctrl_AluFun[0] == 0) && (in_EX_out_rd_idx == ins_rt_idx) ) ? in_EX_out_AluOut : out_rt_data;


assign tmp_bne_flag    = (out_ctrl_AluFun[0] == 0) && (tmp_bne_rs_data != tmp_bne_rt_data);


// assign tmp_bne_flag   = (out_ctrl_AluFun[0] == 0) && (out_rs_data != out_rt_data);
assign tmp_j_jal_flag = tmp_ctrl_PC_op == 2'b10                                  ;
assign tmp_jr_flag    = tmp_ctrl_PC_op == 2'b11                                  ;


assign ins_rs_idx     = in_instruct[25:21];
assign ins_rt_idx     = in_instruct[20:16];
assign ins_rd_idx     = in_instruct[15:11];
assign ins_imm16      = in_instruct[15:0] ;
assign ins_31_26      = in_instruct[31:26];
assign ins_5_0        = in_instruct[5:0]  ;
assign ins_jump_addr  = in_instruct[25:0] ;

assign out_ins_rs_idx = ins_rs_idx        ;
assign out_ins_rt_idx = ins_rt_idx        ;
assign out_ins_rd_idx = ins_rd_idx        ;

assign out_ins_shamt  = in_instruct[10:6] ;

// if IF forward happens, 即要读的寄存器也是要写的寄存器，但做不到同一个周期内、既读又写
assign out_rs_data    = in_IF_forwardA ? in_write_data : tmp_reg_rs_data;
assign out_rt_data    = in_IF_forwardB ? in_write_data : tmp_reg_rt_data;


assign out_PC_addr    = in_PC_addr                          ;
assign out_jr_PC_addr = out_rs_data                         ;

assign out_imm_extend = ext_op ? sign_ext_imm : zero_ext_imm;
assign out_ctrl_PCSrc = tmp_ctrl_PCSrc                      ;

assign out_jump_PC_addr   = {in_PC_addr[31:28], ins_jump_addr, 2'b00};
assign out_branch_PC_addr = in_PC_addr + (sign_ext_imm << 2)         ;


ID_control control_test(
    .in_ins_31_26   (   ins_31_26           ),
    .in_ins_5_0     (   ins_5_0             ),

    .out_PC_op      (   tmp_ctrl_PC_op      ),      // 控制PC地址的操作类型，PC自增、beq和bne、jr跳转、j和jal跳转
    .out_RegDst     (   out_ctrl_RegDst     ),      // 0 for ID_EX_rd_idx, 1 for IDEX_rt_idx, 2 for $31(in EX stage)(jal instruction)
    .out_Reg_Wr     (   tmp_ctrl_RegWr      ),      
    .out_ALUSrc1    (   out_ctrl_AluSrc1    ),      // 0 for rs_data, 1 for shamt
    .out_ALUSrc2    (   out_ctrl_AluSrc2    ),      // 0 for rt_data, 1 for immediate(signed or zero extended)
    .out_Mem_Wr     (   tmp_ctrl_MemWr      ),      
    .out_Mem_Rd     (   out_ctrl_MemRd      ),      
    .out_ext_op     (   ext_op              ),      // 0 for zero extend, 1 for sign extend
    .out_lui_op     (   out_ctrl_LuiOp      ),      // 1: 需要将imm16放到高16位
    .out_ALUFun     (   out_ctrl_AluFun     ),      
    .out_MemToReg   (   out_ctrl_MemToReg   ),      // alu输出 与 PC+8(jal需要将PC+8的值写回寄存器$31)、mem输出 （PC+8也是通过alu运算的，所以两个通道就行了）
    .out_I_type_ins (   out_I_type_ins      )
);

ID_regFile regFile_test(
    .in_clk         (   in_clk         )    ,
    .in_rst_n       (   in_rst_n       )    ,
    .in_regWrite    (   in_regWrite    )    ,
    .in_rs_addr     (   ins_rs_idx     )    ,
    .in_rt_addr     (   ins_rt_idx     )    ,
    .in_write_addr  (   in_w_rd_addr   )    ,
    .in_write_data  (   in_write_data  )    ,

    .out_rs_data    (   tmp_reg_rs_data)    ,
    .out_rt_data    (   tmp_reg_rt_data)    ,
    .out_cipherkey  (   out_cipherkey  )    ,
    .out_state      (   out_state      )    
);

always @(*) begin
    if(ext_op && ins_imm16[15])     sign_ext_imm = {16'hFF_FF, ins_imm16};
    else begin
        sign_ext_imm = {16'h00_00, ins_imm16};
        zero_ext_imm = {16'h00_00, ins_imm16};
    end

    if(tmp_ctrl_PC_op == 2'b01) begin                   // beq or bne instruction
        if     (tmp_beq_flag) tmp_ctrl_PCSrc = 2'b01;   // beq
        else if(tmp_bne_flag) tmp_ctrl_PCSrc = 2'b01;   // bne
        else                  tmp_ctrl_PCSrc = 2'b00;          
    end
    else                      tmp_ctrl_PCSrc = tmp_ctrl_PC_op;

    // 数据冒险只需要将 Reg写信号 和 Mem写信号 置零即可，控制冒险同理
    if(in_data_hazard || in_ctrl_hazard)
        // beq and bne, j and jal, jr really happens. (其中之一满足就行) 
        if(in_data_hazard || tmp_beq_flag || tmp_bne_flag || tmp_j_jal_flag || tmp_jr_flag)
            if(tmp_j_jal_flag && tmp_ctrl_RegWr) out_ctrl_RegWr = 1;        // 判断为jal指令，因为只有jal指令需要将PC+8写回寄存器
            else                                 out_ctrl_RegWr = 0;
        else out_ctrl_MemWr = 0;
    else begin
        out_ctrl_RegWr = tmp_ctrl_RegWr;
        out_ctrl_MemWr = tmp_ctrl_MemWr;
    end


end
endmodule