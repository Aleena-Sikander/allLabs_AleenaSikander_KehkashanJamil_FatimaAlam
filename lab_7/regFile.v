module registerFile(
input [31:0] WriteData,
input [4:0] RS1,
input [4:0] RS2,
input [4:0] RD,
input RegWrite,
input Clk,
input Reset,
output [31:0] ReadData1,
output [31:0] ReadData2
);

reg [31:0] Registerx [31:0];
integer index;

// synchronous write and reset
always @(posedge Clk)
begin
    if (Reset)
    begin
        Registerx[0] <= 32'b0;
        for (index = 1; index < 32; index = index + 1)
        begin
            Registerx[index] <= 32'b0;
        end
    end
    else if (RegWrite)
    begin
        // prevent writing to register 0
        if (RD != 5'd0)
            Registerx[RD] <= WriteData;
    end
end

// asynchronous reads with x0 hardwired to zero
assign ReadData1 = (RS1 == 5'd0) ? 32'b0 : Registerx[RS1];
assign ReadData2 = (RS2 == 5'd0) ? 32'b0 : Registerx[RS2];

endmodule