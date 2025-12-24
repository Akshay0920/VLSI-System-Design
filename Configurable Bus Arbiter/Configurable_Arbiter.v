// Configurable Arbiter (Fixed vs Round-Robin)
module mode_mux (
    input clk,                  // System Clock
    input rst_n,                // Active low reset
    input [3:0] req,            // 4 Request inputs
    input mode,                 // 0 = Fixed Priority, 1 = Round Robin
    output reg [3:0] gnt        // One-hot Grant output
    );

    // Register to store the last winner for Round-Robin mode
    reg [1:0] last_winner;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gnt <= 4'b0000;
            last_winner <= 2'b11; // Init for Round Robin (so 0 is next)
        end 
        else begin
            gnt <= 4'b0000; // Default: No grant

            if (mode == 0) begin
              
                // MODE 0: FIXED PRIORITY (0 > 1 > 2 > 3)
                if (req[0])      gnt[0] <= 1;
                else if (req[1]) gnt[1] <= 1;
                else if (req[2]) gnt[2] <= 1;
                else if (req[3]) gnt[3] <= 1;
            end 
            else begin
                
                // MODE 1: ROUND ROBIN PRIORITY
                case (last_winner)
                    2'b00: begin // Last was 0, check 1->2->3->0
                        if (req[1]) begin gnt[1] <= 1; last_winner <= 1; end
                        else if (req[2]) begin gnt[2] <= 1; last_winner <= 2; end
                        else if (req[3]) begin gnt[3] <= 1; last_winner <= 3; end
                        else if (req[0]) begin gnt[0] <= 1; last_winner <= 0; end
                    end
                    2'b01: begin // Last was 1, check 2->3->0->1
                        if (req[2]) begin gnt[2] <= 1; last_winner <= 2; end
                        else if (req[3]) begin gnt[3] <= 1; last_winner <= 3; end
                        else if (req[0]) begin gnt[0] <= 1; last_winner <= 0; end
                        else if (req[1]) begin gnt[1] <= 1; last_winner <= 1; end
                    end
                    2'b10: begin // Last was 2, check 3->0->1->2
                        if (req[3]) begin gnt[3] <= 1; last_winner <= 3; end
                        else if (req[0]) begin gnt[0] <= 1; last_winner <= 0; end
                        else if (req[1]) begin gnt[1] <= 1; last_winner <= 1; end
                        else if (req[2]) begin gnt[2] <= 1; last_winner <= 2; end
                    end
                    2'b11: begin // Last was 3, check 0->1->2->3
                        if (req[0]) begin gnt[0] <= 1; last_winner <= 0; end
                        else if (req[1]) begin gnt[1] <= 1; last_winner <= 1; end
                        else if (req[2]) begin gnt[2] <= 1; last_winner <= 2; end
                        else if (req[3]) begin gnt[3] <= 1; last_winner <= 3; end
                    end
                endcase
            end
        end
    end

endmodule
