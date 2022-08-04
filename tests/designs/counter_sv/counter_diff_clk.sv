// Copyright (C) 2021  The Symbiflow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC

module top (
    input  logic clk_p, clk_n,
    input  logic rst,
    output logic [3:0] io_led
);

wire clk;

IBUFDS ibuf_ds (.I(clk_p), .IB(clk_n), .O(clk));

logic [31:0] counter = 32'b0;

assign io_led = counter[25:22];

always @(posedge clk)
begin
    if(rst)
        counter <= 32'b0;
    else
        counter <= counter + 1;
end

endmodule
