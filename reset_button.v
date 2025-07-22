`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2025 03:34:33 PM
// Design Name: 
// Module Name: reset_button
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
module reset_button(
    input       btnC,
    output reg  rst
    );
    
    assign btnC = rst;
    
endmodule
