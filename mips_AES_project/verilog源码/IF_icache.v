//指令文件。

module IF_icache (
    input         in_rst_n      ,
    input  [7:0]  in_addr       ,

    output [31:0] out_instruct
);

reg [31:0] RAM [0:255];

assign out_instruct = RAM[in_addr];

always @(negedge in_rst_n) begin
    if(~in_rst_n) begin

        RAM[  0] = 32'h00002020;    // add	r4 = r0 + r0
        RAM[  1] = 32'h8c900000;    // lw	r16 = mem(r4+0)
        RAM[  2] = 32'h8c910004;    // lw	r17 = mem(r4+4)
        RAM[  3] = 32'h8c920008;    // lw	r18 = mem(r4+8)
        RAM[  4] = 32'h8c93000c;    // lw	r19 = mem(r4+12)
        RAM[  5] = 32'h8c940010;    // lw	r20 = mem(r4+16)
        RAM[  6] = 32'h8c950014;    // lw	r21 = mem(r4+20)
        RAM[  7] = 32'h8c960018;    // lw	r22 = mem(r4+24)
        RAM[  8] = 32'h8c97001c;    // lw	r23 = mem(r4+28)
        RAM[  9] = 32'h20050000;    // addi	r5 = r0 + 0
        RAM[ 10] = 32'h3c068d00;    // lui	r6 = 1000110100000000*65536
        RAM[ 11] = 32'h2007000a;    // addi	r7 = r0 + 10
        RAM[ 12] = 32'h0290a026;    // xor	r20 = r20 ^ r16
        RAM[ 13] = 32'h02b1a826;    // xor	r21 = r21 ^ r17
        RAM[ 14] = 32'h02d2b026;    // xor	r22 = r22 ^ r18
        RAM[ 15] = 32'h02f3b826;    // xor	r23 = r23 ^ r19
        RAM[ 16] = 32'h10a700d0;    // beq	if(r5==r7) goto pc+4+4*208      最后一条指令
        RAM[ 17] = 32'h20a50001;    // addi	r5 = r5 + 1
        RAM[ 18] = 32'h22990000;    // addi	r25 = r20 + 0
        RAM[ 19] = 32'h0c10001f;    // jal	 goto (pc+4)[31:28] + addr + 2'b00 (实际上跳到RAM[31])

        RAM[ 20] = 32'h23340000;    // addi	r20 = r25 + 0
        RAM[ 21] = 32'h22b90000;    // addi	r25 = r21 + 0
        RAM[ 22] = 32'h0c10001f;    // jal	 goto (pc+4)[31:28]+4*0+00  (实际上跳到RAM[31])
        RAM[ 23] = 32'h23350000;    // addi	r21 = r25 + 0
        RAM[ 24] = 32'h22d90000;    // addi	r25 = r22 + 0
        RAM[ 25] = 32'h0c10001f;    // jal	 goto (pc+4)[31:28]+4*0+00  (实际上跳到RAM[31])
        RAM[ 26] = 32'h23360000;    // addi	r22 = r25 + 0
        RAM[ 27] = 32'h22f90000;    // addi	r25 = r23 + 0
        RAM[ 28] = 32'h0c10001f;    // jal	 goto (pc+4)[31:28]+4*0+00  (实际上跳到RAM[31])
        RAM[ 29] = 32'h23370000;    // addi	r23 = r25 + 0
        RAM[ 30] = 32'h08100036;    // j	 goto (pc+4)[31:28]+4*0+00  跳转到RAM[54]

        RAM[ 31] = 32'h00194582;    // srl	r8 = r25 >> 10110 (10进制数为22)
        RAM[ 32] = 32'h310803fc;    // andi	r8 = r8 & 1020 (10进制)
        RAM[ 33] = 32'h00194b82;    // srl	r9 = r25 >> 01110 (10进制数为14)
        RAM[ 34] = 32'h312903fc;    // andi	r9 = r9 & 1020 (10进制)
        RAM[ 35] = 32'h00195182;    // srl	r10 = r25 >> 00110 (10进制数为12)
        RAM[ 36] = 32'h314a03fc;    // andi	r10 = r10 & 1020 (10进制)
        RAM[ 37] = 32'h00195880;    // sll	r11 = r25 << 00010 (10进制数为2)
        RAM[ 38] = 32'h316b03fc;    // andi	r11 = r11 & 1020 (10进制)
        RAM[ 39] = 32'h01044020;    // add	r8 = r4 + r8
        RAM[ 40] = 32'h01244820;    // add	r9 = r4 + r9
        RAM[ 41] = 32'h01445020;    // add	r10 = r4 + r10
        RAM[ 42] = 32'h01645820;    // add	r11 = r4 + r11
        RAM[ 43] = 32'h8d080200;    // lw	r8 = mem(r8+512)
        RAM[ 44] = 32'h8d290200;    // lw	r9 = mem(r9+512)
        RAM[ 45] = 32'h8d4a0200;    // lw	r10 = mem(r10+512)
        RAM[ 46] = 32'h8d6b0200;    // lw	r11 = mem(r11+512)
        RAM[ 47] = 32'h00084600;    // sll	r8 = r8 << 11000
        RAM[ 48] = 32'h00094c00;    // sll	r9 = r9 << 10000
        RAM[ 49] = 32'h000a5200;    // sll	r10 = r10 << 01000
        RAM[ 50] = 32'h0109c820;    // add	r25 = r9 + r8
        RAM[ 51] = 32'h032ac820;    // add	r25 = r10 + r25
        RAM[ 52] = 32'h032bc820;    // add	r25 = r11 + r25
        RAM[ 53] = 32'h03e00008;    // jr	 goto r31 

        RAM[ 54] = 32'h3c0100ff;    // lui	r1 = 0000000011111111*65536
        RAM[ 55] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[ 56] = 32'h02814824;    // and	r9 = r20 & r1
        RAM[ 57] = 32'h3c01ff00;    // lui	r1 = 1111111100000000*65536
        RAM[ 58] = 32'h3421ffff;    // ori	r1 = r1 | 65535
        RAM[ 59] = 32'h0281a024;    // and	r20 = r20 & r1        
        RAM[ 60] = 32'h3c0100ff;    // lui	r1 = 0000000011111111*65536
        RAM[ 61] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[ 62] = 32'h02a15024;    // and	r10 = r21 & r1
        RAM[ 63] = 32'h3c01ff00;    // lui	r1 = 1111111100000000*65536
        RAM[ 64] = 32'h3421ffff;    // ori	r1 = r1 | 65535
        RAM[ 65] = 32'h02a1a824;    // and	r21 = r21 & r1
        RAM[ 66] = 32'h3c0100ff;    // lui	r1 = 0000000011111111*65536
        RAM[ 67] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[ 68] = 32'h02c15824;    // and	r11 = r22 & r1
        RAM[ 69] = 32'h3c01ff00;    // lui	r1 = 1111111100000000*65536
        RAM[ 70] = 32'h3421ffff;    // ori	r1 = r1 | 65535
        RAM[ 71] = 32'h02c1b024;    // and	r22 = r22 & r1
        RAM[ 72] = 32'h3c0100ff;    // lui	r1 = 0000000011111111*65536
        RAM[ 73] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[ 74] = 32'h02e16024;    // and	r12 = r23 & r1
        RAM[ 75] = 32'h3c01ff00;    // lui	r1 = 1111111100000000*65536
        RAM[ 76] = 32'h3421ffff;    // ori	r1 = r1 | 65535
        RAM[ 77] = 32'h02e1b824;    // and	r23 = r23 & r1
        RAM[ 78] = 32'h028aa026;    // xor	r20 = r20 ^ r10
        RAM[ 79] = 32'h02aba826;    // xor	r21 = r21 ^ r11
        RAM[ 80] = 32'h02ccb026;    // xor	r22 = r22 ^ r12
        RAM[ 81] = 32'h02e9b826;    // xor	r23 = r23 ^ r9
        RAM[ 82] = 32'h3289ff00;    // andi	r9 = r20 & 65280 (0xFF00)
        RAM[ 83] = 32'h3c01ffff;    // lui	r1 = 1111111111111111*65536
        RAM[ 84] = 32'h342100ff;    // ori	r1 = r1 | 255
        RAM[ 85] = 32'h0281a024;    // and	r20 = r20 & r1
        RAM[ 86] = 32'h32aaff00;    // andi	r10 = r21 & 65280
        RAM[ 87] = 32'h3c01ffff;    // lui	r1 = 1111111111111111*65536
        RAM[ 88] = 32'h342100ff;    // ori	r1 = r1 | 255
        RAM[ 89] = 32'h02a1a824;    // and	r21 = r21 & r1
        RAM[ 90] = 32'h32cbff00;    // andi	r11 = r22 & 65280
        RAM[ 91] = 32'h3c01ffff;    // lui	r1 = 1111111111111111*65536
        RAM[ 92] = 32'h342100ff;    // ori	r1 = r1 | 255
        RAM[ 93] = 32'h02c1b024;    // and	r22 = r22 & r1
        RAM[ 94] = 32'h32ecff00;    // andi	r12 = r23 & 65280
        RAM[ 95] = 32'h3c01ffff;    // lui	r1 = 1111111111111111*65536
        RAM[ 96] = 32'h342100ff;    // ori	r1 = r1 | 255
        RAM[ 97] = 32'h02e1b824;    // and	r23 = r23 & r1
        RAM[ 98] = 32'h028ba026;    // xor	r20 = r20 ^ r11
        RAM[ 99] = 32'h02aca826;    // xor	r21 = r21 ^ r12
        RAM[100] = 32'h02c9b026;    // xor	r22 = r22 ^ r9
        RAM[101] = 32'h02eab826;    // xor	r23 = r23 ^ r10
        RAM[102] = 32'h328900ff;    // andi	r9 = r20 & 255
        RAM[103] = 32'h3c01ffff;    // lui	r1 = 1111111111111111*65536
        RAM[104] = 32'h3421ff00;    // ori	r1 = r1 | 65280
        RAM[105] = 32'h0281a024;    // and	r20 = r20 & r1
        RAM[106] = 32'h32aa00ff;    // andi	r10 = r21 & 255
        RAM[107] = 32'h3c01ffff;    // lui	r1 = 1111111111111111*65536
        RAM[108] = 32'h3421ff00;    // ori	r1 = r1 | 65280
        RAM[109] = 32'h02a1a824;    // and	r21 = r21 & r1
        RAM[110] = 32'h32cb00ff;    // andi	r11 = r22 & 255
        RAM[111] = 32'h3c01ffff;    // lui	r1 = 1111111111111111*65536
        RAM[112] = 32'h3421ff00;    // ori	r1 = r1 | 65280
        RAM[113] = 32'h02c1b024;    // and	r22 = r22 & r1
        RAM[114] = 32'h32ec00ff;    // andi	r12 = r23 & 255
        RAM[115] = 32'h3c01ffff;    // lui	r1 = 1111111111111111*65536
        RAM[116] = 32'h3421ff00;    // ori	r1 = r1 | 65280
        RAM[117] = 32'h02e1b824;    // and	r23 = r23 & r1
        RAM[118] = 32'h028ca026;    // xor	r20 = r20 ^ r12
        RAM[119] = 32'h02a9a826;    // xor	r21 = r21 ^ r9
        RAM[120] = 32'h02cab026;    // xor	r22 = r22 ^ r10
        RAM[121] = 32'h02ebb826;    // xor	r23 = r23 ^ r11        
        RAM[122] = 32'h10a70050;    // beq	if(r5==r7) goto pc+4+4*80
        RAM[123] = 32'h22990000;    // addi	r25 = r20 + 0
        RAM[124] = 32'h0c100088;    // jal	 goto (pc+4)[31:28]+4*0+00  跳转到RAM[136]

        RAM[125] = 32'h23340000;    // addi	r20 = r25 + 0
        RAM[126] = 32'h22b90000;    // addi	r25 = r21 + 0
        RAM[127] = 32'h0c100088;    // jal	 goto (pc+4)[31:28]+4*0+00
        RAM[128] = 32'h23350000;    // addi	r21 = r25 + 0
        RAM[129] = 32'h22d90000;    // addi	r25 = r22 + 0
        RAM[130] = 32'h0c100088;    // jal	 goto (pc+4)[31:28]+4*0+00
        RAM[131] = 32'h23360000;    // addi	r22 = r25 + 0
        RAM[132] = 32'h22f90000;    // addi	r25 = r23 + 0
        RAM[133] = 32'h0c100088;    // jal	 goto (pc+4)[31:28]+4*0+00
        RAM[134] = 32'h23370000;    // addi	r23 = r25 + 0
        RAM[135] = 32'h081000cb;    // j	 goto (pc+4)[31:28]+4*0+00  跳转到RAM[203]

        RAM[136] = 32'h3c01ff00;    // lui	r1 = 1111111100000000*65536
        RAM[137] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[138] = 32'h03214024;    // and	r8 = r25 & r1
        RAM[139] = 32'h3c0100ff;    // lui	r1 = 0000000011111111*65536
        RAM[140] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[141] = 32'h03214824;    // and	r9 = r25 & r1
        RAM[142] = 32'h332aff00;    // andi	r10 = r25 & 65280   (0xFF00)
        RAM[143] = 32'h332b00ff;    // andi	r11 = r25 & 255     0xFF
        RAM[144] = 32'h00094a00;    // sll	r9 = r9 << 01000    8
        RAM[145] = 32'h000a5400;    // sll	r10 = r10 << 10000  16
        RAM[146] = 32'h000b5e00;    // sll	r11 = r11 << 11000  24
        RAM[147] = 32'h00086040;    // sll	r12 = r8 << 00001   1
        RAM[148] = 32'h3c018000;    // lui	r1 = 1000000000000000*65536
        RAM[149] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[150] = 32'h0101c024;    // and	r24 = r8 & r1        
        RAM[151] = 32'h13000003;    // beq	if(r24==r0) goto pc+4+4*3
        RAM[152] = 32'h3c011b00;    // lui	r1 = 0001101100000000*65536
        RAM[153] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[154] = 32'h01816026;    // xor	r12 = r12 ^ r1
        RAM[155] = 32'h00096840;    // sll	r13 = r9 << 00001
        RAM[156] = 32'h3c018000;    // lui	r1 = 1000000000000000*65536
        RAM[157] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[158] = 32'h0121c024;    // and	r24 = r9 & r1
        RAM[159] = 32'h13000003;    // beq	if(r24==r0) goto pc+4+4*3
        RAM[160] = 32'h3c011b00;    // lui	r1 = 0001101100000000*65536
        RAM[161] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[162] = 32'h01a16826;    // xor	r13 = r13 ^ r1
        RAM[163] = 32'h000a7040;    // sll	r14 = r10 << 00001
        RAM[164] = 32'h3c018000;    // lui	r1 = 1000000000000000*65536
        RAM[165] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[166] = 32'h0141c024;    // and	r24 = r10 & r1
        RAM[167] = 32'h13000003;    // beq	if(r24==r0) goto pc+4+4*3
        RAM[168] = 32'h3c011b00;    // lui	r1 = 0001101100000000*65536
        RAM[169] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[170] = 32'h01c17026;    // xor	r14 = r14 ^ r1
        RAM[171] = 32'h000b7840;    // sll	r15 = r11 << 00001
        RAM[172] = 32'h3c018000;    // lui	r1 = 1000000000000000*65536
        RAM[173] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[174] = 32'h0161c024;    // and	r24 = r11 & r1
        RAM[175] = 32'h13000003;    // beq	if(r24==r0) goto pc+4+4*3
        RAM[176] = 32'h3c011b00;    // lui	r1 = 0001101100000000*65536
        RAM[177] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[178] = 32'h01e17826;    // xor	r15 = r15 ^ r1
        RAM[179] = 32'h018dc026;    // xor	r24 = r12 ^ r13
        RAM[180] = 32'h0309c026;    // xor	r24 = r24 ^ r9
        RAM[181] = 32'h030ac026;    // xor	r24 = r24 ^ r10
        RAM[182] = 32'h030bc026;    // xor	r24 = r24 ^ r11
        RAM[183] = 32'h23190000;    // addi	r25 = r24 + 0
        RAM[184] = 32'h01aec026;    // xor	r24 = r13 ^ r14
        RAM[185] = 32'h030ac026;    // xor	r24 = r24 ^ r10
        RAM[186] = 32'h030bc026;    // xor	r24 = r24 ^ r11
        RAM[187] = 32'h0308c026;    // xor	r24 = r24 ^ r8
        RAM[188] = 32'h0018c202;    // srl	r24 = r24 >> 01000
        RAM[189] = 32'h0338c820;    // add	r25 = r24 + r25
        RAM[190] = 32'h01cfc026;    // xor	r24 = r14 ^ r15
        RAM[191] = 32'h030bc026;    // xor	r24 = r24 ^ r11
        RAM[192] = 32'h0308c026;    // xor	r24 = r24 ^ r8
        RAM[193] = 32'h0309c026;    // xor	r24 = r24 ^ r9
        RAM[194] = 32'h0018c402;    // srl	r24 = r24 >> 10000
        RAM[195] = 32'h0338c820;    // add	r25 = r24 + r25
        RAM[196] = 32'h01ecc026;    // xor	r24 = r15 ^ r12
        RAM[197] = 32'h0308c026;    // xor	r24 = r24 ^ r8
        RAM[198] = 32'h0309c026;    // xor	r24 = r24 ^ r9
        RAM[199] = 32'h030ac026;    // xor	r24 = r24 ^ r10
        RAM[200] = 32'h0018c602;    // srl	r24 = r24 >> 11000
        RAM[201] = 32'h0338c820;    // add	r25 = r24 + r25
        RAM[202] = 32'h03e00008;    // jr	 goto r31 

        RAM[203] = 32'h00136e02;    // srl	r13 = r19 >> 11000
        RAM[204] = 32'h00137200;    // sll	r14 = r19 << 01000
        RAM[205] = 32'h01cd6820;    // add	r13 = r13 + r14
        RAM[206] = 32'h21b90000;    // addi	r25 = r13 + 0
        RAM[207] = 32'h0c10001f;    // jal	 goto (pc+4)[31:28]+4*0+00  跳转到RAM[31],字节替换
        RAM[208] = 32'h232d0000;    // addi	r13 = r25 + 0
        RAM[209] = 32'h3c018000;    // lui	r1 = 1000000000000000*65536
        RAM[210] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[211] = 32'h00c17024;    // and	r14 = r6 & r1

        RAM[212] = 32'h34210000;    // ori	r1 = r1 | 0         此处不加就出错

        RAM[213] = 32'h00063040;    // sll	r6 = r6 << 00001
        RAM[214] = 32'h11c00003;    // beq	if(r14==r0) goto pc+4+4*3
        RAM[215] = 32'h3c011b00;    // lui	r1 = 0001101100000000*65536
        RAM[216] = 32'h34210000;    // ori	r1 = r1 | 0
        RAM[217] = 32'h00c13026;    // xor	r6 = r6 ^ r1
        RAM[218] = 32'h020d8026;    // xor	r16 = r16 ^ r13
        RAM[219] = 32'h02068026;    // xor	r16 = r16 ^ r6
        RAM[220] = 32'h02308826;    // xor	r17 = r17 ^ r16
        RAM[221] = 32'h02519026;    // xor	r18 = r18 ^ r17
        RAM[222] = 32'h02729826;    // xor	r19 = r19 ^ r18
        RAM[223] = 32'h0810000c;    // j	 goto (pc+4)[31:28]+4*0+00  跳转到RAM[12]

        RAM[224] = 32'h34210000;    // ori	r1 = r1 | 0

        RAM[225] = 32'h081000e1;    // j	 goto (pc+4)[31:28]+4*0+00  跳转到RAM[223]，跳转到自身，一直不变，程序停止

        RAM[226] = 32'h34210000;    // ori	r1 = r1 | 0

    end
    else ;    
end 

endmodule