// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

// tuning allpass filter for karplus-strong
// out = tuning * in + in_{-1} - tuning * out_{-1}

module ks_tuning (
   input lrck,
   input rst_n,
   input signed [9:0] tuning,
   input signed [23:0] in,
   output reg signed [23:0] out,
   output reg overflow
);

reg signed [23:0] last_in;
reg signed [23:0] last_out;
wire signed [33:0] tuning_w = tuning;
wire signed [33:0] i_lo_diff = (34'sb0 + in) - last_out;
wire signed [33:0] last_in_w = {last_in[23], last_in, 9'sb0};
wire signed [33:0] out_tun_w = (tuning_w * i_lo_diff) + last_in_w;
wire signed [23:0] out_tun = out_tun_w[32:9];
wire ofl = out_tun_w[33] != out_tun_w[32];

always @ (posedge lrck) begin
   if (!rst_n) begin
      out <= 0;
      last_in <= 0;
      last_out <= 0;
      overflow <= 0;
   end else begin
      out <= out_tun;
      last_in <= in;
      last_out <= out;
      overflow <= overflow | ofl;
   end
end

endmodule

`default_nettype wire
