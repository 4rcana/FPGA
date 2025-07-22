`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2025 02:40:21 PM
// Design Name: 
// Module Name: seven_seg_tb
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

module seven_seg_tb();

    reg clk;
    reg clk_500;
    reg rx_done;
    reg [7:0] received_byte;
    wire [6:0] seg;
    wire [3:0] an;

    // Instantiate the seven_seg module
    seven_seg uut (
        .clk(clk),
        .clk_500(clk_500),
        .rx_done(rx_done),
        .received_byte(received_byte),
        .seg(seg),
        .an(an)
    );

    // Generate main clock (e.g., 100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz clock period = 10ns

    // Generate clk_500 (~500 Hz for multiplexing)
    initial clk_500 = 0;
    always #1000000 clk_500 = ~clk_500; // Toggle every 1 ms => 500 Hz

    initial begin
        // Initialize inputs
        rx_done = 0;
        received_byte = 0;

        // Wait some time and send a byte (e.g., 123)
        #200000; // wait 200 us
        received_byte = 8'd123;
        rx_done = 1;
        #10;     // pulse rx_done for 10 ns
        rx_done = 0;

    end

endmodule
