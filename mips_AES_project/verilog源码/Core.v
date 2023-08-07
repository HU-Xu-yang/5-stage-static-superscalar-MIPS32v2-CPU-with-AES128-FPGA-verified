module Core (
    input           rst_n       ,
    input           clk         ,

    output [127:0]  cipherkey   ,
    output [127:0]  state
);


// IF stage阶段的wire和reg
reg [31:0] IFID_PC_plus4;
reg [31:0] IFID_instruct;

wire [31:0] IF_out_PC_plus4 ;
wire [31:0] IF_out_instruct ;

wire IF_forwardA;
wire IF_forwardB;

// ID stage阶段的wire和reg
wire [31:0] ID_out_PC_addr          ;   		// PC+4
wire [31:0] ID_out_branch_PC_addr   ;   	// beq and bne PC addr
wire [31:0] ID_out_jump_PC_addr     ;   	// j and jal PC addr
wire [31:0] ID_out_jr_PC_addr       ;   		// jr pc addr

wire [31:0] ID_out_rs_data          ;
wire [31:0] ID_out_rt_data          ;
wire [31:0] ID_out_imm_extend       ;
wire [4:0]  ID_out_ins_shamt        ;
wire [4:0]  ID_out_rs_idx           ;
wire [4:0]  ID_out_rt_idx           ;
wire [4:0]  ID_out_rd_idx           ;
wire [1:0]  ID_out_ctrl_PCSrc       ;
wire [1:0]  ID_out_ctrl_RegDst      ;
wire        ID_out_ctrl_RegWr       ;
wire        ID_out_ctrl_AluSrc1     ;
wire        ID_out_ctrl_AluSrc2     ;
wire        ID_out_ctrl_MemWr       ;
wire        ID_out_ctrl_MemRd       ;
wire        ID_out_ctrl_LuiOp       ;
wire [3:0]  ID_out_ctrl_AluFun      ;
wire        ID_out_ctrl_MemToReg    ;
wire        ID_out_I_type_ins       ;

reg  [31:0] IDEX_PC_addr            ;
reg  [31:0] IDEX_branch_PC_addr     ;
reg  [31:0] IDEX_jump_PC_addr       ;
reg  [31:0] IDEX_jr_PC_addr         ;

reg  [31:0] IDEX_rs_data            ;
reg  [31:0] IDEX_rt_data            ;
reg  [31:0] IDEX_imm_extend         ;
reg  [4:0]  IDEX_ins_shamt          ;
reg  [4:0]  IDEX_rs_idx             ;
reg  [4:0]  IDEX_rt_idx             ;
reg  [4:0]  IDEX_rd_idx             ;
reg  [1:0]  IDEX_ctrl_PCSrc         ;
reg  [1:0]  IDEX_ctrl_RegDst        ;
reg         IDEX_ctrl_RegWr         ;
reg         IDEX_ctrl_AluSrc1       ;
reg         IDEX_ctrl_AluSrc2       ;
reg         IDEX_ctrl_MemWr         ;
reg         IDEX_ctrl_MemRd         ;
reg         IDEX_ctrl_LuiOp         ;
reg  [3:0]  IDEX_ctrl_AluFun        ;
reg         IDEX_ctrl_MemToReg      ;
reg         IDEX_I_type_ins         ;

wire ID_data_hazard;
wire ID_ctrl_hazard;

// EX stage阶段的wire和reg
wire [4:0]  EX_out_rd_idx   ;
wire [31:0] EX_out_AluOut   ;

reg  [4:0]  EXMEM_rd_idx    ;
reg  [31:0] EXMEM_AluOut    ;
reg  [31:0] EXMEM_rt_data   ;
reg         EXMEM_RegWr     ;
reg         EXMEM_MemWr     ;
reg         EXMEM_MemRd     ;
reg         EXMEM_MemToReg  ;

wire [1:0] EX_forwardA;
wire [1:0] EX_forwardB;

// MEM stage阶段的wire和reg
wire [31:0] MEM_out_Rd_data      ;

reg         MEMWB_ctrl_MemToReg  ;
reg         MEMWB_RegWr          ;
reg  [4:0]  MEMWB_rd_idx         ;
reg  [31:0] MEMWB_AluOut         ;
reg  [31:0] MEMWB_MemOut         ;


// WB stage阶段的wire和reg
wire [31:0] WB_out_data;


