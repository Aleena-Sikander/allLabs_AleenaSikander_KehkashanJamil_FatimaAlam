`timescale 1ns / 1ps

module MemorySystem_tb();
    // Inputs to the Top Level
    reg clk;
    reg reset_btn;
    reg [15:0] switches;

    // Outputs from the Top Level
    wire [15:0] leds;
    wire [6:0] seg;
    wire [3:0] an;

    // Instantiate the Unit Under Test (UUT)
    top_lab8 uut (
        .clk(clk),
        .reset_btn(reset_btn),
        .switches(switches),
        .leds(leds),
        .seg(seg),
        .an(an)
    );

    // Clock generation: 100MHz (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset_btn = 1;
        switches = 16'hA5A5; // Pattern to verify through the system [cite: 208]

        // Reset Pulse
        #20 reset_btn = 0;
        
        $display("--- Starting Lab 8 Memory System Simulation ---");

        // The FSM moves based on enable_1hz. 
        // In top_lab8, ONE_HZ_LIMIT is set to 10 for fast simulation.
        // We wait for the FSM to cycle through the states.
        
        // Wait for S_READ_SWITCHES and S_WRITE_DATAMEM
        #200; 
        
        // Wait for S_READ_DATAMEM and S_WRITE_LED [cite: 202, 203]
        #200;

        // Final Verification [cite: 204, 207]
        if (leds === switches) begin
            $display("SUCCESS: Switch value %h successfully routed to LEDs via Data Memory", switches);
        end else begin
            $display("FAILURE: LEDs show %h, expected %h", leds, switches);
        end

        #100 $finish;
    end
endmodule