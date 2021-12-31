// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

// generate white noise for karplus-strong

module ks_noise (
   input lrck,
   output signed [23:0] out
);

reg signed [23:0] lfsr;
wire signed [23:0] shifted [24:0];

generate genvar i;
   assign shifted[0] = lfsr;
   for (i=0; i<24; i=i+1) begin : shift
      assign shifted[i+1] = {shifted[i][22:0], ~^(shifted[i] & 24'h80000D)};
   end
endgenerate

always @ (posedge lrck) begin
   lfsr <= shifted[24];
end

assign out = lfsr;

endmodule

`default_nettype wire
