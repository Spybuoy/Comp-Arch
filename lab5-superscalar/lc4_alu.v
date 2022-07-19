/* INSERT NAME AND PENNKEY HERE */
//Nathaniel Hoaglund nhoag



`timescale 1ns / 1ps
`default_nettype none

module lc4_alu(input  wire [15:0] i_insn,
               input wire [15:0]  i_pc,
               input wire [15:0]  i_r1data,
               input wire [15:0]  i_r2data,
               output wire [15:0] o_result);



               //find which operand it is 
               //branch stuff
               wire branchType = i_insn[15:12] == 4'b0000 ? 1'b1 : 1'b0;
               wire nopIns = i_insn[15:9] == 7'b0000000 ? 1'b1 : 1'b0;
               wire arithType = i_insn[15:12] == 4'b0001 ? 1'b1 : 1'b0;
               wire cmpType = i_insn[15:12] == 4'b0010 ? 1'b1 : 1'b0;
               wire jsrrIns = i_insn[15:11] == 5'b01000 ? 1'b1 : 1'b0;
               wire jsrIns = i_insn[15:11] == 5'b01001 ? 1'b1 : 1'b0;
               wire logType = i_insn[15:12] == 4'b0101 ? 1'b1 : 1'b0;
               wire loadIns = i_insn[15:12] == 4'b0110 ? 1'b1 : 1'b0;
               wire strIns = i_insn[15:12] == 4'b0111 ? 1'b1 : 1'b0;
               wire rtiIns = i_insn[15:12] == 4'b1000 ? 1'b1 : 1'b0;
               wire constIns = i_insn[15:12] == 4'b1001 ? 1'b1 : 1'b0;
               wire shiftType = i_insn[15:12] == 4'b1010 ? 1'b1 : 1'b0;
               wire jmprIns = i_insn[15:11] == 5'b11000 ? 1'b1 : 1'b0;
               wire jmpIns = i_insn[15:11] == 5'b11001 ? 1'b1 : 1'b0;
               wire hiconstIns = i_insn[15:12] == 4'b1101 ? 1'b1 : 1'b0;
               wire trapIns = i_insn[15:12] == 4'b1111 ? 1'b1 : 1'b0;


               wire brpIns = (i_insn[11:9] == 3'b001) && (branchType == 1'b1) ? 1'b1 : 1'b0;
               wire brzIns = (i_insn[11:9] == 3'b010) && (branchType == 1'b1) ? 1'b1 : 1'b0;
               wire brzpIns = (i_insn[11:9] == 3'b011) && (branchType == 1'b1) ? 1'b1 : 1'b0;
               wire brnIns = (i_insn[11:9] == 3'b100) && (branchType == 1'b1) ? 1'b1 : 1'b0;
               wire brnpIns = (i_insn[11:9] == 3'b101) && (branchType == 1'b1) ? 1'b1 : 1'b0;
               wire brnzIns = (i_insn[11:9] == 3'b110) && (branchType == 1'b1) ? 1'b1 : 1'b0;
               wire brnzpIns = (i_insn[11:9] == 3'b111) && (branchType == 1'b1) ? 1'b1 : 1'b0;

               wire addIns = (i_insn[5:3] == 3'b000) && (arithType === 1'b1) ? 1'b1 : 1'b0;
               wire mulIns = (i_insn[5:3] == 3'b001) && (arithType === 1'b1) ? 1'b1 : 1'b0;
               wire subIns = (i_insn[5:3] == 3'b010) && (arithType === 1'b1) ? 1'b1 : 1'b0;
               wire divIns = (i_insn[5:3] == 3'b011) && (arithType === 1'b1) ? 1'b1 : 1'b0;
               wire addImmIns = (i_insn[5] == 1'b1) && (arithType === 1'b1) ? 1'b1 : 1'b0;

               wire cmpIns = (i_insn[8:7] == 2'b00) && (cmpType == 1'b1) ? 1'b1 : 1'b0;
               wire cmpUIns = (i_insn[8:7] == 2'b01) && (cmpType == 1'b1) ? 1'b1 : 1'b0;
               wire cmpIIns = (i_insn[8:7] == 2'b10) && (cmpType == 1'b1) ? 1'b1 : 1'b0;
               wire cmpIUIns = (i_insn[8:7] == 2'b11) && (cmpType == 1'b1) ? 1'b1 : 1'b0;


               wire andIns = (i_insn[5:3] == 3'b000) && (logType === 1'b1) ? 1'b1 : 1'b0;
               wire notIns = (i_insn[5:3] == 3'b001) && (logType === 1'b1) ? 1'b1 : 1'b0;
               wire orIns = (i_insn[5:3] == 3'b010) && (logType === 1'b1) ? 1'b1 : 1'b0;
               wire xorIns = (i_insn[5:3] == 3'b011) && (logType === 1'b1) ? 1'b1 : 1'b0;
               wire andImmIns = (i_insn[5] == 1'b1) && (logType === 1'b1) ? 1'b1 : 1'b0;


               wire sllIns = (i_insn[5:4] == 2'b00) && (shiftType === 1'b1) ? 1'b1 : 1'b0;
               wire sraIns = (i_insn[5:4] == 2'b01) && (shiftType === 1'b1) ? 1'b1 : 1'b0;
               wire srlIns = (i_insn[5:4] == 2'b10) && (shiftType === 1'b1) ? 1'b1 : 1'b0;
               wire modIns = (i_insn[5:4] == 2'b11) && (shiftType === 1'b1) ? 1'b1 : 1'b0;






