// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

// combination of several ks strings

module ks_guitar(
   input lrck,
   input rst_n,
   input msg_en,
   input [31:0] msg_addr,
   input [31:0] msg,
   output reg signed [23:0] out,
   output reg overflow
);

wire signed [23:0] string_out [`STRINGS-1:0];
wire string_overflow [`STRINGS-1:0];
wire signed [27:0] acc_out [`STRINGS:0];
wire acc_overflow [`STRINGS:0];
wire [22:0] msg_sel = msg_addr[31:9];
wire [9:0] msg_string_addr = msg_addr[8:0];

generate genvar i;
   assign acc_out[0] = 28'sb0;
   assign acc_overflow[0] = 1'b0;
   for (i=0; i<`STRINGS; i=i+1) begin:iter
      ks_wrap ks_wrap_inst (
         .lrck(lrck),
         .rst_n(rst_n),
         .msg_en(msg_en && (msg_sel == i)),
         .msg_addr((msg_sel == i) ? msg_string_addr : 9'b0),
         .msg((msg_sel == i) ? msg : 32'b0),
         .in(out),
         .out(string_out[i]),
         .overflow(string_overflow[i])       
      );
      assign acc_out[i+1] = acc_out[i] + string_out[i];
      assign acc_overflow[i+1] = acc_overflow[i] | string_overflow[i];
   end
endgenerate

wire signed [27:0] sum = acc_out[`STRINGS];
wire any_overflow = acc_overflow[`STRINGS];
reg clipped;

always @ (posedge lrck) begin
   if (!rst_n) begin 
      out <= 24'sb0;
      clipped <= 1'b0;
      overflow <= 1'b0;
   end else begin
      out <= sum[23:0];
      if (&sum[27:23] || ~|sum[27:23]) begin
         clipped <= 1'b1;
         overflow <= 1'b1;
      end else begin
         overflow <= any_overflow | clipped;
      end
   end
end

endmodule

`default_nettype wire
