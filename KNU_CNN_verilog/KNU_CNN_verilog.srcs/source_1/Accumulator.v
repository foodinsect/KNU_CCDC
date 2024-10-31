module Accumulator (
	input wire clk_i,
	input wire rstn_i,
	input wire valid_i,
	input wire rd_en_i,
	input wire signed [7:0] bias_i,
	input wire signed [39:0] conv_in,
	output wire signed [23:0] conv_sum,
	output reg acc_full_o
);
	reg signed [19:0] acc [0:63];
	reg [6:0] wr_ptr;
	reg [6:0] rd_ptr;
	reg [1:0] cycle_count;
	wire signed [11:0] signed_bias;
	integer j;

	assign signed_bias = $signed({{4 {bias_i[7]}}, bias_i[7:0]});
	assign conv_sum[12+:12] = (rd_en_i ? $signed(acc[rd_ptr][19:8]) + $signed(signed_bias) : 12'hxxx);
	assign conv_sum[0+:12] = (rd_en_i ? $signed(acc[rd_ptr + 1][19:8]) + $signed(signed_bias) : 12'hxxx);

	always @(posedge clk_i) begin
		if (!rstn_i) begin
			for (j = 0; j < 64; j = j + 1)
				acc[j] <= 20'h00000;
				wr_ptr <= 6'd0;
				rd_ptr <= 6'd0;
				cycle_count <= 2'd0;
				acc_full_o <= 1'b0;
			end
			else if (valid_i) begin
				acc[wr_ptr] <= acc[wr_ptr] + conv_in[20+:20];
				acc[wr_ptr + 1] <= acc[wr_ptr + 1] + conv_in[0+:20];
				wr_ptr <= (wr_ptr + 2) % 64;
				if (wr_ptr == 7'd62) begin
					if (cycle_count == 2'd2) begin
						acc_full_o <= 1'b1;
						cycle_count <= 2'd0;
					end
				else
					cycle_count <= cycle_count + 1;
				end
			end
		if (rd_en_i)
			rd_ptr <= (rd_ptr + 2) % 64;
	end
endmodule