`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2025 12:10:13 PM
// Design Name: 
// Module Name: UART
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


module UART(
    input           RsRx,
    input           clk,
    input           btnC,
//    input           btnU,
    output          RsTx,
    output   [6:0]  seg,
    output   [3:0]  an,
    output   [1:0]  led
    );
    
    wire            baud_sample_tick;
    wire    [7:0]   received_byte;
    wire            rx_done;
    wire            clk_500;
    wire            rst;
    wire            tx_start;
    wire    [7:0]   byte_to_send;
    wire            tx_busy;
    wire    [11:0]  addr;
    
    UART_baud uart_baud_inst (
        .clk(clk),
        .rst(rst),
        .baud_sample_tick(baud_sample_tick)
    );
    
    UART_tx uart_tx_inst(
        .clk(clk),
        .rst(rst),
        .baud_sample_tick(baud_sample_tick),
        .tx_start(tx_start),
        .byte_to_send(byte_to_send),
        .tx_busy(tx_busy),
        .tx(RsTx)
    );
    
    UART_rx uart_rx_inst(
        .clk(clk),
        .rst(rst),
        .baud_sample_tick(baud_sample_tick),
        .rx(RsRx),
        .rx_done(rx_done),
        .received_byte(received_byte)
    );
    
    seven_seg seven_seg_inst (
        .clk(clk),
        .addr(addr),
        .clk_500(clk_500),
        .seg(seg),
        .an(an)
    );
    
    clk_to_500 clk_to_500_inst (
        .clk(clk),
        .rst(rst),
        .clk_500(clk_500)
    );
    
    reset_button reset_button_inst (
        .rst(rst),
        .btnC(btnC)
    );
/*    
    tx_button tx_button_inst (
        .clk(clk),
        .rst(rst),
        .btnU(btnU),
        .received_byte(received_byte),
        .rx_done(rx_done),
        .byte_to_send(byte_to_send),
        .tx_start(tx_start)
    );
*/
    UART_BRAM_traffic_controller UART_BRAM_traffic_controller_inst (
        .clk(clk),
        .rst(rst),
        .din(received_byte),
        .rx_done(rx_done),
        .tx_busy(tx_busy),
        .tx_start(tx_start),
        .dout(byte_to_send),
        .addr(addr),
        .led(led)
    );  
    
endmodule
