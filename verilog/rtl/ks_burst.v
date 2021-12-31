// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

// generate pluck burst for karplus-strong

module ks_burst (
   input lrck,
   input rst_n,
   input pluck,
   input [9:0] length,
   output reg signed [23:0] out
);

wire signed [23:0] noise;
ks_noise noise_inst (
   .lrck(lrck),
   .out(noise)
);

wire signed [23:0] noise_s = noise; // >>> 2;

reg prev_pluck;
reg [9:0] counter;
reg [9:0] ignore;

always @ (posedge lrck) begin
   if (!rst_n) begin
      prev_pluck <= 0;
      counter <= 10'b0;
      ignore <= 10'b0;
      out <= 0;
   end else begin
      prev_pluck <= pluck;
      if (ignore < ~10'b0) ignore <= ignore + 10'b1;
      if (ignore < length) begin
         counter <= 10'b0;
         out <= 24'b0;
      end else if (pluck && !prev_pluck) begin
         counter <= length;
         out <= noise_s;
      end else if (counter) begin
         counter <= counter - 10'b1;
         out <= noise_s;
      end else begin
         out <= 24'b0;
      end
   end
end

endmodule

`default_nettype wire
