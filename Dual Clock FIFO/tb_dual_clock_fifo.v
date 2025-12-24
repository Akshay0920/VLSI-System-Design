// Testbench for DualClockFIFO
`timescale 1ns/1ps

module tb_dual_clock_fifo;

    reg wclk, wrst_n, wen;
    reg [7:0] wdata;
    reg rclk, rrst_n, ren;
    wire [7:0] rdata;
    wire full, empty;

    dual_clock_fifo uut (
        .wclk(wclk), .wrst_n(wrst_n), .wen(wen), .wdata(wdata),
        .rclk(rclk), .rrst_n(rrst_n), .ren(ren),
        .rdata(rdata), .full(full), .empty(empty)
    );

    // Generate Clocks (Different Frequencies)
    always #5 wclk = ~wclk;   // Write Clock: 100MHz (Period 10ns)
    always #8 rclk = ~rclk;   // Read Clock: ~62.5MHz (Period 16ns)

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_dual_clock_fifo);
    end

    initial begin
        // Initialize
        wclk=0; wrst_n=0; wen=0; wdata=0;
        rclk=0; rrst_n=0; ren=0;

        // Reset
        #20 wrst_n=1; rrst_n=1;

        // 1. Write Data (Fast Clock)
        // Fill the FIFO (Depth 8)
        #10 wen=1; wdata=8'hA1;
        #10 wdata=8'hB2;
        #10 wdata=8'hC3;
        #10 wdata=8'hD4;
        #10 wdata=8'hE5;
        #10 wdata=8'hF6;
        #10 wdata=8'h07;
        #10 wdata=8'h18; 
        #10 wen=0; // FIFO should be full now

        // Wait a bit to let synchronization happen
        #50;

        // 2. Read Data (Slow Clock)
        // Note: We sync to rclk edges
        @(posedge rclk); ren=1;
        @(posedge rclk); // Read A1
        @(posedge rclk); // Read B2
        @(posedge rclk); // Read C3
        @(posedge rclk); ren=0;
        
        #50;
        $finish;
    end
    
endmodule
