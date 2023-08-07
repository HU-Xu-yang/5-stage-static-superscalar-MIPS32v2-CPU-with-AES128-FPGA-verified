module ID_control (
    input [5:0] in_ins_31_26        ,
    input [5:0] in_ins_5_0          ,

    output reg [1:0] out_PC_op      ,   	// 控制PC地址的操作类型，PC自增、beq和bne、jr跳转、j和jal跳转
                                        		// j和jal、jr都无条件跳转，beq和bne需要在外面判断一下才能确定是否跳转
    output reg [1:0] out_RegDst     ,   	// 0 for ID_EX_rd_idx, 1 for IDEX_rt_idx, 2 for $31(in EX stage)(jal instruction)
    output reg       out_Reg_Wr     ,
    output reg       out_ALUSrc1    ,   	// 0 for rs_data, 1 for shamt
    output reg       out_ALUSrc2    ,   	// 0 for rt_data, 1 for immediate(signed or zero extended)
    output reg       out_Mem_Wr     ,
    output reg       out_Mem_Rd     ,
    output reg       out_ext_op     ,   	// 0 for zero extend, 1 for sign extend
    output reg       out_lui_op     ,   	// 1: 需要将imm16放到高16位
    output reg [3:0] out_ALUFun     ,
    output reg       out_MemToReg   ,   // alu输出 与 PC+8(jal需要将PC+8的值写回寄存器$31)、mem输出 （PC+8也是通过alu运算的，所以两个通道就行了）
    output reg       out_I_type_ins 
);

// 定义ALU操作
// 00，算术运算
localparam ADD = 6'b00_00,    
           SUB = 6'b00_01,    // 
// 01，逻辑运算
           AND = 6'b01_00,    
           OR  = 6'b01_01,    // 
           XOR = 6'b01_10,    // 
// 10，移位运算
           SLL = 6'b10_00,    
           SRL = 6'b10_01,    // 
           LUI = 6'b10_10,    // 
// 11，比较运算
           SLT = 6'b11_00,    
           BEQ = 6'b11_01,    // 
           BNE = 6'b11_10;    // 

