`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/15/2025 12:19:32 PM
// Design Name: 
// Module Name: blinky
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


module blinky(
    input clk,
    input rx_done,
    output reg led
);
    
    reg [26:0] count = 0;
    reg        flag = 0;
    
    
        
    always @ (posedge clk) begin
    
        if(rx_done) begin
            flag <= 1;
        end
        
        if(flag) begin
            if (count == 100_000_000 - 1) begin 
                count <= 0;
                led <= ~led;
            end else begin
                count <= count + 1;
            end
        end
        
    end
    
endmodule

