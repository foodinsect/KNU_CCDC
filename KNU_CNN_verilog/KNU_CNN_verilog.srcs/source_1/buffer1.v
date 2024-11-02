module buffer1 (
	input clk_i,
	input rstn_i,
	input clear_i,
	input [11:0] din_i,
	input valid_i,
	input buffer1_we,
	input [1:0] rd_mod,
	output reg signed [71:0] dout_o
);
	
	integer i;
	reg signed [11:0] mem [0:143];
	reg [7:0] addr_i;
	reg [4:0] cnt_sub;

	always @(posedge clk_i)
		if (!rstn_i) begin
			addr_i <= 7'd0;
			cnt_sub <= 5'd0;
			if (clear_i)
				for (i = 0; i < 144; i = i + 1)
					mem[i] <= 12'hxxx;
		end

		else if (valid_i & ~buffer1_we) begin
			if (cnt_sub == 5'd12) begin
				cnt_sub <= 12'd0;
				addr_i <= addr_i;
			end
			else begin
				cnt_sub <= cnt_sub + 12'd1;
				addr_i <= addr_i + 1;
			end
		end

		else if (valid_i & buffer1_we)
			addr_i <= addr_i + 1'b1;

		always @(posedge clk_i)
			if (valid_i & buffer1_we)
				mem[addr_i] <= din_i;
				
		always @(*) begin
			dout_o[60+:12] = mem[addr_i + (rd_mod * 8'd12)];
			dout_o[48+:12] = mem[(addr_i + 8'd12) + (rd_mod * 8'd12)];
			dout_o[36+:12] = mem[(addr_i + 8'd24) + (rd_mod * 8'd12)];
			dout_o[24+:12] = mem[(addr_i + 8'd36) + (rd_mod * 8'd12)];
			dout_o[12+:12] = mem[(addr_i + 8'd48) + (rd_mod * 8'd12)];
			dout_o[0+:12] = mem[(addr_i + 8'd60) + (rd_mod * 8'd12)];
		end
endmodule