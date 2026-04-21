`timescale 1ns / 1ps

module tb_ProjectFinal;

    // Inputs
    reg clk;
    reg reset_btn;
    reg [15:0] sw;

    // Outputs
    wire [15:0] led;
    wire [3:0] an;
    wire [6:0] seg;

    // Instantiate the Unit Under Test (UUT)
    TopLevelProcessor uut (
        .clk(clk),
        .reset_btn(reset_btn),
        .sw(sw),
        .led(led),
        .an(an),
        .seg(seg)
    );

    // 100MHz Clock Generation
    always #5 clk = ~clk;

    initial begin
        // Setup Waveforms
        $dumpfile("tb_ProjectFinal.vcd");
        $dumpvars(0, tb_ProjectFinal);

        // 1. Initialize System (Switches OFF)
        clk = 0;
        reset_btn = 1;
        sw = 16'h0000; 

        // 2. Release Reset
        #20;
        reset_btn = 0;
        $display("Processor started. Waiting in IDLE loop...");

        // Let the processor run a few cycles to hit the WAIT_RELEASE / IDLE state
        #100;

        // 3. Trigger the Countdown
        // We set the switches to 3. The processor should read this,
        // jump to COUNTDOWN_SUB, and start counting down on the LEDs.
       $display("Flipping switches to 6...");
       sw =  16'h0006;
        
        // 4. Let it run!
        // Because your program has a delay loop (addi x8, x0, 500) between counts,
        // we need to give the simulation enough time to finish the nested loops.
        #2000000;

        $display("Simulation time finished.");
        $finish;
    end

    always @(led) begin
        $display("Time: %0t ns | LEDs changed to: %h", $time, led);
    end

//// TASK B 
//    initial begin
//        // 1. Initialize with Switch 15 ON (Debug Mode)
//        clk = 0;
//        reset_btn = 1;
//        sw = 16'h8000; // 1000_0000_0000_0000 in binary

//        // 2. Release Reset
//        #20;
//        reset_btn = 0;
//        $display("-----------------------------------------------------");
//        $display("Task B Simulation: Verifying LUI, JAL, and JALR");
//        $display("-----------------------------------------------------");

//        // 3. Run for 60 nanoseconds (just enough to see the loop execute once)
//        #60;
//        $finish;
//    end

    // Real-time Control Signal Monitor
    // This peers inside your top module to print the exact flags
    always @(posedge clk) begin
        if (!reset_btn) begin
            $display("Time: %0t ns | PC: %h | MemtoReg: %b | Jump: %b | Jalr: %b", 
                     $time, uut.PC, uut.MemtoReg, uut.Jump, uut.Jalr);
        end
    end

endmodule