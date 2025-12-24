// Testbench for SafeALU
module tb_safe_alu;

    // Inputs
    reg clk;
    reg rst_n;
    reg [7:0] a;
    reg [7:0] b;
    reg [1:0] opcode;

    // Outputs
    wire [7:0] result;
    wire zero;
    wire carry;
    wire overflow;

    // Instantiate UUT
    safe_alu uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .a(a), 
        .b(b), 
        .opcode(opcode), 
        .result(result), 
        .zero(zero), 
        .carry(carry), 
        .overflow(overflow)
    );

    // Clock Generation
    always #5 clk = ~clk;

    // Waveform dump
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_safe_alu);
    end

    initial begin
        // Initialize
        clk = 0; rst_n = 0; a = 0; b = 0; opcode = 0;

        // Reset
        #10 rst_n = 1;

        // 1. Test ADD (10 + 20 = 30)
        #10 opcode = 2'b00; a = 10; b = 20;
        
        // 2. Test ADD with Carry (255 + 1 = 0, Carry=1)
        #10 a = 255; b = 1;

        // 3. Test SUB (50 - 20 = 30)
        #10 opcode = 2'b01; a = 50; b = 20;

        // 4. Test SUB with Zero Result (10 - 10 = 0, Zero=1)
        #10 a = 10; b = 10;

        // 5. Test AND (0x0F & 0x03 = 0x03)
        // 00001111 AND 00000011 = 00000011
        #10 opcode = 2'b10; a = 8'h0F; b = 8'h03;

        // 6. Test OR (0xF0 | 0x0F = 0xFF)
        // 11110000 OR 00001111 = 11111111
        #10 opcode = 2'b11; a = 8'hF0; b = 8'h0F;

        #20 $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t | Op=%b | A=%d B=%d | Res=%d | Z=%b C=%b V=%b", 
                 $time, opcode, a, b, result, zero, carry, overflow);
    end

endmodule
