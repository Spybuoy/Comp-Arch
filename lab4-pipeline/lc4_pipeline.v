/* TODO: name and PennKeys of all group members here */
//Nate Hoaglund nhoag

`timescale 1ns / 1ps

// disable implicit wire declaration
`default_nettype none

module lc4_processor
   (input  wire        clk,                // main clock
    input wire         rst, // global reset
    input wire         gwe, // global we for single-step clock
                                    
    output wire [15:0] o_cur_pc, // Address to read from instruction memory
    input wire [15:0]  i_cur_insn, // Output of instruction memory
    output wire [15:0] o_dmem_addr, // Address to read/write from/to data memory
    input wire [15:0]  i_cur_dmem_data, // Output of data memory
    output wire        o_dmem_we, // Data memory write enable
    output wire [15:0] o_dmem_towrite, // Value to write to data memory
   
    output wire [1:0]  test_stall, // Testbench: is this is stall cycle? (don't compare the test values)
    output wire [15:0] test_cur_pc, // Testbench: program counter
    output wire [15:0] test_cur_insn, // Testbench: instruction bits
    output wire        test_regfile_we, // Testbench: register file write enable
    output wire [2:0]  test_regfile_wsel, // Testbench: which register to write in the register file 
    output wire [15:0] test_regfile_data, // Testbench: value to write into the register file
    output wire        test_nzp_we, // Testbench: NZP condition codes write enable
    output wire [2:0]  test_nzp_new_bits, // Testbench: value to write to NZP bits
    output wire        test_dmem_we, // Testbench: data memory write enable
    output wire [15:0] test_dmem_addr, // Testbench: address to read/write memory
    output wire [15:0] test_dmem_data, // Testbench: value read/writen from/to memory

    input wire [7:0]   switch_data, // Current settings of the Zedboard switches
    output wire [7:0]  led_data // Which Zedboard LEDs should be turned on?
    );
   


   assign led_data = switch_data;
   /*** YOUR CODE HERE ***/


   //getting pc reg stuff
   wire [15:0]   pc;      // Current program counter (read out from pc_reg)
   wire [15:0]  next_pc;

   Nbit_reg #(16, 16'h8200) pc_reg (.in(next_pc), .out(pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   

   //calculate pc + 1
   wire [15:0] pcp1, clain;
   wire carIn = 1'b1;
   assign clain = 0;
   cla16 a1tpc(.a(pc), .b(clain), .cin(carIn), .sum(pcp1));

   //getting the pc from instruction memory
   assign o_cur_pc = pc;
   assign test_cur_pc = pipe4pc;
   //just to see alu stuff
   //need to check for load to use but it getting cleared anyway
   //assign next_pc = (loadToUseStall) ? pc : pcp1;

   //
   
   //Decoding the input

   //making the wires which will be output of decoder
   wire r1re, r2re, regfile_we, nzp_we, select_pc_plus_one, is_load, is_store, is_branch, is_control_insn;

   wire [2:0] r1sel, r2sel, wsel;

   lc4_decoder decoder(.insn(i_cur_insn), .r1sel(r1sel), .r1re(r1re), .r2sel(r2sel), .r2re(r2re), .wsel(wsel), .regfile_we(regfile_we),
   .nzp_we(nzp_we), .select_pc_plus_one(select_pc_plus_one), .is_load(is_load), .is_store(is_store), .is_branch(is_branch), .is_control_insn(is_control_insn));

   // first pipeline stage
   wire [17:0] pipeline1Enter, pipeline1Output;
   wire [15:0] pipe1OutInsn, pipe1pc;
   assign test_cur_insn = pipe4OutInsn;

   wire isNop1 = misPredict;
   //handle nop case, having MSB signify whether it is legit or not
   //assign pipeline1Enter[11] = 1'b1;

   //assign wires based on decoder output
   assign pipeline1Enter[2:0] = r1sel;
   assign pipeline1Enter[3] = r1re;
   assign pipeline1Enter[6:4] = r2sel;
   assign pipeline1Enter[7] = r2re;
   assign pipeline1Enter[10:8] = wsel;
   assign pipeline1Enter[11] = regfile_we;
   assign pipeline1Enter[12] = nzp_we;
   assign pipeline1Enter[13] = select_pc_plus_one;
   assign pipeline1Enter[14] = is_load;
   assign pipeline1Enter[15] = is_store;
   assign pipeline1Enter[16] = is_branch;
   assign pipeline1Enter[17] = is_control_insn;

   wire [17:0] pipeline1EnterReal = (loadToUseStall == 1'b1) ? pipeline1Output : misPredict ? 0 : pipeline1Enter;
   wire [15:0] pipelineInsnIn = loadToUseStall ? pipe1OutInsn : misPredict ? 0 : i_cur_insn;
   wire [15:0] pipelinepcIn = loadToUseStall ? pipe1pc : pc;


   //gonna try one big register for pipeline stage but could change
   //also need instruction itself for ALU stuff possibly
   Nbit_reg #(16, 0) pipe1insn (.in(pipelineInsnIn), .out(pipe1OutInsn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 0) pipe1pcr (.in(pipelinepcIn), .out(pipe1pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   
   Nbit_reg #(18, 0) pipe1stage (.in(pipeline1EnterReal), .out(pipeline1Output), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(1, 0) n1 (.in(misPredict), .out(isNopOut1), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   wire isNopOut1;
   //into pipline part 2
   // with pipeline1Output as value
   //in this part just do reg file stuff

   //init reg file
   //w_data we deal with much later in the pipeline
   //same with regfilewe
   wire [15:0] rs_output, rt_output, w_data;


   

   lc4_regfile #(.n(16)) regs (.clk(clk), .rst(rst), 
   .gwe(gwe), .i_rs(pipeline1Output[2:0]), .o_rs_data(rs_output), .i_rt(pipeline1Output[6:4]), 
   .o_rt_data(rt_output), .i_rd(pipeline4Output[10:8]), .i_wdata(w_data), .i_rd_we(pipeline4Output[11]));

   assign test_regfile_we = pipeline4Output[11];
   assign test_regfile_wsel = pipeline4Output[10:8];
   assign test_regfile_data = w_data;
   // need to nop all these wires

   wire [17:0] pipeline2Output, pipeline2RealInput;
   wire [15:0] pipe2OutInsn, pipe2Outrs, pipe2Outrt, pipe2pc, pipe2InsnReal, pipe2pcReal;
   //next stage of pipeline 

   assign pipe2InsnReal = isNop2 ? 16'b0000000000000000 : pipe1OutInsn;
   //assign pipe2pcReal = isNop2 ? 16'b0000000000000000 : pipe1pc;
   assign pipe2pcReal = pipe1pc;
   assign pipeline2RealInput = isNop2 ? 16'b0000000000000000 : pipeline1Output;

   wire isNop2, isNopOut2, isNopOut3, isNopOut4;
   assign isNop2 = loadToUseStall | misPredict | isNopOut1;

   Nbit_reg #(16, 0) pipe2insn (.in(pipe2InsnReal), .out(pipe2OutInsn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 0) pipe2pcs (.in(pipe2pcReal), .out(pipe2pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   
   Nbit_reg #(18, 0) pipe2stage (.in(pipeline2RealInput), .out(pipeline2Output), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   
   //deal with output of the registers 
   wire [15:0] rs_outputreal, rt_outputreal;

   wire loadToUseOutput2;
   //WD bypass
   assign rs_outputreal = (pipeline1Output[2:0] == pipeline4Output[10:8]) & pipeline4Output[11]  ? w_data : rs_output;
   assign rt_outputreal = (pipeline1Output[6:4] == pipeline4Output[10:8]) & pipeline4Output[11] ? w_data : rt_output;

   Nbit_reg #(16, 0) rsOutput (.in(rs_outputreal), .out(pipe2Outrs), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 0) rtOutput (.in(rt_outputreal), .out(pipe2Outrt), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(1, 0) loadtouse2 (.in(loadToUseStallReal), .out(loadToUseOutput2), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(1, 0) n2 (.in(isNop2), .out(isNopOut2), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   //next pipeline stage alu part

   //load to use pipelining, might need to see if I need to add something on M stage?
   wire loadToUseStall;

   wire isSrl = (pipe1OutInsn[15:12] == 4'b1010) && (!pipe1OutInsn[4] | !pipe1OutInsn[5]);
   wire isAndImm = (pipe1OutInsn[15:12] == 4'b0101) & (pipe1OutInsn[5]);
   wire isAddImm = ((pipe1OutInsn[15:12] == 4'b0001) & (pipe1OutInsn[5]));
   wire isbranch1 = pipeline1Output[16];
   wire isNot = (pipe1OutInsn[15:12] == 4'b0101) & (pipe1OutInsn[3] & !pipe1OutInsn[4]);
   wire isConst = (pipe1OutInsn[15:12] == 4'b1001); 
   wire isHighConst = pipe1OutInsn[15:12] == 4'b1101;
   wire isControl = pipeline1Output[17];
   wire iscmpi = (pipe1OutInsn[15:12] == 4'b0010) & pipe1OutInsn[8];
   wire isJump = (pipe1OutInsn[15:11] == 5'b11001);

   wire pipe1NotStore = !pipeline1Output[15];
   wire pipeNotStoreAndEqReg = (pipeline1Output[6:4] == pipeline2Output[10:8]);
   assign loadToUseStall = ((pipeline2Output[14]) && ((pipeline1Output[16]) | (((pipeline1Output[2:0] == pipeline2Output[10:8]) & !isConst)
            || ((pipeline1Output[6:4] == pipeline2Output[10:8]) && (pipeline1Output[15] != 1'b1) && !pipeline1Output[14]
             && !isAndImm && !isAddImm && !isSrl && !isbranch1 && !isNot && 
             !isConst && !isHighConst & !iscmpi & !isControl))) && !isJump) ;
   

   wire loadToUseStallReal = misPredict ? 0 : loadToUseStall;

   
   wire loadToUseOutput3;

   //Wx bypassing
   wire [15:0] aluAinput;
   
   wire [15:0] abypass = (pipeline2Output[2:0] == pipeline4Output[10:8]) & pipeline4Output[11] ? w_data : pipe2Outrs;
   assign aluAinput = (pipeline2Output[2:0] == pipeline3Output[10:8]) & (pipeline3Output[11]) ? alu_outputPipe3 : abypass;

   wire [15:0] aluBinput;
   wire [15:0] bbypass = (pipeline2Output[6:4] == pipeline4Output[10:8]) & pipeline4Output[11] ? w_data : pipe2Outrt;
   assign aluBinput = (pipeline2Output[6:4] == pipeline3Output[10:8]) & (pipeline3Output[11]) ? alu_outputPipe3 : bbypass;

   wire[15:0] alu_output;
   wire[15:0] grealrt = (pipeline2Output[6:4] == pipeline3Output[10:8]) & (pipeline3Output[11]) ? alu_outputPipe3 : pipe2Outrt;
   wire[15:0] realrtpipe2 = (pipeline2Output[6:4] == pipeline4Output[10:8]) & (pipeline4Output[11]) ? w_data : grealrt;

   //need to deal with pc getting piped but might have done it
   lc4_alu alu (.i_insn(pipe2OutInsn), .i_pc(pipe2pc), .i_r1data(aluAinput), .i_r2data(aluBinput), .o_result(alu_output));

   wire [15:0] pipe2OutInsnReal, pipe2pcRealo;
   wire [17:0] pipeline2OutputReal;
   wire isNopOut2Real =  isNopOut2;

   assign pipe2OutInsnReal = pipe2OutInsn;
   //assign pipe2pcRealo = misPredict ? 0 : pipe2pc;
   assign pipe2pcRealo = pipe2pc;
   assign pipeline2OutputReal = pipeline2Output;

   wire [15:0] pcp1pipe2, pcp1pipe3, pcp1pipe4;
   //get pc plus 1
   cla16 a1tpc1(.a(pipe2pc), .b(clain), .cin(carIn), .sum(pcp1pipe2));

   //next pipeline 
   wire [17:0] pipeline3Output;
   wire [15:0] pipe3OutInsn, pipe3Outrs, pipe3Outrt, pipe3pc, alu_outputPipe3;
   Nbit_reg #(16, 0) pipe3insn (.in(pipe2OutInsnReal), .out(pipe3OutInsn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 0) pipe3pcs (.in(pipe2pcRealo), .out(pipe3pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 0) pipe3pcs1 (.in(pcp1pipe2), .out(pcp1pipe3), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(18, 0) pipe3stage (.in(pipeline2OutputReal), .out(pipeline3Output), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   Nbit_reg #(16, 0) rs3Output (.in(pipe2Outrs), .out(pipe3Outrs), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 0) rt3Output (.in(realrtpipe2), .out(pipe3Outrt), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 0) alu3Output (.in(alu_output), .out(alu_outputPipe3), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(1, 0) loadtouse3 (.in(loadToUseOutput2), .out(loadToUseOutput3), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(1, 0) isNop3 (.in(isNopOut2Real), .out(isNopOut3), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   //making sure it is not load to use 
   wire loadToUseStallReal2 = misPredict ? 0 : loadToUseOutput2;
   //wm bypass
   wire [15:0] dataToStore;
   assign dataToStore = (pipeline3Output[6:4] == pipeline4Output[10:8]) && !isNopOut4 && !pipeline4Output[16] && pipeline4Output[11] ? w_data : pipe3Outrt;

   assign o_dmem_we = pipeline3Output[15] && !isNopOut3; //marking it to the same as is store until it all works
   wire accessingDmem = pipeline3Output[14] | pipeline3Output[15]; //only accessed if it is a load or store
   assign o_dmem_towrite = dataToStore;

   assign o_dmem_addr = (accessingDmem == 1'b1) ? alu_outputPipe3 : 16'b0000000000000000;
   
   wire [15:0] dataMeme = o_dmem_we ? o_dmem_towrite : pipeline3Output[14] ? i_cur_dmem_data : 0;
   
   //next pipeline
   wire loadToUseOutput4;

   wire [17:0] pipeline4Output;
   wire [15:0] pipe4OutInsn, pipe4Outrs, pipe4Outrt, pipe4pc, alu_outputPipe4, pipe4dmemData, pipe4Addr;
   Nbit_reg #(16, 0) pipe4insn (.in(pipe3OutInsn), .out(pipe4OutInsn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 0) pipe4pcs (.in(pipe3pc), .out(pipe4pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 0) pipe4pcs2 (.in(pcp1pipe3), .out(pcp1pipe4), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(18, 0) pipe4stage (.in(pipeline3Output), .out(pipeline4Output), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   Nbit_reg #(16, 0) rs4Output (.in(pipe3Outrs), .out(pipe4Outrs), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 0) rt4Output (.in(pipe3Outrt), .out(pipe4Outrt), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 0) alu4Output (.in(alu_outputPipe3), .out(alu_outputPipe4), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 0) dataGot (.in(dataMeme), .out(pipe4dmemData), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16, 0) dataAddr (.in(o_dmem_addr), .out(pipe4Addr), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(1, 0) loadtouse4 (.in(loadToUseOutput3), .out(loadToUseOutput4), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(1, 0) isNop4 (.in(isNopOut3), .out(isNopOut4), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));


   wire[15:0] regMuxOutput;
   wire[15:0] mout1 = (pipe4Addr != 1'b0) ? pipe4dmemData : alu_outputPipe4;



   //for now just alu output should be enough
   assign regMuxOutput = (pipeline4Output[13] == 1'b1) ? pcp1pipe4 : mout1;
   //assign regMuxOutput = alu_outputPipe4;
   assign w_data = regMuxOutput;
   wire[15:0] regMuxOutputFake;
   wire[15:0] mout1Fake = pipeline3Output[14] ?  dataMeme : alu_outputPipe3;
   assign regMuxOutputFake = pipeline3Output[13] ? pcp1pipe3 : mout1Fake;

   wire[2:0] nzpf;

   assign nzpf[1] = (regMuxOutputFake == 16'b0000000000000000) ? 1'b1 : 1'b0;
   assign nzpf[0] = ((regMuxOutputFake[15] == 1'b0) && !nzpf[1])? 1'b1 : 1'b0;
   assign nzpf[2] = (regMuxOutputFake[15] == 1'b1) ? 1'b1 : 1'b0;

   //branching stuff
   wire[15:0] imm9;
   wire[15:0] imm11;


assign imm9 = pipe2OutInsn[8] == 1'b1 ? 16'b1111111000000000 | pipe2OutInsn :
16'b0000000111111111 & pipe2OutInsn;
assign imm11 = pipe2OutInsn[10] == 1'b1 ? 16'b1111110000000000 | pipe2OutInsn :
16'b0000001111111111 & pipe2OutInsn;

   //nzp stuff
   wire[2:0] nzp;

   assign nzp[1] = (regMuxOutput == 16'b0000000000000000) ? 1'b1 : 1'b0;
   assign nzp[0] = ((regMuxOutput[15] == 1'b0) && !nzp[1])? 1'b1 : 1'b0;
   assign nzp[2] = (regMuxOutput[15] == 1'b1) ? 1'b1 : 1'b0;

   wire [2:0] nzpOut;


   Nbit_reg #(3, 3'b000) nzp_reg (.in(nzp), .out(nzpOut), .clk(clk), .we(pipeline4Output[12]), .gwe(gwe), .rst(rst));

   //need to test against next nzp not current

   wire [2:0] nzpAndI = nzpOut & pipe2OutInsn[11:9];
   //not sure if needed but assuming they are needed 
   wire [2:0] nzpAndIbypass = nzp & pipe2OutInsn[11:9];
   wire [2:0] nzpFake = nzpf & pipe2OutInsn[11:9];
   //Do i need to check the current nzp getting written??
   wire nzpTest = (pipeline3Output[12] && !isNopOut3) ? (|nzpFake) : (pipeline4Output[12] && !isNopOut4) ? |nzpAndIbypass : |nzpAndI;
   wire [15:0] branchMux = (nzpTest) ? alu_output : pcp1;

   wire[15:0] nppp = loadToUseStall ? pc : pcp1;
   wire[15:0] npct = (pipeline2Output[17]) ? alu_output : nppp;
   assign next_pc = (pipeline2Output[16]) & nzpTest ? branchMux : npct;

   wire misPredict = (pipeline2Output[17] & !isNopOut2)| (pipeline2Output[16] & nzpTest & !isNopOut2);
   //for now not dealing with branch stuff
   assign test_nzp_new_bits = nzp;
   assign test_dmem_addr = pipe4Addr; //need to change once doing other stuff
   assign test_dmem_data = pipe4dmemData;
   assign test_stall[0] = loadToUseOutput4;
   assign test_stall[1] = ((pipe4OutInsn == 0) && (pipe4pc == 0)) | isNopOut4 ? 1 : 0;
   assign test_nzp_we = pipeline4Output[12];
   assign test_dmem_we = pipeline4Output[15];
   
   /* Add $display(...) calls in the always block below to
    * print out debug information at the end of every cycle.
    * 
    * You may also use if statements inside the always block
    * to conditionally print out information.
    *
    * You do not need to resynthesize and re-implement if this is all you change;
    * just restart the simulation.
    */
`ifndef NDEBUG
   always @(posedge gwe) begin
       //$display("%d %h", $time, pipe4OutInsn);
  //  /*  pinstr(pipe1OutInsn);
    pinstr(pipe3OutInsn);
    $display("\n dmem addr %h dmem data %h", test_dmem_addr, test_dmem_data);
    $display("alu output is %h", alu_output);
    $display("rtOutput3 %h", pipe3Outrt);
    $display("towrite %h datamem %h", o_dmem_towrite, dataMeme);
    $display("nop 1, 2, 3, 4: %h %h %h %h", isNopOut1, isNopOut2, isNopOut3, isNopOut4);
    $display("nex pc val is %h", next_pc);
    $display("pc is %h", pc);
    $display("pc1 is %h", pipe1pc);
    $display("pout4 select pc plus 1 %h", pipeline4Output[13]);
    $display("pc2 is %h", pipe2pc);
    $display("pc3 is %h", pipe3pc);
    $display("pc4 is %h", pipe4pc);
    $display("branch mux is %h", branchMux);
    $display("nzp test is %h", nzpTest);
    $display("nzp fake are %h", nzpf);
    $display("regmuzfake is %h", regMuxOutputFake);
    $display("nzp we ins pipe3 %h ins pipe4 %h", pipeline3Output[12], pipeline4Output[12]);
       $display();
       if(loadToUseStall) begin
         $display("LOAD TO USE");
         pinstr(pipe2OutInsn);
         $display();
         pinstr(pipe1OutInsn);
         $display("%h", isAddImm);
         $display("%h, %h", pipeline1Output, pipeline2Output);
         $display("%h", pipe1OutInsn);
         $display("%h", pipeNotStoreAndEqReg);
         $display("%h %h %h %h", pipeline1Output[6:4], pipeline1Output[2:0], pipeline1Output[10:8], pipeline2Output[10:8]);
         $display("above what caused");
       end
       $display("%h", pipe3pc); 
//*/
      // Start each $display() format string with a %d argument for time
      // it will make the output easier to read.  Use %b, %h, and %d
      // for binary, hex, and decimal output of additional variables.
      // You do not need to add a \n at the end of your format string.
      // $display("%d ...", $time);

      // Try adding a $display() call that prints out the PCs of
      // each pipeline stage in hex.  Then you can easily look up the
      // instructions in the .asm files in test_data.

      // basic if syntax:
      // if (cond) begin
      //    ...;
      //    ...;
      // end

      // Set a breakpoint on the empty $display() below
      // to step through your pipeline cycle-by-cycle.
      // You'll need to rewind the simulation to start
      // stepping from the beginning.

      // You can also simulate for XXX ns, then set the
      // breakpoint to start stepping midway through the
      // testbench.  Use the $time printouts you added above (!)
      // to figure out when your problem instruction first
      // enters the fetch stage.  Rewind your simulation,
      // run it for that many nano-seconds, then set
      // the breakpoint.

      // In the objects view, you can change the values to
      // hexadecimal by selecting all signals (Ctrl-A),
      // then right-click, and select Radix->Hexadecimal.

      // To see the values of wires within a module, select
      // the module in the hierarchy in the "Scopes" pane.
      // The Objects pane will update to display the wires
      // in that module.

      //$display(); 
   end
`endif
endmodule