//r1 = rs, r2 = rt

//sign extend, unsigned immediate4, unsigned immediate 8, Imm5, Imm6

wire[15:0] uimm4;
wire[15:0] uimm8;
wire[15:0] uimm7;
wire[15:0] imm9;
wire[15:0] imm5;
wire[15:0] imm8;
wire[15:0] imm7;

wire[15:0] imm6;
wire[15:0] imm11;

assign uimm4 = i_insn[3:0] | 16'b0000000000000000;
assign uimm8 = i_insn[7:0] | 16'b0000000000000000;
assign uimm7 = i_insn[6:0] | 16'b0000000000000000;

assign imm9 = i_insn[8] == 1'b1 ? 16'b1111111000000000 | i_insn :
16'b0000000111111111 & i_insn;
assign imm5 = i_insn[4] == 1'b1 ? 16'b1111111111100000 | i_insn :
16'b0000000000011111 & i_insn;
assign imm8 = i_insn[7] == 1'b1 ? 16'b1111111100000000 | i_insn :
16'b0000000011111111 & i_insn;
assign imm6 = i_insn[5] == 1'b1 ? 16'b1111111111000000 | i_insn :
16'b0000000000111111 & i_insn;
assign imm11 = i_insn[10] == 1'b1 ? 16'b1111110000000000 | i_insn :
16'b0000001111111111 & i_insn;
assign imm7 = i_insn[6] == 1'b1 ? 16'b1111111110000000 | i_insn:
16'b0000000001111111 & i_insn;



           
            wire[15:0] add_temp, sub_temp, div_temp, mod_temp,
            r2DataN, r2DataNeg, mul_temp;

            //adding

            //subtracting


            //dividing and modding

            lc4_divider divmod(.i_dividend(i_r1data), .i_divisor(i_r2data),
            .o_remainder(mod_temp), .o_quotient(div_temp));

            //multiplication

            assign mul_temp = i_r1data * i_r2data;

            //logical operations

            wire[15:0] and_tmp, or_tmp, xor_tmp, not_tmp, andImm_tmp;
            
            
            assign and_tmp = i_r1data & i_r2data;

            assign or_tmp = i_r1data | i_r2data;
            
            assign xor_tmp = i_r1data ^ i_r2data;

            assign not_tmp = ~i_r1data;
            assign andImm_tmp = i_r1data & imm5;

            //computational instructions

            wire[15:0] cmp_tmp, cmpu_tmp, cmpi_tmp, cmpiu_tmp;