// *****************************************
// IF stage
// 定义输出寄存器 IFID
// choose PC_plus4, branch_PC(beq and bne), jump_PC(j and jal), jr_PC
// if data_hazard, make nextPC = nextPC
// *****************************************
IF_core IF_core_test(
    .in_rst_n           (   rst_n                   ),
    .in_data_hazard     (   ID_data_hazard          ),
    .in_IFID_PC_plus4   (   IFID_PC_plus4           ),
    .in_PCSrc           (   IDEX_ctrl_PCSrc         ),
    .in_branch_PC_addr  (   IDEX_branch_PC_addr     ),      	// for beq, bne
    .in_jump_PC_addr    (   IDEX_jump_PC_addr       ),      	// for j, jal
    .in_jr_PC_addr      (   IDEX_jr_PC_addr         ),      		// for jr

    .out_PC_plus4       (   IF_out_PC_plus4         ),
    .out_instruct       (   IF_out_instruct         )
);

IF_forward IF_forward_test(
    .in_MEMWB_RegWr     (   MEMWB_RegWr             ),
    .in_MEMWB_rd_idx    (   MEMWB_rd_idx            ),
    .in_IFID_rs_idx     (   IFID_instruct[25:21]    ),
    .in_IFID_rt_idx     (   IFID_instruct[20:16]    ),

    .out_Mem_forwardA   (   IF_forwardA             ),
    .out_Mem_forwardB   (   IF_forwardB             )
);

// *****************************************
// ID stage
// 定义输出寄存器 IDEX
// 指令解码
// data_hazard and ctrl_hazard
// *****************************************
ID_core ID_core_test(
    .in_clk             (   clk                     ),
    .in_rst_n           (   rst_n                   ),
    .in_regWrite        (   MEMWB_RegWr             ),
    .in_w_rd_addr       (   MEMWB_rd_idx            ),
    .in_instruct        (   IFID_instruct           ),
    .in_write_data      (   WB_out_data             ),
    .in_PC_addr         (   IFID_PC_plus4           ),
    .in_data_hazard     (   ID_data_hazard          ),     		 // lw-and hazard (lw后跟着一条R指令)
    .in_ctrl_hazard     (   ID_ctrl_hazard          ),     		 // beq and bne, j and jal, jr

    .in_IF_forwardA     (   IF_forwardA             ),
    .in_IF_forwardB     (   IF_forwardB             ),
    .in_EX_out_rd_idx   (   EX_out_rd_idx           ),
    .in_EX_out_AluOut   (   EX_out_AluOut           ),

    .out_PC_addr        (   ID_out_PC_addr          ),     		  // = in_PC_addr
    .out_branch_PC_addr (   ID_out_branch_PC_addr   ),      // for beq, bne
    .out_jump_PC_addr   (   ID_out_jump_PC_addr     ),        // for j, jal
    .out_jr_PC_addr     (   ID_out_jr_PC_addr       ),     	 // for jr

    .out_rs_data        (   ID_out_rs_data          ),
    .out_rt_data        (   ID_out_rt_data          ),
    .out_imm_extend     (   ID_out_imm_extend       ),   	// 无符号和有符号扩展，lui的扩展（16位的imm放到高16位）

    .out_ins_shamt      (   ID_out_ins_shamt        ),      	// 移位运算的移位数
    
    .out_ins_rs_idx     (   ID_out_rs_idx           ),
    .out_ins_rt_idx     (   ID_out_rt_idx           ),     	 	 // I-type指令的写入地址是rt
    .out_ins_rd_idx     (   ID_out_rd_idx           ),     	  	// R-type指令的写入地址是rd
                                                            		  	// jr指令将PC指向$31，这个地址在EX级指定
    .out_ctrl_PCSrc     (   ID_out_ctrl_PCSrc       ),        	// 控制PC地址选择的多选器信号，PC自增地址、beq和bne地址、jr跳转地址、j和jal跳转地址
    .out_ctrl_RegDst    (   ID_out_ctrl_RegDst      ),      	// 0 for ID_EX_rd_idx, 1 for IDEX_rt_idx, 2 for $31(in EX stage)(jal instruction)
    .out_ctrl_RegWr     (   ID_out_ctrl_RegWr       ),      
    .out_ctrl_AluSrc1   (   ID_out_ctrl_AluSrc1     ),      	// 0 for rs_data, 1 for shamt (only for sll, srl)
    .out_ctrl_AluSrc2   (   ID_out_ctrl_AluSrc2     ),       	// 0 for rt_data, 1 for immediate(signed or zero extended)
    .out_ctrl_MemWr     (   ID_out_ctrl_MemWr       ),             
    .out_ctrl_MemRd     (   ID_out_ctrl_MemRd       ),             
    .out_ctrl_LuiOp     (   ID_out_ctrl_LuiOp       ),        	// 要把imm16放到高16位
    .out_ctrl_AluFun    (   ID_out_ctrl_AluFun      ),            
    .out_ctrl_MemToReg  (   ID_out_ctrl_MemToReg    ),      // alu输出、mem输出、jal要把PC+8的值写回寄存器$31
    .out_I_type_ins     (   ID_out_I_type_ins       ),

    .out_cipherkey      (   cipherkey               ),
    .out_state          (   state                   )
);

