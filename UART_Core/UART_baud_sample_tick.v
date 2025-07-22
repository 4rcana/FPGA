`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2025 11:20:56 AM
// Design Name: 
// Module Name: UART_baud
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


module UART_baud # (
    parameter       CLOCK_RATE  =   100_000_000,
    parameter       BAUD_RATE   =   9600,
    parameter       OVERSAMPLE  =   16
)(
    input           clk,
    input           rst,
    output  reg     baud_sample_tick
    );
    
    localparam TICKS_PER_BIT = CLOCK_RATE / (BAUD_RATE * OVERSAMPLE);
    localparam TICK_COUNTER_WIDTH = $clog2(TICKS_PER_BIT);
    
    reg [TICK_COUNTER_WIDTH-1:0] tick_counter;
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            tick_counter <= 0;
            baud_sample_tick <= 0;
        end else begin
            if(tick_counter == TICKS_PER_BIT / 2 - 1) begin
                baud_sample_tick <= ~baud_sample_tick;
                tick_counter <= 0;
            end else begin
                tick_counter <= tick_counter + 1;
            end
        end
    end
    
endmodule
