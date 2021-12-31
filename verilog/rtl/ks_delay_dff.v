// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

// programmable delay line for karplus-strong

// the two versions of ks_delay are functionally equivalent
// this version uses less space if memory blocks are unavailable

module ks_delay_dff (
	input lrck,
	input rst_n,
	input signed [23:0] in,
	input [9:0] delay,
	output reg signed [23:0] out
);

reg signed [23:0] buffer [`MAXDELAY-1:0];
reg [9:0] ignore;

generate genvar i;
	always @ (posedge lrck) buffer[0] <= in;
	for (i=0; i<`MAXDELAY-1; i=i+1) begin : propagate
		always @ (posedge lrck) buffer[i+1] <= buffer[i];
	end
endgenerate

always @ (posedge lrck) begin
	if (!rst_n) begin
		out <= 24'b0;
		ignore <= 10'b0;
	end else begin
		if (ignore < delay) begin
			out <= 24'b0;
			ignore <= ignore + 10'b1;
		end else begin
			out <= (delay < 2) ? in : buffer[delay-2];
		end
	end
end

endmodule

`default_nettype wire
