`timescale 1 ns / 1 ps
`default_nettype none

module tb;

`include "utils.v"

reg clk;
reg rst;
reg in;

always #5 clk <= !clk;

initial begin
    clk <= 1'd0;
    rst <= 1'd1;
    in <= 1'd0;

    #100 rst <= 1'b0;
    $dumpfile(`STRINGIFY(`VCD));
    $dumpvars;
    #500 $finish();
end

wire out;
top dut(
    .i(in),
    .o(out)
);

always @(posedge clk) begin
    if (rst)
        in <= 0;
    else
        in <= !in;

    assert(out == in, out);
end

endmodule