ID_hazard ID_hazard_test(
    .in_IDEX_MemRd    (   IDEX_ctrl_MemRd   ),
    .in_IDEX_rt_idx   (   IDEX_rt_idx       ),
    .in_IFID_rs_idx   (   ID_out_rs_idx     ),
    .in_IFID_rt_idx   (   ID_out_rt_idx     ),
    .in_IDEX_PCSrc    (   IDEX_ctrl_PCSrc   ),

    .out_data_hazard  (   ID_data_hazard    ),
    .out_ctrl_hazard  (   ID_ctrl_hazard    )
);


// *****************************************
// EX stage
// 定义输出寄存器 EXMEM
// 算术运算、逻辑运算、移位运算、比较运算（slt）
// 旁路单元
// *****************************************
EX_core EX_core_test(
    .in_AluSrc1     (   IDEX_ctrl_AluSrc1   ),
    .in_AluSrc2     (   IDEX_ctrl_AluSrc2   ),
    .in_ALUFun      (   IDEX_ctrl_AluFun    ),
    .in_Shamt       (   IDEX_ins_shamt      ),
    .in_rt_idx      (   IDEX_rt_idx         ),
    .in_rd_idx      (   IDEX_rd_idx         ),
    .in_ctrl_PCSrc  (   IDEX_ctrl_PCSrc     ),
    .in_ctrl_RegWr  (   IDEX_ctrl_RegWr     ),
    .in_PC_addr     (   IDEX_PC_addr        ),
    .in_RegDst      (   IDEX_ctrl_RegDst    ),

    .in_ForwardA    (   EX_forwardA         ),
    .in_ForwardB    (   EX_forwardB         ),
    .in_ext_imm     (   IDEX_imm_extend     ),
    .in_IDEX_A      (   IDEX_rs_data        ),      		// A通道alu来自IDEX寄存器的输入
    .in_EXMEM_A     (   EXMEM_AluOut        ),      	// 来自EXMEM寄存器
    .in_MEMWB_A     (   WB_out_data         ),      	// 来自MEMWB寄存器
    .in_IDEX_B      (   IDEX_rt_data        ),
    .in_EXMEM_B     (   EXMEM_AluOut        ),
    .in_MEMWB_B     (   WB_out_data         ), 

    .out_rd_idx     (   EX_out_rd_idx       ),     		 
    .out_AluOut     (   EX_out_AluOut       )      		
);

EX_forward EX_forward_test(
    .in_EXMEM_RegWr     (   EXMEM_RegWr     ),
    .in_MEMWB_RegWr     (   MEMWB_RegWr     ),
    .in_EXMEM_rd_idx    (   EXMEM_rd_idx    ),
    .in_MEMWB_rd_idx    (   MEMWB_rd_idx    ),
    .in_IDEX_rs_idx     (   IDEX_rs_idx     ),
    .in_IDEX_rt_idx     (   IDEX_rt_idx     ),
    .in_ID_I_type_ins   (   IDEX_I_type_ins ),

    .out_forwardA       (   EX_forwardA     ),
    .out_forwardB       (   EX_forwardB     )
);


// *****************************************
// MEM stage
// 定义输出寄存器 MEMWB
// *****************************************
MEM_core MEM_core_test(
    .in_clk         (   clk             ),
    .in_rst_n       (   rst_n           ),
    .in_MemWr       (   EXMEM_MemWr     ),
    .in_MemRd       (   EXMEM_MemRd     ),
    .in_Wr_data     (   EXMEM_rt_data   ),
    .in_WrRd_addr   (   EXMEM_AluOut    ),

    .out_Rd_data    (   MEM_out_Rd_data )
);