always @(*) begin
    case(in_ins_31_26)
        6'b00_0000: begin       // R-type instruction
            case(in_ins_5_0)    // R-type ins's function code
                6'b10_0000: begin   // add                    
                    out_PC_op      = 0    ;
                    out_RegDst     = 2'd0 ;
                    out_Reg_Wr     = 1    ;
                    out_ALUSrc1    = 0    ;
                    out_ALUSrc2    = 0    ;
                    out_ALUFun     = ADD  ;
                    out_Mem_Wr     = 0    ;
                    out_Mem_Rd     = 0    ;
                    out_MemToReg   = 0    ;   // 选择ALU输出
                    out_ext_op     = 0    ;   
                    out_lui_op     = 0    ;
                    out_I_type_ins = 0    ;
                end
                6'b10_0010: begin   // sub
                    out_PC_op      = 0    ;
                    out_RegDst     = 2'd0 ;
                    out_Reg_Wr     = 1    ;
                    out_ALUSrc1    = 0    ;
                    out_ALUSrc2    = 0    ;
                    out_ALUFun     = SUB  ;
                    out_Mem_Wr     = 0    ;
                    out_Mem_Rd     = 0    ;
                    out_MemToReg   = 0    ;   // 选择ALU输出
                    out_ext_op     = 0    ;  
                    out_lui_op     = 0    ;
                    out_I_type_ins = 0    ;
                end
                6'b10_0100: begin   // and
                    out_PC_op      = 0    ;
                    out_RegDst     = 2'd0 ;
                    out_Reg_Wr     = 1    ;
                    out_ALUSrc1    = 0    ;
                    out_ALUSrc2    = 0    ;
                    out_ALUFun     = AND  ;
                    out_Mem_Wr     = 0    ;
                    out_Mem_Rd     = 0    ;
                    out_MemToReg   = 0    ;   // 选择ALU输出
                    out_ext_op     = 0    ;   
                    out_lui_op     = 0    ;
                    out_I_type_ins = 0    ;
                end
                6'b10_0101: begin   // or
                    out_PC_op      = 0    ;
                    out_RegDst     = 2'd0 ;
                    out_Reg_Wr     = 1    ;
                    out_ALUSrc1    = 0    ;
                    out_ALUSrc2    = 0    ;
                    out_ALUFun     = OR   ;
                    out_Mem_Wr     = 0    ;
                    out_Mem_Rd     = 0    ;
                    out_MemToReg   = 0    ;   // 选择ALU输出
                    out_ext_op     = 0    ;   
                    out_lui_op     = 0    ;
                    out_I_type_ins = 0    ;
                end
                6'b10_0110: begin   // xor
                    out_PC_op      = 0    ;
                    out_RegDst     = 2'd0 ;
                    out_Reg_Wr     = 1    ;
                    out_ALUSrc1    = 0    ;
                    out_ALUSrc2    = 0    ;
                    out_ALUFun     = XOR  ;
                    out_Mem_Wr     = 0    ;
                    out_Mem_Rd     = 0    ;
                    out_MemToReg   = 0    ;   // 选择ALU输出
                    out_ext_op     = 0    ;   
                    out_lui_op     = 0    ;
                    out_I_type_ins = 0    ;
                end
                6'b10_1010: begin   // slt
                    out_PC_op      = 0    ;
                    out_RegDst     = 2'd0 ;
                    out_Reg_Wr     = 1    ;
                    out_ALUSrc1    = 0    ;
                    out_ALUSrc2    = 0    ;
                    out_ALUFun     = SLT  ;
                    out_Mem_Wr     = 0    ;
                    out_Mem_Rd     = 0    ;
                    out_MemToReg   = 0    ;   // 选择ALU输出
                    out_ext_op     = 0    ;   
                    out_lui_op     = 0    ;
                    out_I_type_ins = 0    ;
                end
                6'b00_0000: begin   // sll
                    out_PC_op      = 0    ;
                    out_RegDst     = 2'd0 ;
                    out_Reg_Wr     = 1    ;
                    out_ALUSrc1    = 1    ;   // 1 for shamt, sll指令正好rs位置为零，所以选择将shamt字段放到rs数据通道
                    out_ALUSrc2    = 0    ;
                    out_ALUFun     = SLL  ;
                    out_Mem_Wr     = 0    ;
                    out_Mem_Rd     = 0    ;
                    out_MemToReg   = 0    ;   // 选择ALU输出
                    out_ext_op     = 0    ;   
                    out_lui_op     = 0    ;    
                    out_I_type_ins = 0    ;              
                end
                6'b00_0010: begin   // srl
                    out_PC_op      = 0    ;
                    out_RegDst     = 2'd0 ;
                    out_Reg_Wr     = 1    ;
                    out_ALUSrc1    = 1    ;   // 1 for shamt, srl指令正好rs位置为零，所以选择将shamt字段放到rs数据通道
                    out_ALUSrc2    = 0    ;
                    out_ALUFun     = SRL  ;
                    out_Mem_Wr     = 0    ;
                    out_Mem_Rd     = 0    ;
                    out_MemToReg   = 0    ;   // 选择ALU输出
                    out_ext_op     = 0    ;   
                    out_lui_op     = 0    ;  
                    out_I_type_ins = 0    ;
                end
                6'b00_1000: begin   // jr, PC的下一个地址是rs寄存器的值
                    out_PC_op      = 2'd3 ;   // 这条指令没有经过EX阶段运算，因为为了解决跳转的冒险，在ID阶段就判断了所有PC跳转值，要在ID_core里面判断
                    out_RegDst     = 2'd0 ;   
                    out_Reg_Wr     = 0    ;
                    out_ALUSrc1    = 0    ;
                    out_ALUSrc2    = 0    ;
                    out_ALUFun     = ADD  ;   // jr指令，注意并没有让jr指令经过EX阶段运算，这个ADD是随意取的
                    out_Mem_Wr     = 0    ;
                    out_Mem_Rd     = 0    ;
                    out_MemToReg   = 0    ;   // 选择ALU输出
                    out_ext_op     = 0    ;  
                    out_lui_op     = 0    ;
                    out_I_type_ins = 0    ;
                end
                default: begin      // 没有写Reg和Mem，相当于nop
                    out_PC_op      = 0    ;
                    out_RegDst     = 2'd0 ;
                    out_Reg_Wr     = 0    ;
                    out_ALUSrc1    = 0    ;
                    out_ALUSrc2    = 0    ;
                    out_ALUFun     = ADD  ;
                    out_Mem_Wr     = 0    ;
                    out_Mem_Rd     = 0    ;
                    out_MemToReg   = 0    ;   // 选择ALU输出
                    out_ext_op     = 0    ;   
                    out_lui_op     = 0    ;
                    out_I_type_ins = 0    ;
                end
            endcase
        end
        6'b00_1000: begin       // addi, Imm-type
            out_PC_op      = 0    ;
            out_RegDst     = 2'd1 ;   // I-type指令，EX阶段rd的来源是rt
            out_Reg_Wr     = 1    ;
            out_ALUSrc1    = 0    ;
            out_ALUSrc2    = 1    ;   // 选择立即数通道
            out_ALUFun     = ADD  ;
            out_Mem_Wr     = 0    ;
            out_Mem_Rd     = 0    ;
            out_MemToReg   = 0    ;   // 选择ALU输出
            out_ext_op     = 1    ;   // sign extend
            out_lui_op     = 0    ;
            out_I_type_ins = 1    ;
        end
        6'b00_1001: begin       // addiu, Imm-type
            out_PC_op      = 0    ;
            out_RegDst     = 2'd1 ;   // I-type指令，EX阶段rd的来源是rt
            out_Reg_Wr     = 1    ;
            out_ALUSrc1    = 0    ;
            out_ALUSrc2    = 1    ;   // 选择立即数通道
            out_ALUFun     = ADD  ;
            out_Mem_Wr     = 0    ;
            out_Mem_Rd     = 0    ;
            out_MemToReg   = 0    ;   // 选择ALU输出
            out_ext_op     = 1    ;   // sign extend
            out_lui_op     = 0    ;
            out_I_type_ins = 1    ;
        end
        6'b00_1100: begin       // andi, Imm-type
            out_PC_op      = 0    ;
            out_RegDst     = 2'd1 ;   // I-type指令，EX阶段rd的来源是rt
            out_Reg_Wr     = 1    ;
            out_ALUSrc1    = 0    ;
            out_ALUSrc2    = 1    ;   // 选择立即数通道
            out_ALUFun     = AND  ;
            out_Mem_Wr     = 0    ;
            out_Mem_Rd     = 0    ;
            out_MemToReg   = 0    ;   // 选择ALU输出
            out_ext_op     = 0    ;   // zero extend
            out_lui_op     = 0    ;
            out_I_type_ins = 1    ;
        end        
        6'b00_1101: begin       // ori, Imm-type
            out_PC_op      = 0    ;
            out_RegDst     = 2'd1 ;   // I-type指令，EX阶段rd的来源是rt
            out_Reg_Wr     = 1    ;
            out_ALUSrc1    = 0    ;
            out_ALUSrc2    = 1    ;   // 选择立即数通道
            out_ALUFun     = OR   ;
            out_Mem_Wr     = 0    ;
            out_Mem_Rd     = 0    ;
            out_MemToReg   = 0    ;   // 选择ALU输出
            out_ext_op     = 0    ;   // zero extend
            out_lui_op     = 0    ;
            out_I_type_ins = 1    ;
        end
        6'b00_1110: begin       // xori, Imm-type
            out_PC_op      = 0    ;
            out_RegDst     = 2'd1 ;   // I-type指令，EX阶段rd的来源是rt
            out_Reg_Wr     = 1    ;
            out_ALUSrc1    = 0    ;
            out_ALUSrc2    = 1    ;   // 选择立即数通道
            out_ALUFun     = XOR  ;
            out_Mem_Wr     = 0    ;
            out_Mem_Rd     = 0    ;
            out_MemToReg   = 0    ;   // 选择ALU输出
            out_ext_op     = 0    ;   // zero extend
            out_lui_op     = 0    ;
            out_I_type_ins = 1    ;
        end
        6'b00_1111: begin       // lui, Imm-type
            out_PC_op      = 0    ;
            out_RegDst     = 2'd1 ;   // I-type指令，EX阶段rd的来源是rt
            out_Reg_Wr     = 1    ;
            out_ALUSrc1    = 0    ;   
            out_ALUSrc2    = 1    ;   // 选择立即数通道
            out_ALUFun     = LUI  ;
            out_Mem_Wr     = 0    ;
            out_Mem_Rd     = 0    ;
            out_MemToReg   = 0    ;   // 选择ALU输出
            out_ext_op     = 0    ;   // zero extend，因为要左移16位，选哪个扩展无所谓
            out_lui_op     = 1    ;   // lui            
            out_I_type_ins = 1    ;
        end
        6'b10_0011: begin       // lw, Imm-type
            out_PC_op      = 0    ;
            out_RegDst     = 2'd1 ;   // I-type指令，EX阶段rd的来源是rt
            out_Reg_Wr     = 1    ;
            out_ALUSrc1    = 0    ;
            out_ALUSrc2    = 1    ;   // 选择立即数通道
            out_ALUFun     = ADD  ;
            out_Mem_Wr     = 0    ;
            out_Mem_Rd     = 1    ;   // read Mem_dcache
            out_MemToReg   = 1    ;   // WB阶段选择Mem输出
            out_ext_op     = 1    ;   // sign extend
            out_lui_op     = 0    ;            
            out_I_type_ins = 1    ;
        end
        6'b10_1011: begin       // sw, Imm-type
            out_PC_op      = 0    ;
            out_RegDst     = 2'd0 ;   // sw指令没有写寄存器，这个值填哪个无所谓
            out_Reg_Wr     = 0    ;   // sw指令没有写寄存器
            out_ALUSrc1    = 0    ;
            out_ALUSrc2    = 1    ;   // 选择立即数通道
            out_ALUFun     = ADD  ;
            out_Mem_Wr     = 1    ;   // write Mem_dcache
            out_Mem_Rd     = 0    ;
            out_MemToReg   = 0    ;   // 选择ALU输出。sw指令没有写寄存器，这个值填哪个无所谓
            out_ext_op     = 1    ;   // sign extend
            out_lui_op     = 0    ;            
            out_I_type_ins = 1    ;
        end
        6'b00_0100: begin       // beq, Imm-type
            out_PC_op      = 2'd1 ;
            out_RegDst     = 2'd0 ;   // beq指令没有写寄存器，这个值无所谓
            out_Reg_Wr     = 0    ;
            out_ALUSrc1    = 0    ;
            out_ALUSrc2    = 1    ;   // 选择立即数通道
            out_ALUFun     = BEQ  ;
            out_Mem_Wr     = 0    ;
            out_Mem_Rd     = 0    ;
            out_MemToReg   = 0    ;   // 选择ALU输出
            out_ext_op     = 1    ;   // sign extend
            out_lui_op     = 0    ;
            out_I_type_ins = 1    ;
        end
        6'b00_0101: begin       // bne, Imm-type
            out_PC_op      = 2'd1 ;
            out_RegDst     = 2'd0 ;   // bne指令没有写寄存器，这个值无所谓
            out_Reg_Wr     = 0    ;
            out_ALUSrc1    = 0    ;
            out_ALUSrc2    = 1    ;   // 选择立即数通道
            out_ALUFun     = BNE  ;
            out_Mem_Wr     = 0    ;
            out_Mem_Rd     = 0    ;
            out_MemToReg   = 0    ;   // 选择ALU输出
            out_ext_op     = 1    ;   // sign extend
            out_lui_op     = 0    ;
            out_I_type_ins = 1    ;
        end        
        6'b00_0010: begin       // j, Jump-type
            out_PC_op      = 2'd2 ;
            out_RegDst     = 2'd0 ;   // j指令没有写寄存器，这个值无所谓
            out_Reg_Wr     = 0    ;
            out_ALUSrc1    = 0    ;
            out_ALUSrc2    = 0    ;   
            out_ALUFun     = ADD  ;   // 无所谓
            out_Mem_Wr     = 0    ;
            out_Mem_Rd     = 0    ;
            out_MemToReg   = 0    ;   // 选择ALU输出
            out_ext_op     = 0    ;   
            out_lui_op     = 0    ;
            out_I_type_ins = 0    ;
        end
        6'b00_0011: begin       // jal, Jump-type
            out_PC_op      = 2'd2 ;
            out_RegDst     = 2'd2 ;   // jal指令要将PC+8写入$31
            out_Reg_Wr     = 1    ;
            out_ALUSrc1    = 0    ;
            out_ALUSrc2    = 0    ;   
            out_ALUFun     = ADD  ;   // 无所谓
            out_Mem_Wr     = 0    ;
            out_Mem_Rd     = 0    ;
            out_MemToReg   = 0    ;   // PC+8, (jal指令的PC+8要写回$31)，从alu通道输出
            out_ext_op     = 0    ;   
            out_lui_op     = 0    ;
            out_I_type_ins = 0    ;
        end
        default: begin          // 没有写回寄存器和写Mem，相当于nop
            out_PC_op      = 0    ;
            out_RegDst     = 2'd0 ;
            out_Reg_Wr     = 0    ;
            out_ALUSrc1    = 0    ;
            out_ALUSrc2    = 0    ;
            out_ALUFun     = ADD  ;
            out_Mem_Wr     = 0    ;
            out_Mem_Rd     = 0    ;
            out_MemToReg   = 0    ;   // 选择ALU输出
            out_ext_op     = 0    ;  
            out_lui_op     = 0    ;
            out_I_type_ins = 0    ;
        end
    endcase
end
endmodule