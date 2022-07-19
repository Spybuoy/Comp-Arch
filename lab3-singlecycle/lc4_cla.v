/* TODO: INSERT NAME AND PENNKEY HERE */

//Nate Hoaglund

`timescale 1ns / 1ps
`default_nettype none

/**
 * @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b;
   assign p = a | b;
endmodule

/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals 
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits collectively generate a carry (ignoring cin)
 * @param pout whether these 4 bits collectively would propagate an incoming carry (ignoring cin)
 * @param cout the carry outs for the low-order 3 bits
 */
module gp4(input wire [3:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [2:0] cout);

           wire pin_0_cin = pin[0] & cin;
           wire c1 = pin_0_cin | gin[0];
           wire pin_1_c1 = pin[1] & c1;
           wire c2 = pin_1_c1 | gin[1];
           wire pin_2_c2 = pin[2] & c2;
           wire c3 = pin_2_c2 | gin[2]; 

            assign cout[0] = c1;
            assign cout[1] = c2;
            assign cout[2] = c3;
            wire p3_g2 =  (pin[3] & gin[2]);
            wire p3_p2_g1 = ((pin[3] & pin[2]) & gin[1]);
            wire p3_p2_p1_g0 = (((pin[3] & pin[2]) & pin[1]) & gin[0]);
            assign gout = gin[3] | p3_g2 | p3_p2_g1 | p3_p2_p1_g0;
            assign pout = (& pin);
            
   
endmodule

/**
 * 16-bit Carry-Lookahead Adder
 * @param a first input
 * @param b second input
 * @param cin carry in
 * @param sum sum of a + b + carry-in
 */
module cla16
  (input wire [15:0]  a, b,
   input wire         cin,
   output wire [15:0] sum);

   wire [15:0] tempAdd;
   assign  tempAdd[15:0] = a ^ b;
   wire [15:0] tempcouts; 
   //no carry out so use cin as first carry
   assign tempcouts[0] = cin;

   wire [15:0]gp1_pout;
   wire [15:0]gp1_gout;
   wire [3:0]gp4_gout;
   wire [3:0]gp4_pout;


   genvar j;
   genvar i;
   for(i =0; i < 16; i=i+1) begin 
     gp1 z(.a(a[i]), .b(b[i]), .g(gp1_gout[i]), .p(gp1_pout[i]));
   end
  
   for(j =0; j < 4; j=j+1) begin
     
    gp4 x(.gin(gp1_gout[((j * 4) + 3):(j * 4)]), .pin(gp1_pout[((j * 4) + 3):(j * 4)]), .cin(tempcouts[(j * 4)]),
     .gout(gp4_gout[j]), .pout(gp4_pout[j]), .cout(tempcouts[((j * 4) + 3): ((j * 4) + 1)]));
   end 
   assign tempcouts[4] = gp4_gout[0] | (gp4_pout[0] & tempcouts[0]);
   assign tempcouts[8] = gp4_gout[1] | (gp4_pout[1] & tempcouts[4]);
   assign tempcouts[12] = gp4_gout[2] | (gp4_pout[2] & tempcouts[8]);

  
  assign sum = (tempcouts ^ tempAdd);



endmodule


/** Lab 2 Extra Credit, see details at
  https://github.com/upenn-acg/cis501/blob/master/lab2-alu/lab2-cla.md#extra-credit
 If you are not doing the extra credit, you should leave this module empty.
 */
module gpn
  #(parameter N = 4)
  (input wire [N-1:0] gin, pin,
   input wire  cin,
   output wire gout, pout,
   output wire [N-2:0] cout);
 


        wire[N-1:0] cgout;
        genvar i;
        genvar j;
        genvar p;

        assign cout[0] = (pin[0] & cin) | gin[0];
        for(i = 1; i < N - 1; i = i + 1) begin
          assign cout[i] = (pin[i] & cout[i-1]) | gin[i];
        end


        for(i = 1; i < N ; i = i + 1) begin
          assign cgout[i] =  (&pin[(N-1): (N-i)]) & gin[(N-i-1)];
          
        end

        assign cgout[0] = gin[N-1];
        assign pout = (& pin);
        assign gout = (|cgout) ;

        


            
endmodule

