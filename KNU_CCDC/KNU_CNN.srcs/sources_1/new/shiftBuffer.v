module shiftBuffer(
    input           clk_i,
    input   [11:0]  data_i,
    input           shift_en,
    output  [11:0]  data_o
    );

reg [11:0] register [0:15];

integer i;

always @(posedge clk_i) begin
    if (shift_en) begin
        register[0] <= data_i;
        for (i = 1; i < 16 ; i = i + 1) begin
            register[i] <= register[i-1];
        end
    end
end

assign data_o = register[15];

endmodule