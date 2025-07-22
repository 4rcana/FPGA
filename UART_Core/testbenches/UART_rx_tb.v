`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2025 02:30:07 PM
// Design Name: 
// Module Name: UART_rx_tb
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


module UART_rx_tb();

    localparam OVERSAMPLE = 16;
    reg clk;
    reg rst;
    reg rx;
    reg baud_sample_tick;
    wire [7:0] received_byte;
    wire rx_done;

    // Instantiate DUT
    UART_rx #(.OVERSAMPLE(OVERSAMPLE)) dut (
        .rx(rx),
        .rst(rst),
        .baud_sample_tick(baud_sample_tick),
        .clk(clk),
        .received_byte(received_byte),
        .rx_done(rx_done)
    );

    // Clock generation (100 MHz clock, 10ns period)
    initial clk = 0;
    initial baud_sample_tick = 0;
    always #5 clk = ~clk;
    always #3255 baud_sample_tick = ~baud_sample_tick;

    // Variables for simulation
    reg [7:0] data_to_send = 8'b1001_0110; // example byte to send
    integer i;

    // Test sequence
    initial begin
        // Initialize signals
        #10
        rst = 1;
        rx = 1; // idle line is HIGH
        #10
        rst = 0;
        #30

        // Send UART frame: Start bit (0), 8 data bits LSB first, Stop bit (1)
        send_uart_byte(data_to_send);

        #100;
    end

    // Task to send a UART byte serially
    task send_uart_byte(input [7:0] byte);
        integer bit_i;
        begin
            // Start bit (0)
            drive_rx_bit(0);

            // Data bits LSB first
            for(bit_i = 0; bit_i < 8; bit_i = bit_i + 1) begin
                drive_rx_bit(byte[bit_i]);
            end

            // Stop bit (1)
            drive_rx_bit(1);
        end
    endtask

    // Task to drive rx line for one UART bit period (OVERSAMPLE baud_sample_ticks)
    task drive_rx_bit(input bit_value);
        integer tick_count;
        begin
            rx = bit_value;
            // Hold rx stable for OVERSAMPLE baud_sample_ticks
            for(tick_count = 0; tick_count < OVERSAMPLE; tick_count = tick_count + 1) begin
                @(posedge baud_sample_tick);
            end
        end
    endtask

endmodule
