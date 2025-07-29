`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2025 11:20:56 AM
// Design Name: 
// Module Name: UART_rx
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



module UART_rx # (
    parameter           OVERSAMPLE  =   16
)(
    input               rx,
    input               rst,
    input               baud_sample_tick,
    input               clk,
    output  reg [7:0]   received_byte,
    output  reg         rx_done
    );
    
    localparam  IDLE_STATE  =   0;
    localparam  START_STATE =   1;
    localparam  DATA_STATE  =   2;
    localparam  DONE_STATE  =   3;
    localparam  BAUD_SAMPLE_TICK_COUNTER_WIDTH = $clog2(OVERSAMPLE);
    
    reg [1:0]   STATE;
    reg [3:0]   bit_counter;
    reg [BAUD_SAMPLE_TICK_COUNTER_WIDTH-1:0]    baud_sample_tick_counter;
    reg         baud_sample_tick_d;
    reg         baud_sample_tick_posedge;

    always @ (posedge clk or posedge rst) begin
    
        if (rst) begin
            STATE <= IDLE_STATE;
            baud_sample_tick_counter <= 0;
            bit_counter <= 0;
            rx_done <= 0;
            received_byte <= 0;

        end else begin        
            if (baud_sample_tick_posedge) begin
                case (STATE)
                
                    IDLE_STATE: begin
                        rx_done <= 0;
                        bit_counter <= 0;
                        baud_sample_tick_counter <= 0;
                        if (!rx) begin
                            STATE = START_STATE;
                        end
                    end
                    
                    START_STATE: begin
                        if(baud_sample_tick_counter == ((OVERSAMPLE / 2) - 1)) begin
                            STATE <= DATA_STATE;
                            baud_sample_tick_counter <= 0;
                        end else begin
                            baud_sample_tick_counter <= baud_sample_tick_counter + 1;
                        end
                    end
                    
                    DATA_STATE: begin
                        if(baud_sample_tick_counter == (OVERSAMPLE - 1)) begin
                            if(bit_counter == 8) begin
                                STATE <= DONE_STATE;
                                bit_counter <= 0;
                            end else begin
                                received_byte[bit_counter] <= rx;
                                bit_counter <= bit_counter + 1;
                            end
                            baud_sample_tick_counter <= 0;
                            
                        end else begin
                            baud_sample_tick_counter <= baud_sample_tick_counter + 1;
                        end
                    end
                    
                    DONE_STATE: begin
                        if(baud_sample_tick_counter == ((OVERSAMPLE / 2) - 1)) begin
                            rx_done <= 1;
                            STATE <= IDLE_STATE;
                            baud_sample_tick_counter <= 0;
                        end else begin
                            baud_sample_tick_counter <= baud_sample_tick_counter + 1;
                        end
                    end
                endcase
            end
        end
    end
    
    // Rising edge detection
    always @(posedge clk) begin
        baud_sample_tick_d <= baud_sample_tick;
        baud_sample_tick_posedge <= baud_sample_tick & ~baud_sample_tick_d;
    end

endmodule