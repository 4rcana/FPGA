`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/21/2025 02:56:18 PM
// Design Name: 
// Module Name: BRAM
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


module BRAM # (
    parameter   DATA_WIDTH  =   8,
    parameter   ADDR_WIDTH  =   12,
    parameter   SIZE        =   4096
)(
    input                           clk,
    input       [ADDR_WIDTH-1:0]    addr,
    input       [DATA_WIDTH-1:0]    din,
    input                           write_enable,
    input                           en,
    output  reg [DATA_WIDTH-1:0]    dout
    );
    
    reg [DATA_WIDTH-1:0] memory [SIZE-1:0];
    
    always @ (posedge clk) begin
        if (en) begin
            if (write_enable) begin
                memory[addr] <= din;
            end
            dout <= memory[addr];
        end
    end
    
endmodule
