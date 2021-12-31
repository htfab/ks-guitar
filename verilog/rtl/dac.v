// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2021 Tamas Hubai

`default_nettype none

// interface an i2c DAC chip (tested with CS4344)

module dac (
   input clk,           // hardware clock
   input rst_dac_n,     // reset, active low
   input signed [23:0] left,  // sample on left channel, synced to mclk
   input signed [23:0] right, // sample on right channel, synced to mclk
   input msg_en,           // incoming configuration message
   input [31:0] msg_addr,  // addressed to DAC if msg_addr is -1
   input [31:0] msg,       // contains mclk_div and sclk_div
   output mclk,         // i2c master clock
   output sclk,         // i2c bit clock
   output lrck,         // i2c left-right clock
   output sdin          // i2c output bit
);

reg [9:0] mclk_div;     // (mclk to sclk divisor) / 2 - 1
reg [9:0] sclk_div;     // (sclk to lrck divisor) / 2 - 1
reg [9:0] mctr;         // mclk division counter
reg [9:0] sctr;         // sclk division counter
reg lrsel;              // left-right selector
reg [23:0] lsamp;       // left sample, saved on lrck
reg [23:0] rsamp;       // right sample, saved on lrck
reg cbit;               // register for i2c output bit

wire [8:0] sidx = sctr[9:1];  // i2c output bit index (valid for 0..23, send zero bit if >23)

assign mclk = clk;
assign sclk = sctr[0];
assign lrck = lrsel;

always @ (posedge mclk) begin
   if (!rst_dac_n) begin
      mclk_div <= 10'd7;
      sclk_div <= 10'd63;
   end else begin
      if (msg_en && (msg_addr == ~32'b0)) begin
         mclk_div <= msg[31:22];
         sclk_div <= msg[21:12];
      end   
   end
end

always @ (posedge mclk) begin
   if (!rst_dac_n) begin
      mctr <= 0;
      sctr <= 0;
      lsamp <= 0;
      rsamp <= 0;
   end else begin
      if (mctr == mclk_div) begin  // mctr wraps around, sclk flips
         mctr <= 0;
         if (!sclk) begin   // sync to sclk positive edge
            if (sidx < 24) begin
               if (!lrck) cbit <= lsamp[23-sidx];  // valid bit index on left channel
               else       cbit <= rsamp[23-sidx];  // valid bit index on right channel          
            end else      cbit <= 0;               // invalid bit index (>23)
         end
         if (sctr == sclk_div) begin  // sctr wraps around
            sctr <= 0;
            if (lrsel) begin  // save next sample
               lrsel <= 1'b0;
               lsamp <= left;
               rsamp <= right;
            end else begin
               lrsel <= 1'b1;
            end
         end else begin
            sctr <= sctr + 10'b1;
         end
      end else begin
         mctr <= mctr + 10'b1;
      end
   end
end
   
assign sdin = cbit;

endmodule

`default_nettype wire
