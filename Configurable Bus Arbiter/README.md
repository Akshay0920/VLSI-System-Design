## DESIGN REPORT: Configurable Bus Arbiter

### PROBLEM STATEMENT
The objective is to design a configurable "Arbiter" that controls access to a shared resource (like a data bus). The unique feature is that it must support two different modes of operation:
1. **Fixed Priority:** User 0 always wins if they are requesting.
2. **Round Robin:** The priority rotates fairly among all users.

### USE CASE
Real-world systems often need to switch strategies dynamically. For example, a network router might use "Round Robin" for normal web traffic to be fair to everyone, but switch to "Fixed Priority" (giving priority to Voice-over-IP) when a phone call is detected to ensure call quality.

### DESIGN REQUIREMENTS
* **Inputs:** Clock (`clk`), Reset (`rst_n`), Requests (`req[3:0]`), Mode (`mode`).
* **Outputs:** Grant (`gnt[3:0]`).
* **Mode 0 (Fixed):** Priority order is strictly 0 > 1 > 2 > 3.
* **Mode 1 (Round-Robin):** Priority rotates based on the last winner (Winner becomes lowest priority).

### DESIGN CONSTRAINTS
The design must use multiplexing logic to select between the two algorithms based on the `mode` input. It must be written in Verilog and handle simultaneous requests cleanly (One-Hot output).

### DESIGN METHODOLOGY & IMPLEMENTATION DETAILS
I implemented this using an `if-else` block inside the main sequential loop.
1. **Mode Switching:** The outer `if (mode == 0)` checks the configuration.
2. **Fixed Logic:** I used a standard `if-else if` ladder checking `req[0]` first, then `req[1]`, etc.
3. **Round Robin Logic:** I reused the logic from Challenge 4, using a `last_winner` register and a `case` statement to determine the next priority.
This structure allows the hardware to switch behaviors instantly on the next clock cycle.

### FUNCTIONAL SIMULATION METHODOLOGY & TEST CASES
1. **Fixed Priority Test:** I set `mode=0` and asserted all requests (`1111`). I verified that `gnt[0]` stayed high continuously, ignoring the others. I then removed request 0, and `gnt[1]` immediately took over.
2. **Round Robin Test:** I switched to `mode=1` with all requests still active. I verified the waveform showed the grant moving `1 -> 2 -> 3 -> 0` in a cycle.

### RESULTS & ANALYSIS
The design successfully integrated both behaviors. The mode input acted as a selector, seamlessly changing how the arbiter made decisions. No glitches were observed during mode switching.

### CHALLENGES & CONCLUSIONS
The main challenge was combining two different logic styles in one module. I had to ensure that the `last_winner` register (used for Round Robin) didn't interfere when we were in Fixed Priority mode. I solved this by only updating `last_winner` when in Mode 1.
