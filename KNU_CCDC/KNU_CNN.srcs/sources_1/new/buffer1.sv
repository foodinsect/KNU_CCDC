`timescale 1ns / 1ps

module buffer1(
    input                           clk_i,
    input                           rstn_i,
    input       [11:0]              din_i,
    input                           valid_i,
    input                           buffer1_we,
    output reg signed [11:0]        dout_o [0:5]
);

integer  i;
reg  signed [11:0] mem [0:143];
reg [7:0]  addr_i;

always @(posedge clk_i) begin
    if(!rstn_i)begin
        addr_i <= 7'd0;
    end
    else begin
        if(valid_i)begin
            addr_i <= addr_i + 1'b1;
        end
    end
end
    
always @(posedge clk_i) begin
        if(valid_i & buffer1_we)begin
            mem[addr_i] <= din_i;
        end
end

always @(*) begin
    dout_o[0] = mem[addr_i];
    dout_o[1] = mem[addr_i + 6'd12];
    dout_o[2] = mem[addr_i + 6'd24];
    dout_o[3] = mem[addr_i + 6'd36];
    dout_o[4] = mem[addr_i + 6'd48];
    dout_o[5] = mem[addr_i + 6'd60];
end

endmodule