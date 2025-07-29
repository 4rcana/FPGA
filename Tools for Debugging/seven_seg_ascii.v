`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2025 11:12:12 AM
// Design Name: 
// Module Name: seven_seg
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

module seven_seg(
    input clk,
    input clk_500,                     // Fast clock for multiplexing (e.g., 1 kHz-10 kHz)
    input rx_done,                     // Pulse indicating new byte received
    input [7:0] received_byte,         // Byte to display in decimal
    output reg [6:0] seg,              // 7 segment lines (a to g)
    output reg [3:0] an                // 3-digit enable lines (active low)
);
    
    reg [3:0] hundreds = 0;
    reg [3:0] tens = 0;
    reg [3:0] ones = 0;
    reg [1:0] digit_sel = 0;

    // Decimal conversion on rx_done pulse
    always @(posedge clk) begin
        if (rx_done) begin
            hundreds <= received_byte / 100;
            tens     <= (received_byte % 100) / 10;
            ones     <= received_byte % 10;
        end
    end

    // 7-segment decoder
    function [6:0] decode_7seg;
        input [3:0] digit;
        case (digit)
            4'd0: decode_7seg = 7'b100_0000;
            4'd1: decode_7seg = 7'b111_1001;
            4'd2: decode_7seg = 7'b010_0100;
            4'd3: decode_7seg = 7'b011_0000;
            4'd4: decode_7seg = 7'b001_1001;
            4'd5: decode_7seg = 7'b001_0010;
            4'd6: decode_7seg = 7'b000_0010;
            4'd7: decode_7seg = 7'b111_1000;
            4'd8: decode_7seg = 7'b000_0000;
            4'd9: decode_7seg = 7'b001_0000;
            default: decode_7seg = 7'b111_1111; // Blank
        endcase
    endfunction

    // Digit multiplexing (rotates every clock cycle)
    always @(posedge clk_500) begin
        digit_sel <= digit_sel + 1;

        case (digit_sel)
            2'd0: begin
                seg <= decode_7seg(ones);
                an  <= 4'b1110; // Enable digit 0
            end
            2'd1: begin
                seg <= decode_7seg(tens);
                an  <= 4'b1101; // Enable digit 1
            end
            2'd2: begin
                seg <= decode_7seg(hundreds);
                an  <= 4'b1011; // Enable digit 2
            end
            2'd3: begin
                seg <= 7'b111_1111;
                an  <= 4'b0111; // Enable digit 3
            end
            default: begin
                seg <= 7'b111_1111;
                an  <= 4'b1111;
            end
        endcase
    end

endmodule
