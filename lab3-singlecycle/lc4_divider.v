/* Names: Nathaniel Hoaglund - nhoag
          Chakradhar Paladi */

`timescale 1ns / 1ps
`default_nettype none

module lc4_divider(input  wire [15:0] i_dividend,
                   input  wire [15:0] i_divisor,
                   output wire [15:0] o_remainder,
                   output wire [15:0] o_quotient);
      wire [15:0] tmp_quote[16:0];
      wire [15:0] tmp_o_remainder;
      wire [15:0] tmp_o_quotient;
      wire [15:0] tmp_remain[16:0];
      wire [15:0] tmp_dividend[16:0];
      assign tmp_dividend[0] = i_dividend;
      assign tmp_quote[0] = 16'b0000000000000000;
      assign tmp_remain[0] = 16'b0000000000000000;
      genvar i;
      for (i=0; i < 16; i=i+1) begin
            lc4_divider_one_iter f(.i_dividend(tmp_dividend[i]), .i_divisor(i_divisor),
            .i_remainder(tmp_remain[i]), .i_quotient(tmp_quote[i]), .o_dividend(tmp_dividend[i + 1]),
             .o_remainder(tmp_remain[i + 1]), 
             .o_quotient(tmp_quote[i + 1]));
      end
      assign tmp_o_remainder = tmp_remain[16];
      assign tmp_o_quotient = tmp_quote[16];
      assign o_remainder = i_divisor == 0 ? 16'b0000000000000000 : tmp_o_remainder;
      assign o_quotient = i_divisor == 0 ? 16'b0000000000000000 : tmp_o_quotient;

endmodule // lc4_divider

module lc4_divider_one_iter(input  wire [15:0] i_dividend,
                            input  wire [15:0] i_divisor,
                            input  wire [15:0] i_remainder,
                            input  wire [15:0] i_quotient,
                            output wire [15:0] o_dividend,
                            output wire [15:0] o_remainder,
                            output wire [15:0] o_quotient);
//assigning initial shifting of values
      //initial shifts

      wire [15:0] remain_shift = i_remainder << 1;
      wire [15:0] dividend_shift_15 = i_dividend >> 15;
      //wire [15:0] dividend_shift_1 = i_dividend << 1;
      wire [15:0] quot_shift = i_quotient << 1;
      //assigning new remainder and oring it
      wire [15:0] dividend_and = dividend_shift_15 & 16'b0000000000000001;
      wire [15:0] remainder_or = dividend_and | remain_shift;

      //make all possible wires
      wire [15:0] quot_shift_or = quot_shift | 16'b0000000000000001;
      wire [15:0] remain_if_less = remainder_or - i_divisor;

      
      //check if remainder is less than divisor

      assign o_dividend = i_dividend << 1;
      assign o_remainder = remainder_or < i_divisor ? remainder_or : remain_if_less;
      assign o_quotient = remainder_or < i_divisor ? quot_shift : quot_shift_or;



endmodule

