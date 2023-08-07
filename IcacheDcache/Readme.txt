1. 若没有异步SRAM，指令存储器和数据存储器简单可用寄存器堆实现，
   并在复位时将加载存储器内容，详见icache.v和dcache.v文件；
2. modelsim仿真时可以将存储器内容写入文件中，用$readmemh或$readmemb读取；