//might need to add sign
            wire [15:0]cmpo = ($signed(i_r1data) > $signed(i_r2data)) ? 16'b0000000000000001 : 16'b1111111111111111;
            assign cmp_tmp = (i_r1data == i_r2data) ? 16'b0000000000000000 : cmpo;

            wire [15:0]cmpuo;
            assign cmpuo = (i_r1data) > (i_r2data) ? 16'b0000000000000001 : 16'b1111111111111111;
            assign cmpu_tmp = i_r1data == i_r2data ? 16'b0000000000000000 : cmpuo;

            wire [15:0]cmpio = $signed(i_r1data) > $signed(imm7) ? 16'b0000000000000001 : 16'b1111111111111111;
            assign cmpi_tmp = $signed(imm7) == i_r1data ? 16'b0000000000000000 : cmpio;

            wire [15:0]cmpiu = (i_r1data) > (uimm7) ? 16'b0000000000000001 : 16'b1111111111111111;
            assign cmpiu_tmp = i_r1data == uimm7 ? 16'b0000000000000000 : cmpiu;


            //JMP will just output Rs (i_r1data)

            //JSR 
            wire[15:0] jsr_tmp;
            wire[15:0] pcAnd = (16'b1000000000000000 & i_pc);
            wire [15:0] shiftimm11 = (imm11 << 4);
            //trying to add sign to it
            assign jsr_tmp[15] = pcAnd[15];           
            assign jsr_tmp[14:0] = (pcAnd[14:0]) | shiftimm11[14:0];
            

            //CONST will just equal imm9

            //RTI returns the value of i_r1data

            //HICONST r1data = rd
            wire[15:0] hiconst_tmp;
            assign hiconst_tmp = (i_r1data & 16'b0000000011111111
            | (uimm8 << 8));

            //TRAP 
            wire[15:0] trap_tmp = (16'b1000000000000000 | uimm8);

            //Load and Store have to go through cla mux

            wire[15:0] sll_tmp = i_r1data << (uimm4);
            wire[15:0] sra_tmp = $signed($signed(i_r1data) >>> (uimm4));
            wire[15:0] srl_tmp = i_r1data >> (uimm4);


            //mux code

            //what makes cin 1
            wire[2:0] cin1;
            assign cin1[0] = subIns;
            assign cin1[1] = branchType;
            assign cin1[2] = jmpIns;

            //what makes apc 1
            wire [1:0] aPc;
            assign aPc[0] = branchType;
            assign aPc[1] = jmpIns;
            //wire [1:0] aRs;
            
            
            wire claCin = (|cin1);

            wire claPc = (|aPc);
            //wire claARs = (|aRs);
            //wire[15:0] inp2 = (claARs == 1'b1) ? i_r1data : ;
            wire [15:0] claA = (claPc == 1'b1) ? i_pc : i_r1data;

            //what gets added to other part
            wire claBsext11;
            assign claBsext11 = jmpIns;

            wire [1:0] claBsext6;
            assign claBsext6[0] = loadIns;
            assign claBsext6[1] = strIns;
            wire claRt;
            assign claRt = addIns;
            
            wire claRtN = subIns;
            //wire [2:0] claBSext7;
            //assign claBSext7[0] = ;
            wire claBSext5 = addImmIns;
            wire claBSext9 = branchType;





            wire [15:0] claB;


            wire claRtN1 = |claRtN;
            wire claBsext1 = |claBsext6;
            wire claRt1 = |claRt;
            wire claBSext51 = |claBSext5;
            wire claBSext91 = |claBSext9;
            wire claBSext61 = |claBsext6;

            wire [15:0] b6 = imm11;
            wire [15:0] b5 = (nopIns) == 1'b1 ? 16'b0000000000000000 : b6;
            wire [15:0] b4 = (claRtN1) == 1'b1 ? ~i_r2data : b5;
            wire [15:0] b3 = (claBSext61 == 1'b1) ? imm6 : b4;
            wire [15:0] b2 = (claRt1 == 1'b1) ? i_r2data : b3;
            wire [15:0] b1 = (claBSext51 == 1'b1) ? imm5 : b2;
            assign claB = (claBSext91 == 1'b1) ? imm9 : b1;
            
            wire [15:0] sum;
           

           // wire [15:0] claB = ((|claRt) == 1'b1) ? i_r2data : inpB2;

            cla16 s(.a(claA), .b(claB), .cin(claCin), .sum(sum));


            wire[15:0] checkCin;
            assign checkCin[0] = claCin;

            //muxing to output


            wire [15:0] o_28 = (jsrIns == 1'b1) ? jsr_tmp : sum; 
            wire [15:0] o_27 = (nopIns == 1'b1) ? sum : o_28; 
            wire [15:0] o_26 = (notIns == 1'b1) ? not_tmp : o_27; 
            wire [15:0] o_25 = (addImmIns == 1'b1) ? sum : o_26; 
            wire [15:0] o_24 = (cmpIUIns == 1'b1) ? cmpiu_tmp : o_25; 
            wire [15:0] o_23 = (cmpIIns == 1'b1) ? cmpi_tmp : o_24; 
            wire [15:0] o_22 = (cmpUIns == 1'b1) ? cmpu_tmp : o_23; 
            wire [15:0] o_21 = (cmpIns == 1'b1) ? cmp_tmp : o_22; 
            wire [15:0] o_20 = (branchType == 1'b1 && nopIns == 1'b0) ? sum : o_21; 
            wire [15:0] o_19 = (jmpIns == 1'b1) ? sum : o_20; 
            wire [15:0] o_18 = (jmprIns == 1'b1) ? i_r1data : o_19; 
            wire [15:0] o_17 = (srlIns == 1'b1) ? srl_tmp : o_18; 
            wire [15:0] o_16 = (sraIns == 1'b1) ? sra_tmp : o_17; 
            wire [15:0] o_15 = (sllIns == 1'b1) ?  sll_tmp : o_16; 
            wire [15:0] o_14 = (constIns == 1'b1) ? imm9 : o_15; 
            wire [15:0] o_13 = (strIns == 1'b1) ? sum : o_14; 
            wire [15:0] o_12 = (loadIns == 1'b1) ? sum : o_13; 
            wire [15:0] o_11 = (andImmIns == 1'b1) ? andImm_tmp : o_12; 
            wire [15:0] o_10 = (xorIns == 1'b1) ? xor_tmp : o_11; 
            wire [15:0] o_9 = (orIns == 1'b1) ? or_tmp : o_10; 
            wire [15:0] o_8 = (andIns == 1'b1) ? and_tmp : o_9; 
            wire [15:0] o_7 = (trapIns == 1'b1) ? trap_tmp : o_8; 
            wire [15:0] o_6 = (jsrrIns == 1'b1) ? i_r1data : o_7; 
            wire [15:0] o_5 = (modIns == 1'b1) ? mod_temp : o_6; 
            wire [15:0] o_4 = (divIns == 1'b1) ? div_temp : o_5; 
            wire [15:0] o_3 = (mulIns == 1'b1) ? mul_temp : o_4; 
            wire [15:0] o_2 = (addIns == 1'b1) ? sum : o_3; 
            wire [15:0] o_1 = (rtiIns == 1'b1) ? i_r1data : o_2; 
            assign o_result = (hiconstIns == 1'b1) ? hiconst_tmp : o_1;





            



endmodule

