`timescale 1ns / 1ps

module RF_ALU_FSM_tb();
    reg clk, reset_btn;
    reg [15:0] switches;
    wire [15:0] leds;
    wire [6:0] seg;
    wire [3:0] an;

    // Instantiate the Top Level [cite: 76]
    top_lab7 uut (
        .clk(clk), .reset_btn(reset_btn), .switches(switches),
        .leds(leds), .seg(seg), .an(an)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset_btn = 1; switches = 0;
        #20 reset_btn = 0; // Release reset to start FSM [cite: 46]

        // Wait for FSM to cycle through states [cite: 51]
        // Since clock_divider limit is small (10), it will move quickly
        #500; 
        
        $display("Final LED Result (AND operation): %h", leds);
        $finish;
    end
endmodule