`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2025 11:20:56 AM
// Design Name: 
// Module Name: UART_tx
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


module UART_tx # (
    parameter           OVERSAMPLE  =   16
)(
    input               tx_start,
    input       [7:0]   byte_to_send,
    input               rst,
    input               baud_sample_tick,
    input               clk,
    output  reg         tx,
    output  reg         tx_busy
    );
    
    localparam  IDLE_STATE  =   0;
    localparam  START_STATE =   1;
    localparam  DATA_STATE  =   2;
    localparam  DONE_STATE  =   3;
    localparam  BAUD_SAMPLE_TICK_COUNTER_WIDTH = $clog2(OVERSAMPLE);
        
    reg [1:0]   STATE;
    reg [BAUD_SAMPLE_TICK_COUNTER_WIDTH-1:0] baud_sample_tick_counter;
    reg [2:0]   bit_counter;
    reg         baud_tick;
    reg         baud_sample_tick_d;
    reg         baud_sample_tick_posedge;
    reg [7:0]   tx_byte;

    // Reset logic
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            STATE <= IDLE_STATE;
            tx <= 1;
            tx_busy <= 0;
            bit_counter <= 0;
            baud_sample_tick_counter <= 0;
            
        end else begin
        
            // tx_busy flag and data latching to local reg
            if (STATE == IDLE_STATE && tx_start) begin
                tx_busy <= 1;
                STATE <= START_STATE;
                bit_counter <= 0;
                baud_sample_tick_counter <= 0;
                tx_byte <= byte_to_send;
            end
            //////////////////////////////////////////////////////////////
            
            // Rising edge detection and baud_tick generation
            baud_sample_tick_d <= baud_sample_tick;
            baud_sample_tick_posedge <= baud_sample_tick & ~baud_sample_tick_d;
            
            if (baud_sample_tick_posedge) begin
            
                if (baud_sample_tick_counter == (OVERSAMPLE - 1)) begin
                    baud_tick <= 1;
                    baud_sample_tick_counter <= 0;
                    
                end else begin
                    baud_sample_tick_counter <= baud_sample_tick_counter + 1;
                end
                
            end else begin
                baud_tick <= 0;
            end
            ///////////////////////////////////////////////////////////////
            
            // Tx logic timed by baud_tick
            if (baud_tick) begin
                case (STATE)
                
                    IDLE_STATE: begin
                        tx <= 1;
                        tx_busy <= 0;
                    end
                
                    START_STATE: begin
                        tx <= 0;
                        STATE <= DATA_STATE;
                    end
                    
                    DATA_STATE: begin
                        tx <= tx_byte[bit_counter];
                        if (bit_counter == 7) begin
                            STATE <= DONE_STATE;
                            bit_counter <= 0;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end
                    
                    DONE_STATE: begin
                        tx <= 1;
                        STATE <= IDLE_STATE;
                    end
                endcase
            end
            ///////////////////////////////////////////////////////
        end
    end
    
endmodule