# asynchronous-FIFO
# Asynchronous FIFO (Verilog)

This project implements an **Asynchronous FIFO** in Verilog with Gray-coded pointers and dual-clock domain support.

## Features

- Dual-clock (write and read clock can be independent)
- Gray code pointer synchronization
- Full and empty flag detection
- Configurable data width and depth

## File Structure

| File              | Description                                  |
|-------------------|----------------------------------------------|
| `async_fifo.v`    | Main FIFO module                             |
| `tb_async_fifo.v` | Testbench with dual-clock verification       |
| `README.md`       | Project description                          |

## Parameters

- `DATA_WIDTH`: Width of data in bits (default: 8)
- `PTR_SIZE`: Size of address pointers (default: 4 → FIFO depth = 16)

## Usage

### Simulation

```bash
iverilog -o fifo_tb async_fifo.v tb_async_fifo.v
vvp fifo_tb
gtkwave fifo_tb.vcd
