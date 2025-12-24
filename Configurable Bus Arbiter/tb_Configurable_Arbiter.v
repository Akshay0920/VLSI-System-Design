// Testbench for ModeMux
module tb_mode_mux;

    reg clk, rst_n;
    reg [3:0] req;
    reg mode;
    wire [3:0] gnt;

    mode_mux uut (
        .clk(clk), .rst_n(rst_n),
        .req(req), .mode(mode),
        .gnt(gnt)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_mode_mux);
    end

    initial begin
        clk = 0; rst_n = 0; req = 0; mode = 0;
        #10 rst_n = 1;
      
        // TEST 1: Fixed Priority Mode (Mode = 0)
        mode = 0;
        
        // Case A: Req 0 and 1 active. 0 should win.
        #10 req = 4'b0011; 
        #10; // Check waveform: Gnt should be 0001 (bit 0)

        // Case B: All active. 0 should still win.
        #10 req = 4'b1111;
        #10; // Check waveform: Gnt should be 0001

        // Case C: 0 drops out. 1 should win.
        #10 req = 4'b1110;
        #10; // Check waveform: Gnt should be 0010 (bit 1)

        // TEST 2: Round Robin Mode (Mode = 1)
        #10 mode = 1; req = 4'b0000; // Clear requests first
        #10;

        // Enable all requests. Should rotate 0->1->2->3
        req = 4'b1111;
        #10; // Cycle 1
        #10; // Cycle 2
        #10; // Cycle 3
        #10; // Cycle 4

        #20 $finish;
    end

    initial begin
        $monitor("Time=%0t | Mode=%b | Req=%b | Gnt=%b", 
                 $time, mode, req, gnt);
    end

endmodule
