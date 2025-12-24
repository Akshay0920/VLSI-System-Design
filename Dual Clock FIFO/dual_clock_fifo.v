// DualClockFIFO: Asynchronous FIFO with Gray Code Pointers
// Depth = 8, Data Width = 8
module dual_clock_fifo (
    input wclk, wrst_n, wen,      // Write domain signals
    input [7:0] wdata,
    input rclk, rrst_n, ren,      // Read domain signals
    output reg [7:0] rdata,
    output reg full, empty        // Status flags
    );

    parameter ADDR_SIZE = 3;      // 3 bits = Depth 8
    
    reg [7:0] mem [0:7];          // Memory array
    
    // Pointers (Binary and Gray)
    reg [ADDR_SIZE:0] w_ptr_bin, w_ptr_gray;
    reg [ADDR_SIZE:0] r_ptr_bin, r_ptr_gray;
    
    // Synchronizers
    reg [ADDR_SIZE:0] w_ptr_gray_sync1, w_ptr_gray_sync2; // Write ptr -> Read clock
    reg [ADDR_SIZE:0] r_ptr_gray_sync1, r_ptr_gray_sync2; // Read ptr -> Write clock

    // 1. WRITE DOMAIN (wclk)
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            w_ptr_bin <= 0;
            w_ptr_gray <= 0;
        end else if (wen && !full) begin
            // Write Data
            mem[w_ptr_bin[ADDR_SIZE-1:0]] <= wdata;
            
            // Increment Binary Pointer
            w_ptr_bin <= w_ptr_bin + 1;
            
            // Convert to Gray Code: (bin >> 1) ^ bin
            w_ptr_gray <= ((w_ptr_bin + 1) >> 1) ^ (w_ptr_bin + 1);
        end
    end

    // Synchronize Read Pointer into Write Domain
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            r_ptr_gray_sync1 <= 0;
            r_ptr_gray_sync2 <= 0;
        end else begin
            r_ptr_gray_sync1 <= r_ptr_gray;
            r_ptr_gray_sync2 <= r_ptr_gray_sync1;
        end
    end

    // Full Flag Logic (Gray Code Comparison)
    // Full if top 2 bits are different, rest same
    always @(*) begin
        full = (w_ptr_gray == {~r_ptr_gray_sync2[ADDR_SIZE:ADDR_SIZE-1], r_ptr_gray_sync2[ADDR_SIZE-2:0]});
    end
  
    // 2. READ DOMAIN (rclk)  
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            r_ptr_bin <= 0;
            r_ptr_gray <= 0;
            rdata <= 0;
        end else if (ren && !empty) begin
            // Read Data
            rdata <= mem[r_ptr_bin[ADDR_SIZE-1:0]];
            
            // Increment Binary Pointer
            r_ptr_bin <= r_ptr_bin + 1;
            
            // Convert to Gray Code
            r_ptr_gray <= ((r_ptr_bin + 1) >> 1) ^ (r_ptr_bin + 1);
        end
    end

    // Synchronize Write Pointer into Read Domain
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            w_ptr_gray_sync1 <= 0;
            w_ptr_gray_sync2 <= 0;
        end else begin
            w_ptr_gray_sync1 <= w_ptr_gray;
            w_ptr_gray_sync2 <= w_ptr_gray_sync1;
        end
    end

    // Empty Flag Logic
    // Empty if pointers are identical
    always @(*) begin
        empty = (r_ptr_gray == w_ptr_gray_sync2);
    end

endmodule
