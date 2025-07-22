`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/21/2025 01:13:36 PM
// Design Name: 
// Module Name: tx_button
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

// NEED TO ADD DEBOUNCE
module tx_button(
    input               clk,
    input               rst,
    input               btnU,
    input       [7:0]   received_byte,
    input               rx_done,
    output reg  [7:0]   byte_to_send,
    output reg          tx_start
    );
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            byte_to_send <= 0;
            tx_start <= 0;
            
        end else begin
        
            if (rx_done) begin
                byte_to_send <= received_byte + 1;
            end
        
            if (btnU) begin
                tx_start <= 1;
            end else begin
                tx_start <= 0;
            end
            
        end
    end
    
endmodule
