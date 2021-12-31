// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

// karplus-strong guitar with dac output, without caravel specifics

module core (
   input clk,
   input rst_n,
   input msg_en,
   input [31:0] msg_addr,
   input [31:0] msg,
   output mclk,
   output lrck,
   output sclk,
   output sdin
);

wire signed [23:0] ks_out;
wire ks_overflow;
ks_guitar ks_guitar_inst (
   .lrck(lrck),
   .rst_n(rst_n),
   .msg_en(msg_en),
   .msg_addr(msg_addr),
   .msg(msg),
   .out(ks_out),
   .overflow(ks_overflow)
);

dac dac_inst (
   .clk(clk),
   .rst_dac_n(rst_n),
   .left(ks_out),
   .right(ks_out),
   .msg_en(msg_en),
   .msg_addr(msg_addr),
   .msg(msg),
   .mclk(mclk),
   .sclk(sclk),
   .lrck(lrck),
   .sdin(sdin)
);

endmodule

`default_nettype wire
