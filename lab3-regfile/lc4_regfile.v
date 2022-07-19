/* TODO: Names of all group members
 * TODO: PennKeys of all group members
 *
 * lc4_regfile.v
 * Implements an 8-register register file parameterized on word size.
 *
 */

`timescale 1ns / 1ps

// Prevent implicit wire declaration
`default_nettype none


module lc4_regfile #(parameter n = 16)
   (input  wire         clk,
    input  wire         gwe,
    input  wire         rst,
    input  wire [  2:0] i_rs,      // rs selector
    output wire [n-1:0] o_rs_data, // rs contents
    input  wire [  2:0] i_rt,      // rt selector
    output wire [n-1:0] o_rt_data, // rt contents
    input  wire [  2:0] i_rd,      // rd selector
    input  wire [n-1:0] i_wdata,   // data to write
    input  wire         i_rd_we    // write enable
    );

    //make all the registers

    //have all their outputs
    wire[n-1:0] reg0Data, reg1Data, reg2Data, reg3Data, reg4Data, reg5Data,
    reg6Data, reg7Data;

    //check rd to see which one we are writing to
    wire writeTo0 = i_rd[2:0] == 3'b000 ? 1'b1 : 1'b0;
    wire writeTo1 = i_rd[2:0] == 3'b001 ? 1'b1 : 1'b0;
    wire writeTo2 = i_rd[2:0] == 3'b010 ? 1'b1 : 1'b0;
    wire writeTo3 = i_rd[2:0] == 3'b011 ? 1'b1 : 1'b0;
    wire writeTo4 = i_rd[2:0] == 3'b100 ? 1'b1 : 1'b0;
    wire writeTo5 = i_rd[2:0] == 3'b101 ? 1'b1 : 1'b0;
    wire writeTo6 = i_rd[2:0] == 3'b110 ? 1'b1 : 1'b0;
    wire writeTo7 = i_rd[2:0] == 3'b111 ? 1'b1 : 1'b0;

    wire wandw0 = writeTo0 & i_rd_we;
    wire wandw1 = writeTo1 & i_rd_we;
    wire wandw2 = writeTo2 & i_rd_we;
    wire wandw3 = writeTo3 & i_rd_we;
    wire wandw4 = writeTo4 & i_rd_we;
    wire wandw5 = writeTo5 & i_rd_we;
    wire wandw6 = writeTo6 & i_rd_we;
    wire wandw7 = writeTo7 & i_rd_we;


    Nbit_reg #(.n(n))   r0 (.in(i_wdata), .clk(clk), .gwe(gwe), .rst(rst),
    .we(wandw0), .out(reg0Data));

    Nbit_reg #(.n(n)) r1 (.in(i_wdata), .clk(clk), .gwe(gwe), .rst(rst),
    .we(wandw1), .out(reg1Data));

    Nbit_reg #(.n(n)) r2 (.in(i_wdata), .clk(clk), .gwe(gwe), .rst(rst),
    .we(wandw2), .out(reg2Data));

    Nbit_reg #(.n(n)) r3 (.in(i_wdata), .clk(clk), .gwe(gwe), .rst(rst),
    .we(wandw3), .out(reg3Data));

    Nbit_reg #(.n(n)) r4 (.in(i_wdata), .clk(clk), .gwe(gwe), .rst(rst),
    .we(wandw4), .out(reg4Data));

    Nbit_reg #(.n(n)) r5 (.in(i_wdata), .clk(clk), .gwe(gwe), .rst(rst),
    .we(wandw5), .out(reg5Data));

    Nbit_reg #(.n(n))r6 (.in(i_wdata), .clk(clk), .gwe(gwe), .rst(rst),
    .we(wandw6), .out(reg6Data));

    Nbit_reg #(.n(n)) r7 (.in(i_wdata), .clk(clk), .gwe(gwe), .rst(rst),
    .we(wandw7), .out(reg7Data));

 //check rs to see which one we are reading from
    wire rs0 = i_rs[2:0] == 3'b000 ? 1'b1 : 1'b0;
    wire rs1 = i_rs[2:0] == 3'b001 ? 1'b1 : 1'b0;
    wire rs2 = i_rs[2:0] == 3'b010 ? 1'b1 : 1'b0;
    wire rs3 = i_rs[2:0] == 3'b011 ? 1'b1 : 1'b0;
    wire rs4 = i_rs[2:0] == 3'b100 ? 1'b1 : 1'b0;
    wire rs5 = i_rs[2:0] == 3'b101 ? 1'b1 : 1'b0;
    wire rs6 = i_rs[2:0] == 3'b110 ? 1'b1 : 1'b0;
    wire rs7 = i_rs[2:0] == 3'b111 ? 1'b1 : 1'b0;

    //assigning rs





     
    wire [n-1: 0] rsTmp6 = (rs6 == 1'b1) ? reg6Data : reg7Data;
    wire [n-1: 0] rsTmp5 = (rs5 == 1'b1) ? reg5Data : rsTmp6;
    wire [n-1: 0] rsTmp4  = (rs4 == 1'b1) ? reg4Data : rsTmp5;
    wire [n-1: 0] rsTmp3 = (rs3 == 1'b1) ? reg3Data : rsTmp4;
    wire [n-1: 0] rsTmp2 = (rs2 == 1'b1) ? reg2Data : rsTmp3;
    wire [n-1: 0] rsTmp1 = (rs1 == 1'b1) ? reg1Data : rsTmp2;
    assign o_rs_data = (rs0 == 1'b1) ? reg0Data : rsTmp1;

 //check rs to see which one we are reading from
    wire rt0 = i_rt[2:0] == 3'b000 ? 1'b1 : 1'b0;
    wire rt1 = i_rt[2:0] == 3'b001 ? 1'b1 : 1'b0;
    wire rt2 = i_rt[2:0] == 3'b010 ? 1'b1 : 1'b0;
    wire rt3 = i_rt[2:0] == 3'b011 ? 1'b1 : 1'b0;
    wire rt4 = i_rt[2:0] == 3'b100 ? 1'b1 : 1'b0;
    wire rt5 = i_rt[2:0] == 3'b101 ? 1'b1 : 1'b0;
    wire rt6 = i_rt[2:0] == 3'b110 ? 1'b1 : 1'b0;
    wire rt7 = i_rt[2:0] == 3'b111 ? 1'b1 : 1'b0;


    wire [n-1: 0] rtTmp6 = (rt6 == 1'b1) ? reg6Data : reg7Data;
    wire [n-1: 0] rtTmp5 = (rt5 == 1'b1) ? reg5Data : rtTmp6;
    wire [n-1: 0] rtTmp4 = (rt4 == 1'b1) ? reg4Data : rtTmp5;
    wire [n-1: 0] rtTmp3 = (rt3 == 1'b1) ? reg3Data : rtTmp4;
    wire [n-1: 0] rtTmp2 = (rt2 == 1'b1) ? reg2Data : rtTmp3;
    wire [n-1: 0] rtTmp1 = (rt1 == 1'b1) ? reg1Data : rtTmp2;
    assign o_rt_data = (rt0 == 1'b1) ? reg0Data : rtTmp1;


   /***********************
    * TODO YOUR CODE HERE *
    ***********************/

endmodule
