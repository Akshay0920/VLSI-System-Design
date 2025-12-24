## DESIGN REPORT: DUALCLOCKFIFO

### PROBLEM STATEMENT
The objective is to design an Asynchronous FIFO (First-In-First-Out) buffer. Unlike standard FIFOs where reading and writing happen on the same clock, this design must handle two separate, independent clocks (write clock and read clock). This is known as "Clock Domain Crossing" (CDC).

### USE CASE
This is a critical component in almost all modern chips. For example, a USB controller (running at 480 MHz) needs to send data to the main CPU (running at 3 GHz). Because the clocks are different speeds and phases, you cannot just pass data directly. A Dual-Clock FIFO acts as a safe bridge between them.

### DESIGN REQUIREMENTS
* **Write Interface:** `wclk` (fast), `wrst_n`, `wen`, `wdata`, `full`.
* **Read Interface:** `rclk` (slow), `rrst_n`, `ren`, `rdata`, `empty`.
* **Synchronization:** Must use Gray Code pointers to safely pass counters between the two clock domains without causing glitches.
* **Depth:** 8 slots.

### DESIGN CONSTRAINTS
The design must be synthesizable Verilog. It must prevent "metastability" (errors caused by confusing signal timing) by using 2-stage synchronizers (double flip-flops) for the pointers.

### DESIGN METHODOLOGY & IMPLEMENTATION DETAILS
1. **Memory:** A standard register array stores the data.
2. **Gray Pointers:** I maintained binary pointers for addressing memory, but converted them to Gray Code before sending them to the other clock domain. Gray code is safer because only one bit changes at a time, minimizing synchronization errors.
3. **Synchronizers:** I used two flip-flops (`sync1`, `sync2`) to carefully move the write pointer into the read domain (to check for empty) and the read pointer into the write domain (to check for full).

### FUNCTIONAL SIMULATION METHODOLOGY & TEST CASES
The testbench used two clocks with different periods (10ns vs 16ns) to simulate a real-world mismatch.
1. **Write Burst:** I filled the FIFO using the fast clock. Verified the `full` flag went high.
2. **Synchronization Delay:** I observed that the `empty` flag didn't drop *instantly* on the read side; it took 2-3 clock cycles, which is the expected behavior of the synchronizers.
3. **Read Burst:** I read data using the slow clock and verified the data integrity (A1, B2, C3...) matches the input.

### RESULTS & ANALYSIS
The simulation successfully transferred data between the two domains. The logic correctly handled the full/empty flags despite the asynchronous clocks. The Gray code conversion prevented any glitches during the pointer handover.

### CHALLENGES & CONCLUSIONS
The main challenge is that "Full" and "Empty" flags are slightly delayed because of the synchronizers. This is normal for Async FIFOs (pessimistic reporting), meaning the FIFO might say it's full for a few extra cycles even if a space just opened up. This ensures safety.
