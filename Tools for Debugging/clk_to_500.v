`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2025 01:57:09 PM
// Design Name: 
// Module Name: clk_to_500
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_to_500(
    input clk,
    input rst,
    output reg clk_500
    );

    localparam DIVISOR = 200_000;  // 100 MHz / 100,000 = 1 kHz

    reg [16:0] counter;  // log2(100000) ≈ 17 bits

    always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            clk_500 <= 0;
        end else begin
            if (counter == (DIVISOR / 2 - 1)) begin
                counter <= 0;
                clk_500 <= ~clk_500;  // toggle output clock
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
