`timescale 1ns / 1ps

module buffer1(
    input                           clk_i,
    input                           rstn_i,
    input                           clear_i,
    input       [11:0]              din_i,
    input                           valid_i,
    input                           buffer1_we,
    input       [1:0]               rd_mod,
    output reg signed [11:0]        dout_o [0:5]
);

integer  i;
reg  signed [11:0] mem [0:143];
reg [7:0]  addr_i;
reg [4:0]  cnt_sub;

always @(posedge clk_i) begin
    if(!rstn_i)begin
        addr_i <= 7'd0;
        cnt_sub <= 5'd0;
    end
    else begin
        if(valid_i&(~buffer1_we))begin
            if (cnt_sub == 5'd12) begin
                cnt_sub <= 12'd0;
                addr_i <= addr_i; 
            end
            else begin
                cnt_sub <= cnt_sub + 12'd1;
                addr_i <= addr_i + 1;
            end
        end
        else if(valid_i & (buffer1_we)) begin
            addr_i <= addr_i + 1'b1;
        end
    end
end
    
always @(posedge clk_i) begin
    if(valid_i & buffer1_we)begin
        mem[addr_i] <= din_i;
    end
    if (clear_i) begin
        for (i=0; i < 144; i=i+1) begin
            mem[i] <= 12'hxxx;
        end
    end
end


always @(*) begin
    dout_o[0] = mem[addr_i + rd_mod*8'd12];
    dout_o[1] = mem[addr_i + 8'd12 + rd_mod*8'd12];
    dout_o[2] = mem[addr_i + 8'd24 + rd_mod*8'd12];
    dout_o[3] = mem[addr_i + 8'd36 + rd_mod*8'd12];
    dout_o[4] = mem[addr_i + 8'd48+ rd_mod*8'd12];
    dout_o[5] = mem[addr_i + 8'd60+ rd_mod*8'd12];
end

endmodule