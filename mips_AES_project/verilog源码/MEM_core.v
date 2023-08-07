module MEM_core (
    input         in_clk        ,
    input         in_rst_n      ,
    input         in_MemWr      ,
    input         in_MemRd      ,

    input [31:0]  in_Wr_data    ,
    input [31:0]  in_WrRd_addr  ,

    output [31:0] out_Rd_data   
); 

MEM_dcache dcahce_test(
    .in_clk       (   in_clk        ),
    .in_rst_n     (   in_rst_n      ),
    .in_Wr_flag   (   in_MemWr      ),
    .in_Rd_flag   (   in_MemRd      ),
    .in_Wr_data   (   in_Wr_data    ),
    .in_WrRd_addr (   in_WrRd_addr  ),

    .out_Rd_data  (   out_Rd_data   )
);

endmodule