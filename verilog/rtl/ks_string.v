// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

// karplus-strong string model with some jaffe-smith extensions

module ks_string (
   input lrck,
   input rst_n,
   input [9:0] delay,
   input [9:0] stretch,
   input [9:0] loss,
   input signed [9:0] tuning,
   input [9:0] dynamics,
   input [9:0] volume,
   input [9:0] sympat,
   input pluck,
   input signed [23:0] in,
   output signed [23:0] out,
   output overflow
);

wire signed [23:0] burst_out;
ks_burst ks_burst_inst (
   .lrck(lrck),
   .rst_n(rst_n),
   .pluck(pluck),
   .length(delay),
   .out(burst_out)
);

wire signed [23:0] sample;
wire signed [23:0] delay_out;
ks_delay_dff ks_delay_inst (
   .lrck(lrck),
   .rst_n(rst_n),
   .in(sample),
   .delay(delay),
   .out(delay_out)
);

wire signed [23:0] feedback_out;
ks_feedback ks_feedback_inst (
   .lrck(lrck),
   .rst_n(rst_n),
   .stretch(stretch),
   .in(delay_out),
   .out(feedback_out)
);

wire signed [23:0] loss_out;
ks_fader ks_fader_loss (
   .lrck(lrck),
   .rst_n(rst_n),
   .volume(loss),
   .in(feedback_out),
   .out(loss_out)
);

wire signed [23:0] tuning_out;
wire tuning_overflow;
ks_tuning ks_tuning_inst (
   .lrck(lrck),
   .rst_n(rst_n),
   .tuning(tuning),
   .in(loss_out),
   .out(tuning_out),
   .overflow(overflow)
);

wire signed [23:0] sympat_out;
ks_fader ks_fader_sympat (
   .lrck(lrck),
   .rst_n(rst_n),
   .volume(sympat),
   .in(in),
   .out(sympat_out)
);

assign sample = burst_out + tuning_out + sympat_out;

wire signed [23:0] dynamics_out;
ks_dynamics ks_dynamics_inst (
   .lrck(lrck),
   .rst_n(rst_n),
   .dynamics(dynamics),
   .in(sample),
   .out(dynamics_out)
);

wire signed [23:0] volume_out;
ks_fader ks_fader_volume (
   .lrck(lrck),
   .rst_n(rst_n),
   .volume(volume),
   .in(dynamics_out),
   .out(volume_out)
);

assign out = volume_out;

endmodule

`default_nettype wire
