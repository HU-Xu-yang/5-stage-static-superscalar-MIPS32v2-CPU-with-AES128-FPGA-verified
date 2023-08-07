module EX_alu (
    input  [3:0]  in_ALUFun     ,
    input  [31:0] in_dataA      ,   // sll和srl中shamt移位扩展到32位的输入
    input  [31:0] in_dataB      ,

    output [31:0] out_alu_result
);

reg [31:0] arith_result;   			 // 算术运算
reg [31:0] logic_result;  			 // 逻辑运算
reg [31:0] shift_result;   			// 移位运算
reg [31:0] comp_result ;  			 // 比较运算

assign out_alu_result = (in_ALUFun[3:2] == 2'b00)? arith_result :
                        (in_ALUFun[3:2] == 2'b01)? logic_result :
                        (in_ALUFun[3:2] == 2'b10)? shift_result :
                        comp_result; 

wire [4:0] shamt;
assign shamt = in_dataA[4:0];   // sll与srl中的shamt从输入A中取出

always @(*) begin
    case(in_ALUFun[3:2])
        2'b00: begin           			 // 算术运算
            if(in_ALUFun[0] == 0) arith_result = in_dataA + in_dataB;   // 0 for add, 1 for sub
            else                  arith_result = in_dataA - in_dataB;
        end
        2'b01: begin            		// 逻辑运算
            case(in_ALUFun[1:0])
                2'b00:   logic_result = in_dataA & in_dataB;            // and
                2'b01:   logic_result = in_dataA | in_dataB;            // or
                2'b10:   logic_result = in_dataA ^ in_dataB;            // xor
                default: logic_result = 32'b0              ;            // default result
            endcase
        end
        2'b10: begin            		// 移位运算
            case(in_ALUFun[1:0])
                2'b00:   shift_result = in_dataB << shamt;              // sll
                2'b01:   shift_result = in_dataB >> shamt;              // srl
                2'b10:   shift_result = in_dataB << 16   ;              // lui
                default: shift_result = 0                ;              // default result
            endcase
        end
        2'b11: begin            		// 比较运算
            case(in_ALUFun[1:0])
                2'b00: begin    		// SLT
                    if(in_dataA < in_dataB)  comp_result = 1;
                    else                     comp_result = 0;
                end/* beq and bne已经在ID级处理了
                2'b01: begin   			 // BEQ
                    if(in_dataA == in_dataB) comp_result = 1;
                    else                     comp_result = 0;
                end
                2'b10: begin    		// BNE
                    if(in_dataA != in_dataB) comp_result = 1;
                    else                     comp_result = 0;
                end*/
                default:                     comp_result = 0;
            endcase
        end
        default: begin
            arith_result = 32'b0;
            logic_result = 32'b0;
            shift_result = 32'b0;
            comp_result  = 32'b0;
        end
    endcase
end
endmodule