// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

// wrapper for ks to control with messages

module ks_wrap(
   input lrck,
   input rst_n,
   input msg_en,
   input [8:0] msg_addr,
   input [31:0] msg,
   input signed [23:0] in,
   output signed [23:0] out,
   output overflow
);

reg [9:0] delay;
reg [9:0] stretch;
reg [9:0] loss;
reg signed [9:0] tuning;
reg [9:0] dynamics;
reg [9:0] volume;
reg [9:0] sympat;
reg panic;
reg pluck;

ks_string ks_string_inst (
   .lrck(lrck),
   .rst_n(rst_n & !panic),
   .delay(delay),
   .stretch(stretch),
   .loss(loss),
   .tuning(tuning),
   .dynamics(dynamics),
   .volume(volume),
   .sympat(sympat),
   .pluck(pluck),
   .in(in),
   .out(out),
   .overflow(overflow)
);

wire [2:0] ctrl1 = msg_addr[8:6];
wire [2:0] ctrl2 = msg_addr[5:3];
wire [2:0] ctrl3 = msg_addr[2:0];
wire [9:0] val1 = msg[31:22];
wire [9:0] val2 = msg[21:12];
wire [9:0] val3 = msg[11:2];
wire val_panic = msg[1];
wire val_pluck = msg[0];

always @ (posedge lrck) begin
   if (!rst_n) begin
      delay <= 10'b0000110000;
      stretch <= 10'b1000000000;
      loss <= 10'b1111111110;
      tuning <= 10'sb0000000000;
      dynamics <= 10'b0000000000;
      volume <= 10'b1111111111;
      sympat <= 10'b0000000000;
      panic <= 0; 
      pluck <= 0;
   end else begin
      if (msg_en) begin
         case (ctrl1)
            1: delay <= val1;
            2: stretch <= val1;
            3: loss <= val1;
            4: tuning <= val1;
            5: dynamics <= val1;
            6: volume <= val1;
            7: sympat <= val1;         
         endcase
         case (ctrl2)
            1: delay <= val2;
            2: stretch <= val2;
            3: loss <= val2;
            4: tuning <= val2;
            5: dynamics <= val2;
            6: volume <= val2;
            7: sympat <= val2;
         endcase
         case (ctrl3)
            1: delay <= val3;
            2: stretch <= val3;
            3: loss <= val3;
            4: tuning <= val3;
            5: dynamics <= val3;
            6: volume <= val3;
            7: sympat <= val3;
         endcase
         panic <= val_panic;
         pluck <= val_pluck;
      end else begin
         panic <= 0;
         pluck <= 0;
      end   
   end
end

endmodule

`default_nettype wire
