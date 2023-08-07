module EX_core (
    input        in_AluSrc1     ,
    input        in_AluSrc2     ,
    input [3:0]  in_ALUFun      ,
    input [4:0]  in_Shamt       ,
    input [4:0]  in_rt_idx      ,
    input [4:0]  in_rd_idx      ,
    input [1:0]  in_ctrl_PCSrc  ,
    input        in_ctrl_RegWr  ,
    input [31:0] in_PC_addr     ,
    input [1:0]  in_RegDst      ,

    input [1:0]  in_ForwardA    ,
    input [1:0]  in_ForwardB    ,
    input [31:0] in_ext_imm     ,
    input [31:0] in_IDEX_A      ,   			// A通道alu来自IDEX寄存器的输入
    input [31:0] in_EXMEM_A     ,   		// 来自EXMEM寄存器
    input [31:0] in_MEMWB_A     ,   		// 来自MEMWB寄存器
    input [31:0] in_IDEX_B      ,
    input [31:0] in_EXMEM_B     ,
    input [31:0] in_MEMWB_B     ,

    output [4:0]  out_rd_idx    ,
    output [31:0] out_AluOut    
);

wire [31:0]  ALU_dataA    ;
wire [31:0]  ALU_dataB    ;
wire [31:0]  tmp_dataA    ;
wire [31:0]  tmp_dataB    ;
wire        tmp_jal_flag ;
wire [31:0] tmp_AluOut   ;

assign tmp_jal_flag = ((in_ctrl_PCSrc == 2'b10) && in_ctrl_RegWr) ? 1 : 0;
assign out_AluOut   = tmp_jal_flag ? (in_PC_addr) : tmp_AluOut           ;  // PC地址已在IDEX寄存器加4，这里只要再加4

assign out_rd_idx   = (in_RegDst == 2'b00) ? in_rd_idx :
                      (in_RegDst == 2'b01) ? in_rt_idx :
                      (in_RegDst == 2'b10) ? 5'b1_1111 :                   		 // $31寄存器的地址5'd31
                      in_rd_idx;

EX_alu alu_test(
    .in_ALUFun      ( in_ALUFun  ),
    .in_dataA       ( ALU_dataA  ),
    .in_dataB       ( ALU_dataB  ),
     
    .out_alu_result ( tmp_AluOut )
);
assign tmp_dataA = in_AluSrc1 ? {27'b0, in_Shamt} : in_IDEX_A  ;     	// only for sll, srl
assign tmp_dataB = in_AluSrc2 ? in_ext_imm        : in_IDEX_B  ;

assign ALU_dataA = (in_ForwardA == 2'b00) ? tmp_dataA :
                   (in_ForwardA == 2'b01) ? in_EXMEM_A:
                   (in_ForwardA == 2'b10) ? in_MEMWB_A:
                   tmp_dataA;

assign ALU_dataB = (in_ForwardB == 2'b00) ? tmp_dataB :
                   (in_ForwardB == 2'b01) ? in_EXMEM_B:
                   (in_ForwardB == 2'b10) ? in_MEMWB_B:
                   tmp_dataB;

endmodule