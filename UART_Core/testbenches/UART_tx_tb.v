`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2025 01:27:46 PM
// Design Name: 
// Module Name: UART_tx_tb
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


module UART_tx_tb();

    // Testbench parameters
    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] byte_to_send;
    reg baud_sample_tick;

    wire tx;
    wire tx_busy;

    // Instantiate the UART_tx module
    UART_tx uut (
        .tx_start(tx_start),
        .byte_to_send(byte_to_send),
        .rst(rst),
        .baud_sample_tick(baud_sample_tick),
        .clk(clk),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // Clock generation (e.g., 100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;  // 10 ns period

    // Baud tick generation (simulate baud tick every ~104.167 us if 9600 baud)
    initial baud_sample_tick = 0;
    always #3255 baud_sample_tick = ~baud_sample_tick;

    // Test procedure
    initial begin
        // Initialize
        #10
        rst = 1;
        tx_start = 0;
        byte_to_send = 8'h00;
        #10
        rst = 0;
        #10
        // Send a byte
        byte_to_send = 8'hA5;   // Binary: 10100101
        tx_start = 1;
        #10
        tx_start = 0;
        
        #300000
        rst = 1;
        #300000
        rst = 0;
        #150000
        tx_start = 1;
        #10
        tx_start = 0;
    end

endmodule
