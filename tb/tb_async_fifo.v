`timescale 1ns / 1ps

module tb_async_fifo;
  parameter DATA_WIDTH = 8;
  parameter PTR_SIZE   = 4; // FIFO depth = 2^PTR_SIZE
  parameter FIFO_DEPTH = (1 << PTR_SIZE);

  reg wr_clk = 0, rd_clk = 0;
  reg rst = 1;
  reg wr_en = 0, rd_en = 0;
  reg [DATA_WIDTH-1:0] wr_data;
  wire [DATA_WIDTH-1:0] rd_data;
  wire full, empty;

  // Instantiate FIFO
  async_fifo #(DATA_WIDTH, PTR_SIZE) dut (
    .wr_clk(wr_clk), .rd_clk(rd_clk), .rst(rst),
    .wr_en(wr_en), .wr_data(wr_data), .full(full),
    .rd_en(rd_en), .rd_data(rd_data), .empty(empty)
  );

  // Write Clock
  always #5 wr_clk = ~wr_clk;  // 100 MHz
  // Read Clock
  always #7 rd_clk = ~rd_clk;  // ~71 MHz

  initial begin
    $dumpfile("fifo_tb.vcd");
    $dumpvars(0, tb_async_fifo);

    // Reset
    #10 rst = 0;

    // Write 10 values
    repeat (10) begin
      @(posedge wr_clk);
      wr_en = 1;
      wr_data = $random;
    end
    wr_en = 0;

    // Read 10 values
    #20;
    repeat (10) begin
      @(posedge rd_clk);
      rd_en = 1;
    end
    rd_en = 0;

    #100 $finish;
  end
endmodule
