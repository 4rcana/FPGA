`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2025 12:08:04 PM
// Design Name: 
// Module Name: UART_BRAM_traffic_controller_tb
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

module UART_BRAM_traffic_controller_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 12;
    parameter SIZE = 4096;

    // Signals
    reg clk = 0;
    reg rst;
    reg [DATA_WIDTH-1:0] din;
    reg rx_done;
    reg tx_busy;
    wire [DATA_WIDTH-1:0] from_BRAM;
    wire en;
    wire write_enable;
    wire [ADDR_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] to_BRAM;
    wire tx_start;
    wire [DATA_WIDTH-1:0] dout;

    // Instantiate DUT
    UART_BRAM_traffic_controller #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .SIZE(SIZE)
    ) dut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .rx_done(rx_done),
        .tx_busy(tx_busy),
        .from_BRAM(from_BRAM),
        .en(en),
        .write_enable(write_enable),
        .addr(addr),
        .to_BRAM(to_BRAM),
        .tx_start(tx_start),
        .dout(dout)
    );

    // Internal BRAM signal for simple modeling
    reg [DATA_WIDTH-1:0] memory [0:SIZE-1];
    
    integer i;

    // Clock generation
    always #5 clk = ~clk;

    // Drive fake BRAM output

    initial begin
        rst = 1;
        din = 0;
        rx_done = 0;
        tx_busy = 0;

        // Initialize memory
        for (i = 0; i < SIZE; i = i + 1) begin
            memory[i] = 0;
        end

        #20;
        rst = 0;

        // === WRITE SEQUENCE ===
        send_uart_byte(8'h12);  // WRITE_COMMAND
        #500;
        send_uart_byte(8'hAA);
        #30;
        send_uart_byte(8'hBB);
        #30;
        send_uart_byte(8'hCC);
        #30;
        send_uart_byte(8'h1B);     // ESCAPE to end write
        #300;

        // === READ SEQUENCE ===
        //send_uart_byte(8'h11);  // READ_COMMAND
        
        din = 8'h11;
        rx_done = 1;
        #30;
        
        
        repeat (4096*2) begin
            tx_busy = 1;
            #120;
            tx_busy = 0;
            #30;
        end
        
        rx_done = 0;
        
        #50000

        // === ERASE SEQUENCE ===
        send_uart_byte(8'h13);  // ERASE_COMMAND
    end

    // Task to simulate receiving a data byte
    task send_uart_byte(input [7:0] byte);
        begin
            @(posedge clk);
            din = byte;
            rx_done = 1;
            #500
            rx_done = 0;
        end
    endtask

endmodule

