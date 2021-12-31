// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

// generic fader for karplus-strong
// out = volume * in

module ks_fader (
   input lrck,
   input rst_n,
   input [9:0] volume,
   input signed [23:0] in,
   output reg signed [23:0] out
);

wire signed [33:0] in_w = in;
wire signed [33:0] inc_volume_s = volume + 34'b1;
wire signed [33:0] out_fader_w = inc_volume_s * in_w;
wire signed [23:0] out_fader = out_fader_w[33:10];

always @ (posedge lrck) begin
   if (!rst_n) begin
      out <= 0;
   end else begin
      out <= out_fader;
   end
end

endmodule

`default_nettype wire
