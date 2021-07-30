// Copyright (C) 2021  The Symbiflow Authors.
//
// Use of this source code is governed by a ISC-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/ISC
//
// SPDX-License-Identifier: ISC

module ram0(
    // Write port
    input wrclk,
    input [31:0] di,
    input wren,
    input [8:0] wraddr,
    // Read port
    input rdclk,
    input rden,
    input [8:0] rdaddr,
    output reg [31:0] do);

    (* ram_style = "block" *) reg [31:0] ram[0:511];

    integer i;
    initial begin
        for (i=0; (i<511); i=(i+1)) begin
            if ( i % 10 == 0)
                ram[i] = 32'b00000000_00000000_00000000_00000001;
            else if ( i % 10 == 1)
                ram[i] = 32'b10101010_10101010_10101010_10101010;
            else if ( i % 10 == 2)
                ram[i] = 32'b01010101_01010101_01010101_01010101;
            else if ( i % 10 == 3)
                ram[i] = 32'b11111111_11111111_11111111_11111111;
            else if ( i % 10 == 4)
                ram[i] = 32'b11110000_11110000_11110000_11110000;
            else if ( i % 10 == 5)
                ram[i] = 32'b00001111_00001111_00001111_00001111;
            else if ( i % 10 == 6)
                ram[i] = 32'b11001100_11001100_11001100_11001100;
            else if ( i % 10 == 7)
                ram[i] = 32'b00110011_00110011_00110011_00110011;
            else if ( i % 10 == 8)
                ram[i] = 32'b00000000_00000010_00000000_00000010;
            else if ( i % 10 == 9)
                ram[i] = 32'b00000000_00000100_00000000_00000100;
        end
    end

    always @ (posedge wrclk) begin
        if(wren) begin
            ram[wraddr] <= di;
        end
    end

    always @ (posedge rdclk) begin
        if(rden) begin
            do <= ram[rdaddr];
        end
    end
endmodule

module top (
    input  wire clk,

    input  wire rx,
    output wire tx,

    input  wire butu,
    input  wire butd,
    input  wire butl,
    input  wire butr,
    input  wire butc,

    input  wire [15:0] sw,
    output wire [15:0] led
);
    wire rden;
    reg wren;
    wire [8:0] rdaddr;
    wire [8:0] wraddr;
    wire [31:0] di;
    wire [31:0] do;
    ram0 ram(
        .wrclk(clk),
        .di(di),
        .wren(wren),
        .wraddr(wraddr),
        .rdclk(clk),
        .rden(rden),
        .rdaddr(rdaddr),
        .do(do)
    );

    reg [8:0] address_reg;

    reg [31:0] data_reg;
    reg [15:0] out_reg;

    assign rdaddr = address_reg;
    assign wraddr = address_reg;

    // display_mode == 00 -> ram[address_reg][15:0]
    // display_mode == 00 && butc -> ram[address_reg][31:16]
    // display_mode == 01 -> address_reg
    // display_mode == 10 -> data_reg[15:0]
    // display_mode == 11 -> data_reg[31:16]
    wire [1:0] display_mode;

    // input_mode == 00 -> in[8:0] -> address_reg
    // input_mode == 01 && butl -> in[7:0] -> data_reg[7:0]
    // input_mode == 01 && butr -> in[7:0] -> data_reg[15:8]
    // input_mode == 10 && butl -> in[7:0] -> data_reg[23:16]
    // input_mode == 10 && butr -> in[7:0] -> data_reg[31:24]
    // input_mode == 11 -> data_reg -> ram[address_reg]
    wire [1:0] input_mode;

    // WE == 0 -> address_reg and data_reg unchanged.
    // WE == 1 -> address_reg or data_reg is updated because on input_mode.
    wire we;
    wire butc_good;

    assign display_mode[0] = sw[14];
    assign display_mode[1] = sw[15];

    assign input_mode[0] = sw[12];
    assign input_mode[1] = sw[13];

    assign we = butc;
    assign led = out_reg;
    assign di = data_reg;
    assign rden = 1;

    initial begin
        address_reg = 10'b0;
        data_reg = 32'b0;
        out_reg = 16'b0;
    end

    assign butc_good = butc;

    always @ (posedge clk) begin
        if(display_mode == 0) begin
            if (butc_good)
                out_reg <= do[31:16];
            else
                out_reg <= do[15:0];
        end else if(display_mode == 1) begin
            out_reg <= address_reg;
        end else if(display_mode == 2) begin
            out_reg <= data_reg[15:0];
        end else if(display_mode == 3) begin
            out_reg <= data_reg[31:16];
        end

        if(input_mode == 0) begin
            address_reg <= sw[10:0];
            wren <= 0;
        end else if(input_mode == 1 && butl) begin
            data_reg[7:0] <= sw[7:0];
            wren <= 0;
        end else if(input_mode == 1 && butr) begin
            data_reg[15:8] <= sw[7:0];
            wren <= 0;
        end else if(input_mode == 2 && butl) begin
            data_reg[23:16] <= sw[7:0];
            wren <= 0;
        end else if(input_mode == 2 && butr) begin
            data_reg[31:24] <= sw[7:0];
            wren <= 0;
        end else if(input_mode == 3 && we == 1) begin
            wren <= 1;
        end
    end

    // Uart loopback
    assign tx = rx;
endmodule
