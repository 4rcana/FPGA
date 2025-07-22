`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2025 03:12:31 PM
// Design Name: 
// Module Name: UART_BRAM_traffic_controller
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


module UART_BRAM_traffic_controller # (
    parameter   DATA_WIDTH      =   8,
    parameter   ADDR_WIDTH      =   12,
    parameter   SIZE            =   4096
)(
    input                           clk,
    input                           rst,
    input       [DATA_WIDTH-1:0]    din,
    input                           rx_done,
    input                           tx_busy,
    input       [DATA_WIDTH-1:0]    from_BRAM,
    output  reg                     en,
    output  reg                     write_enable,
    output  reg [ADDR_WIDTH-1:0]    addr,
    output  reg [DATA_WIDTH-1:0]    to_BRAM,
    output  reg                     tx_start,
    output  reg [DATA_WIDTH-1:0]    dout
);
    
    BRAM # (
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .SIZE(SIZE)
    ) BRAM_inst (
        .clk(clk),
        .addr(addr),
        .din(to_BRAM),
        .dout(from_BRAM),
        .en(en),
        .write_enable(write_enable)
    );
    
    localparam  IDLE_STATE      =   0;
    localparam  READ_STATE      =   1;
    localparam  WRITE_STATE     =   2;
    localparam  ERASE_STATE     =   3;
    
    localparam  READ_COMMAND    =   8'h11;
    localparam  WRITE_COMMAND   =   8'h12;
    localparam  ERASE_COMMAND   =   8'h13;
    
    localparam  ASCII_ESCAPE    =   8'h1B;
    
    
    reg [1:0]   STATE;
    reg         rx_done_d;
    reg         rx_done_posedge;
    reg         rx_done_negedge;
    
    // rx_done rising edge detection
    always @ (posedge clk) begin
        rx_done_d <= rx_done;
        rx_done_posedge <= rx_done & ~rx_done_d;
        rx_done_negedge <= ~rx_done & rx_done_d;
    end
    
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            STATE <= IDLE_STATE;
            en <= 0;
            write_enable <= 0;
            addr <= 0;
            
        end else begin
            case (STATE)
            
                IDLE_STATE: begin
                    if (rx_done_posedge) begin
                        if (din == READ_COMMAND) begin
                            STATE <= READ_STATE;
                        end
                        if (din == WRITE_COMMAND) begin
                            STATE <= WRITE_STATE;
                        end
                        if (din == ERASE_COMMAND) begin
                            STATE <= ERASE_STATE;
                        end
                    end else begin
                        addr <= 0;
                        to_BRAM <= 0;
                    end
                end
                
                READ_STATE: begin
                    if (addr == SIZE-1) begin
                        STATE <= IDLE_STATE;
                        tx_start <= 0;
                        en <= 0;
                    end else begin
                        if (!tx_busy) begin
                            dout <= from_BRAM;
                            addr <= addr + 1;
                            tx_start <= 1;
                            en <= 1;
                        end
                        
                    end
                end
                
                WRITE_STATE: begin
                    if (addr == SIZE-1 || din == ASCII_ESCAPE) begin
                        STATE <= IDLE_STATE;
                        en <= 0;
                        write_enable <= 0;
                    end else begin
                        if (rx_done_posedge) begin
                            addr <= addr + 1;
                            to_BRAM <= din;
                            en <= 1;
                            write_enable <= 1;
                        end
                    end
                end
                
                ERASE_STATE: begin
                    if (addr == SIZE-1) begin
                        STATE <= IDLE_STATE;
                        en <= 0;
                        write_enable <= 0;
                    end else begin
                        addr <= addr + 1;
                        to_BRAM <= 0;
                        en <= 1;
                        write_enable <= 1;
                    end
                end
            
            endcase
        end
    end

endmodule
