`timescale 1ns / 1ps

module async_fifo #(parameter DEPTH = 8, parameter WIDTH = 8) (
    input wire wr_clk,
    input wire rd_clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [WIDTH-1:0] write_data,
    output reg [WIDTH-1:0] read_data,
    output wire empty,
    output wire full
);

    localparam ADDR_SIZE = $clog2(DEPTH); // 3 for DEPTH=8
    localparam PTR_SIZE = ADDR_SIZE + 1;  // Extra bit for wrap detection

    reg [PTR_SIZE-1:0] wptr_bin, rptr_bin;
    reg [PTR_SIZE-1:0] wptr_gray, rptr_gray;
    reg [PTR_SIZE-1:0] wptr_gray_sync_rd, rptr_gray_sync_wr;
    reg [PTR_SIZE-1:0] mem [0:DEPTH-1];

    // Write logic
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            wptr_bin <= 0;
            wptr_gray <= 0;
        end else if (wr_en && !full) begin
            mem[wptr_bin[ADDR_SIZE-1:0]] <= write_data;// ptr is from [ADDR_SIZE :0] BUT we leave out the msb
            wptr_bin <= wptr_bin + 1;
            wptr_gray <= (wptr_bin + 1) ^ ((wptr_bin + 1) >> 1);
        end
    end

    // Read logic
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            rptr_bin <= 0;
            rptr_gray <= 0;
            read_data <= 0;
        end else if (rd_en && !empty) begin
            read_data <= mem[rptr_bin[ADDR_SIZE-1:0]];
            rptr_bin <= rptr_bin + 1;
            rptr_gray <= (rptr_bin + 1) ^ ((rptr_bin + 1) >> 1);
        end
    end

    // Synchronize pointers across clock domains
    reg [PTR_SIZE-1:0] wptr_gray_ff1_rd, wptr_gray_ff2_rd;
    reg [PTR_SIZE-1:0] rptr_gray_ff1_wr, rptr_gray_ff2_wr;

    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            {wptr_gray_ff2_rd, wptr_gray_ff1_rd, wptr_gray_sync_rd} <= 0;
        end else begin
            wptr_gray_ff1_rd <= wptr_gray;
            wptr_gray_ff2_rd <= wptr_gray_ff1_rd;
            wptr_gray_sync_rd <= wptr_gray_ff2_rd;
        end
    end

    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            {rptr_gray_ff2_wr, rptr_gray_ff1_wr, rptr_gray_sync_wr} <= 0;
        end else begin
            rptr_gray_ff1_wr <= rptr_gray;
            rptr_gray_ff2_wr <= rptr_gray_ff1_wr;
            rptr_gray_sync_wr <= rptr_gray_ff2_wr;
        end
    end

    // Full detection
    assign full = (wptr_gray == {~rptr_gray_sync_wr[PTR_SIZE-1], rptr_gray_sync_wr[PTR_SIZE-2:0]});

    // Empty detection
    assign empty = (rptr_gray == wptr_gray_sync_rd);

endmodule
