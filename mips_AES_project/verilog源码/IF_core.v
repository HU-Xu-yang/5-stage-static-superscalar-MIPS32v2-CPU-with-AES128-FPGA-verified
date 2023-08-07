module IF_core (
    input           in_rst_n            ,
    input           in_data_hazard      ,
    input  [31:0]   in_IFID_PC_plus4    ,
    input  [1:0]    in_PCSrc            ,
    input  [31:0]   in_branch_PC_addr   ,   // for beq, bne
    input  [31:0]   in_jump_PC_addr     ,   // for j, jal
    input  [31:0]   in_jr_PC_addr       ,   // for jr

    output [31:0]   out_instruct        ,
    output [31:0]   out_PC_plus4        
);

wire [31:0] PC_plus4;  
wire [31:0] PC_Rd_addr;

assign PC_plus4 = in_data_hazard ? (in_IFID_PC_plus4 - 4) : (in_IFID_PC_plus4 + 4);

assign PC_Rd_addr = in_data_hazard      ? (in_IFID_PC_plus4 - 4) : 
                    (in_PCSrc == 2'b00) ? in_IFID_PC_plus4       :
                    (in_PCSrc == 2'b01) ? in_branch_PC_addr      :
                    (in_PCSrc == 2'b10) ? in_jump_PC_addr        :
                    in_jr_PC_addr;


// in_IFID_PC_plus4    ;
assign out_PC_plus4 = in_data_hazard      ? (PC_plus4          + 4) : 
                      (in_PCSrc == 2'b00) ? PC_plus4                :
                      (in_PCSrc == 2'b01) ? (in_branch_PC_addr + 4) :
                      (in_PCSrc == 2'b10) ? (in_jump_PC_addr   + 4) :
                      (in_jr_PC_addr + 4);

IF_icache icache_test(
    .in_rst_n       (   in_rst_n         ),
    .in_addr        (   PC_Rd_addr[9:2]  ),
    .out_instruct   (   out_instruct     )
);

endmodule