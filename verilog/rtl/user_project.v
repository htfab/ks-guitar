// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

module user_project (
`ifdef USE_POWER_PINS
    inout vccd1,  // User area 1 1.8V supply
    inout vssd1,  // User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);

// clock & reset
wire clk = wb_clk_i;
wire rst_n = ~wb_rst_i;

// single cycle input only wishbone logic
wire [21:0] inputs;
wire valid = wbs_stb_i && wbs_cyc_i;
assign wbs_ack_o = valid;
wire msg_en = valid && wbs_we_i;
wire [31:0] msg_addr = msg_en ? wbs_adr_i : 0;
wire [31:0] msg = msg_en ? wbs_dat_i : 0;
assign wbs_dat_o = {10'b0, inputs};

// pin assignment
wire mclk;
wire lrck;
wire sclk;
wire sdin;
assign inputs = io_in[33:12];
assign io_out[33:0] = 34'b0;
assign io_out[34] = mclk;
assign io_out[35] = lrck;
assign io_out[36] = sclk;
assign io_out[37] = sdin;
assign io_oeb[33:0] = {34{1'b1}}; // input
assign io_oeb[37:34] = {4{1'b0}}; // output

// logic analyzer is unused
assign la_data_out = 128'b0;

// irq is unused
assign irq = 3'b0;

core core_inst (
    .clk(clk),
    .rst_n(rst_n),
    .msg_en(msg_en),
    .msg_addr(msg_addr),
    .msg(msg),
    .mclk(mclk),
    .lrck(lrck),
    .sclk(sclk),
    .sdin(sdin)
);

endmodule
`default_nettype wire