// *****************************************
// WB stage
// 
// *****************************************
assign WB_out_data = MEMWB_ctrl_MemToReg ? MEMWB_MemOut : MEMWB_AluOut;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin        					// 初始化所有寄存器
        // 初始化IF寄存器
        IFID_PC_plus4       <= 0    ;
        IFID_instruct       <= 0    ;

        // 初始化ID寄存器
        IDEX_PC_addr        <= 0    ;
        IDEX_rs_data        <= 0    ;
        IDEX_rt_data        <= 0    ;
        IDEX_imm_extend     <= 0    ;
        IDEX_ins_shamt      <= 0    ;
        IDEX_rs_idx         <= 0    ;
        IDEX_rt_idx         <= 0    ;
        IDEX_rd_idx         <= 0    ;
        IDEX_ctrl_PCSrc     <= 0    ;
        IDEX_ctrl_RegDst    <= 0    ;
        IDEX_ctrl_RegWr     <= 0    ;
        IDEX_ctrl_AluSrc1   <= 0    ;
        IDEX_ctrl_AluSrc2   <= 0    ;
        IDEX_ctrl_MemWr     <= 0    ;
        IDEX_ctrl_MemRd     <= 0    ;
        IDEX_ctrl_LuiOp     <= 0    ;
        IDEX_ctrl_AluFun    <= 0    ;
        IDEX_ctrl_MemToReg  <= 0    ;
        IDEX_I_type_ins     <= 0    ;

        // 初始化EX寄存器
        EXMEM_rd_idx        <= 0    ;
        EXMEM_AluOut        <= 0    ;
        EXMEM_rt_data       <= 0    ;
        EXMEM_RegWr         <= 0    ;
        EXMEM_MemWr         <= 0    ;
        EXMEM_MemRd         <= 0    ;
        EXMEM_MemToReg      <= 0    ;
 
        // 初始化MEM寄存器 
        MEMWB_ctrl_MemToReg <= 0    ;
        MEMWB_RegWr         <= 0    ;
        MEMWB_rd_idx        <= 0    ;
        MEMWB_AluOut        <= 0    ;
        MEMWB_MemOut        <= 0    ;

        // WB寄存器初始化
            // 不需要操作寄存器

    end
    else begin        
        // IF寄存器
        IFID_PC_plus4       <= IF_out_PC_plus4         ;
        IFID_instruct       <= IF_out_instruct         ;

        // ID寄存器
        IDEX_PC_addr        <= ID_out_PC_addr          ;
        IDEX_branch_PC_addr <= ID_out_branch_PC_addr   ;
        IDEX_jump_PC_addr   <= ID_out_jump_PC_addr     ;
        IDEX_jr_PC_addr     <= ID_out_jr_PC_addr       ;

        IDEX_rs_data        <= ID_out_rs_data          ;
        IDEX_rt_data        <= ID_out_rt_data          ;
        IDEX_imm_extend     <= ID_out_imm_extend       ;
        IDEX_ins_shamt      <= ID_out_ins_shamt        ;
        IDEX_rs_idx         <= ID_out_rs_idx           ;
        IDEX_rt_idx         <= ID_out_rt_idx           ;
        IDEX_rd_idx         <= ID_out_rd_idx           ;
        IDEX_ctrl_PCSrc     <= ID_out_ctrl_PCSrc       ;
        IDEX_ctrl_RegDst    <= ID_out_ctrl_RegDst      ;
        IDEX_ctrl_RegWr     <= ID_out_ctrl_RegWr       ;
        IDEX_ctrl_AluSrc1   <= ID_out_ctrl_AluSrc1     ;
        IDEX_ctrl_AluSrc2   <= ID_out_ctrl_AluSrc2     ;
        IDEX_ctrl_MemWr     <= ID_out_ctrl_MemWr       ;
        IDEX_ctrl_MemRd     <= ID_out_ctrl_MemRd       ;
        IDEX_ctrl_LuiOp     <= ID_out_ctrl_LuiOp       ;
        IDEX_ctrl_AluFun    <= ID_out_ctrl_AluFun      ;
        IDEX_ctrl_MemToReg  <= ID_out_ctrl_MemToReg    ;
        IDEX_I_type_ins     <= ID_out_I_type_ins       ;

        // EX寄存器
        EXMEM_rd_idx        <= EX_out_rd_idx           ;
        EXMEM_AluOut        <= EX_out_AluOut           ;
        EXMEM_rt_data       <= IDEX_rt_data            ;
        EXMEM_RegWr         <= IDEX_ctrl_RegWr         ;
        EXMEM_MemWr         <= IDEX_ctrl_MemWr         ;
        EXMEM_MemRd         <= IDEX_ctrl_MemRd         ;
        EXMEM_MemToReg      <= IDEX_ctrl_MemToReg      ;
 
        // MEM寄存器
        MEMWB_ctrl_MemToReg <= EXMEM_MemToReg          ;
        MEMWB_RegWr         <= EXMEM_RegWr             ;
        MEMWB_rd_idx        <= EXMEM_rd_idx            ;
        MEMWB_AluOut        <= EXMEM_AluOut            ;
        MEMWB_MemOut        <= MEM_out_Rd_data         ;

        // WB寄存器
        // 不需要操作寄存器
    end

end
endmodule