// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

// programmable delay line for karplus-strong

// the two versions of ks_delay are functionally equivalent
// use this one if buffer[] synthesises to dual-port ram access

module ks_delay_mem (
   input lrck,
   input rst_n,
   input signed [23:0] in,
   input [9:0] delay,
   output reg signed [23:0] out
);

reg signed [23:0] buffer [`MAXDELAY:0];
reg [9:0] write;
reg [9:0] read;
reg [9:0] fill;

always @ (posedge lrck) begin
   if (!rst_n) begin
      out <= 24'b0;
      write <= 10'b0;
      read <= 10'b0;
      fill <= 10'b0;
   end else begin
      if (fill <= `MAXDELAY) fill <= fill + 10'b1;
      if (read < fill) begin
         out <= buffer[read];
      end else begin
         out <= 24'sb0;
      end
      if (write + 10'b1 < delay) begin
         read <= write + `MAXDELAY + 10'b10 - delay;
      end else begin
         read <= write + 10'b1 - delay;
      end
      buffer[write] <= in;
      if (write >= `MAXDELAY) begin
         write <= 10'b0;
      end else begin
         write <= write + 10'b1;
      end
   end
end

endmodule

`default_nettype wire
