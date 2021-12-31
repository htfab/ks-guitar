// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

// feedback lowpass filter for karplus-strong
// out = loss * ((1-stretch) * in + stretch * in_{-1})

module ks_feedback (
   input lrck,
   input rst_n,
   input [9:0] stretch,
   input signed [23:0] in,
   output reg signed [23:0] out
);

reg signed [23:0] last_in;
wire signed [33:0] last_in_w = last_in;
wire signed [33:0] in_w = in;
wire signed [33:0] stretch_s = stretch;
wire signed [33:0] out_lowpass_w = (last_in_w - in_w) * stretch_s + (in_w << 10);
wire signed [23:0] out_lowpass = out_lowpass_w[33:10];

always @ (posedge lrck) begin
   if (!rst_n) begin
      out <= 0;
      last_in <= 0;
   end else begin
      out <= out_lowpass;
      last_in <= in;
   end
end

endmodule

`default_nettype wire
