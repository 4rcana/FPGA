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

// NEED FIXING
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
    output  reg [DATA_WIDTH-1:0]    dout,
    output  reg [1:0]               led
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
    reg         tx_busy_d;
    reg         tx_busy_negedge;
    reg         tx_busy_negedge_d;
    reg         en_d;
    
    // edge detection and delays
    always @ (posedge clk) begin
        rx_done_d <= rx_done;
        rx_done_posedge <= rx_done & ~rx_done_d;
        rx_done_negedge <= ~rx_done & rx_done_d;
        tx_busy_d <= tx_busy;
        tx_busy_negedge <= ~tx_busy & tx_busy_d;
        tx_busy_negedge_d <= tx_busy_negedge;
        en_d <= en;
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
                led <= 2'b00;
                    if (rx_done_posedge) begin
                        case (din)
                        
                            READ_COMMAND: begin
                                STATE <= READ_STATE;
                                en <= 1;
                            end
                            
                            WRITE_COMMAND: begin
                                STATE <= WRITE_STATE;
                                en <= 1;
                                write_enable <= 1;
                            end
                            
                            ERASE_COMMAND: begin
                                STATE <= ERASE_STATE;
                                en <= 1;
                                write_enable <= 1;
                            end
                            
                        endcase
                    end else begin
                        en <= 0;
                        write_enable <= 0;
                        dout <= 0;
                        addr <= 0;
                        tx_start <= 0;
                    end
                end
                // WORKS
                READ_STATE: begin
                    led <= 2'b01;
                    if (addr == SIZE-1 || (en_d && !from_BRAM)) begin
                        STATE <= IDLE_STATE;
                        tx_start <= 0;
                    end else begin
                        if (en_d) begin
                            dout <= from_BRAM;
                            if (tx_busy_negedge) begin
                                addr <= addr + 1;
                            end
                            if (!tx_busy_d && !tx_busy_negedge && !tx_busy_negedge_d) begin
                                tx_start <= 1;
                            end else begin
                                tx_start <= 0;
                            end
                        end
                    end
                end
                // WORKS
                WRITE_STATE: begin
                    led <= 2'b10;
                    if (addr == SIZE-1 || din == ASCII_ESCAPE) begin
                        STATE <= IDLE_STATE;
                    end else begin
                        if (din != WRITE_COMMAND) begin
                            if (rx_done_posedge) begin
                                to_BRAM <= din;
                            end
                            if (rx_done_negedge) begin
                                addr <= addr + 1;
                                to_BRAM <= 0;
                            end
                        end
                    end
                end
                // WORKS (although a minor bug appears and the address is incremented +1 than actually needed)
                ERASE_STATE: begin
                    led <= 2'b11;
                    if (addr == SIZE-1 || (en_d && !from_BRAM)) begin
                        STATE <= IDLE_STATE;
                    end else begin
                        to_BRAM <= 0;
                        addr <= addr + 1;
                    end
                end
            
            endcase
        end
    end

endmodule
