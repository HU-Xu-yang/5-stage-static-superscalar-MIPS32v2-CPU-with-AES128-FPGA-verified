`timescale 1ns/1ns

module Core_tb;
    
// input
reg reset       ;
reg system_clk  ;

// output 
wire [127:0] state      ;
wire [127:0] cipherkey  ;

always #25 system_clk = ~system_clk;

initial begin
    reset = 0; system_clk = 0;

    #50 reset = 1;              

    #2500000 $stop;
end

Core core_test(
    .rst_n      (   reset       ),
    .clk        (   system_clk  ),

    .cipherkey  (   cipherkey   ),
    .state      (   state       )
);
    
endmodule