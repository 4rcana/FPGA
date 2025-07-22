`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2025 12:27:21 PM
// Design Name: 
// Module Name: UART_baud_tb
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

module UART_baud_tb;

    // Parameters
    parameter CLOCK_RATE = 100_000_000;   // 100 MHz
    parameter BAUD_RATE  = 9600;
    parameter OVERSAMPLE = 16;
    parameter TICKS_PER_BIT = CLOCK_RATE / (BAUD_RATE * OVERSAMPLE); // ~651

    // Clock period (100 MHz = 10 ns)
    localparam CLK_PERIOD = 10;

    // DUT signals
    reg clk = 0;
    reg rst = 1;
    wire baud_sample_tick;

    // Instantiate DUT
    UART_baud #(
        .CLOCK_RATE(CLOCK_RATE),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLE(OVERSAMPLE)
    ) dut (
        .clk(clk),
        .rst(rst),
        .baud_sample_tick(baud_sample_tick)
    );

    always #(CLK_PERIOD / 2) clk <= ~clk;

    // Test process
    initial begin
        
        #50;
        rst = 1;
        #50;
        rst = 0;
    
    end
    

endmodule
