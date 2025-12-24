// SafeALU: 8-bit Arithmetic Logic Unit with Flags
module safe_alu (
    input clk,               // System Clock
    input rst_n,             // Active low reset
    input [7:0] a,           // Input Operand A
    input [7:0] b,           // Input Operand B
    input [1:0] opcode,      // Operation Selector
    output reg [7:0] result, // ALU Result
    output reg zero,         // Zero Flag
    output reg carry,        // Carry Flag (Unsigned)
    output reg overflow      // Overflow Flag (Signed)
    );

    // Opcodes
    parameter OP_ADD = 2'b00;
    parameter OP_SUB = 2'b01;
    parameter OP_AND = 2'b10;
    parameter OP_OR  = 2'b11;

    // Internal temporary variable to handle 9-bit math (for carry)
    reg [8:0] temp_result;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result   <= 0;
            zero     <= 0;
            carry    <= 0;
            overflow <= 0;
        end 
        else begin
            // Default values
            carry <= 0;
            overflow <= 0;

            case (opcode)
                OP_ADD: begin
                    // Perform addition on 9 bits to capture carry
                    temp_result = a + b; 
                    result <= temp_result[7:0];
                    carry <= temp_result[8]; // The 9th bit is the carry
                    
                    // Signed Overflow Logic: Positive + Positive = Negative?
                    if (a[7] == b[7] && result[7] != a[7]) 
                        overflow <= 1;
                end

                OP_SUB: begin
                    result <= a - b;
                    // Borrow logic is the inverse of carry in some architectures, 
                    // but simple subtraction usually doesn't need C flag in basic Verilog.
                    // Overflow: Positive - Negative = Negative?
                    if (a[7] != b[7] && result[7] != a[7])
                        overflow <= 1;
                end

                OP_AND: begin
                    result <= a & b;
                end

                OP_OR: begin
                    result <= a | b;
                end
            endcase

            // Zero flag logic (updates for all operations)
            // Note: We use the value we just calculated
            if ((opcode == OP_ADD && temp_result[7:0] == 0) || 
                (opcode != OP_ADD && (opcode == OP_SUB ? (a - b) : 
                                      opcode == OP_AND ? (a & b) : (a | b)) == 0)) begin
                zero <= 1;
            end else begin
                zero <= 0;
            end
        end
    end

endmodule
