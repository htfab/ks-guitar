// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

// dynamics lowpass filter for karplus-strong
// out = (1-dynamics) * in + dynamics * out_{-1}

module ks_dynamics (
   input lrck,
   input rst_n,
   input [9:0] dynamics,
   input signed [23:0] in,
   output reg signed [23:0] out
);

reg signed [23:0] last_out;
wire signed [33:0] last_out_w = last_out;
wire signed [33:0] in_w = in;
wire signed [33:0] dyn_s = dynamics;
wire signed [33:0] out_lowpass_w = (last_out_w - in_w) * dyn_s + (in_w << 10);
wire signed [23:0] out_lowpass = out_lowpass_w[33:10];

always @ (posedge lrck) begin
   if (!rst_n) begin
      out <= 0;
      last_out <= 0;
   end else begin
      out <= out_lowpass;
      last_out <= out;
   end
end

endmodule

`default_nettype wire
