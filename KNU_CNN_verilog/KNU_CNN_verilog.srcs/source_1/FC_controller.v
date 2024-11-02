module FC_controller (
	input wire clk_i,
	input wire rstn_i,
	input wire start_i,
	input wire next_i,
	output reg [1:0] select_o,
	output reg clear_o,
	output reg en_o,
	output reg weight_en,
	output reg [5:0] weight_idx,
	output reg done
);
	
	reg [3:0] current_state;
	reg [3:0] next_state;
	reg weight_idx_en;
	reg weight_idx_clr;

	always @(posedge clk_i)
		if (!rstn_i)
			current_state <= 3'd0;
		else
			current_state <= next_state;

	always @(posedge clk_i)
		if (!rstn_i | weight_idx_clr)
			weight_idx <= 6'd0;
		else if (weight_idx_en)
			weight_idx <= weight_idx + 6'd1;

	always @(*)
		case (current_state)
			4'd0: begin
				weight_idx_clr = 1'b1;
				select_o = 2'd0;
				clear_o = 1'b0;
				en_o = 1'b0;
				weight_en = 1'b0;
				weight_idx_en = 1'b0;
				done = 1'b0;
			end
			4'd1: begin
				weight_idx_clr = 1'b0;
				select_o = 2'd0;
				clear_o = 1'b0;
				en_o = 1'b0;
				weight_en = 1'b1;
				weight_idx_en = 1'b1;
				done = 1'b0;
			end
			4'd2: begin
				weight_idx_clr = 1'b0;
				select_o = 2'd1;
				clear_o = 1'b0;
				en_o = 1'b1;
				weight_en = 1'b1;
				weight_idx_en = 1'b1;
				done = 1'b0;
			end
			4'd3: begin
				weight_idx_clr = 1'b0;
				select_o = 2'd2;
				clear_o = 1'b0;
				en_o = 1'b1;
				weight_en = 1'b1;
				weight_idx_en = 1'b1;
				done = 1'b0;
			end
			4'd4: begin
				weight_idx_clr = 1'b0;
				select_o = 2'd3;
				clear_o = 1'b0;
				en_o = 1'b1;
				weight_en = 1'b1;
				weight_idx_en = 1'b1;
				done = 1'b0;
			end
			4'd5: begin
				weight_idx_clr = 1'b0;
				select_o = 2'd3;
				clear_o = 1'b1;
				en_o = 1'b0;
				weight_en = 1'b0;
				weight_idx_en = 1'b1;
				done = 1'b0;
			end
			4'd6: begin
				weight_idx_clr = 1'b0;
				select_o = 2'd0;
				clear_o = 1'b0;
				en_o = 1'b0;
				weight_en = 1'b0;
				weight_idx_en = 1'b1;
				done = 1'b0;
			end
			4'd7: begin
				weight_idx_clr = 1'b0;
				select_o = 2'd0;
				clear_o = 1'b0;
				en_o = 1'b0;
				weight_en = 1'b0;
				weight_idx_en = 1'b1;
				done = 1'b0;
			end
			4'd8: begin
				weight_idx_clr = 1'b1;
				select_o = 2'd0;
				clear_o = 1'b0;
				en_o = 1'b0;
				weight_en = 1'b0;
				weight_idx_en = 1'b0;
				done = 1'b1;
			end
			default:;
		endcase

	always @(*)
		case (current_state)
			4'd0:
				if (start_i)
					next_state = 4'd1;
				else
					next_state = 4'd0;
			4'd1: next_state = 4'd2;
			4'd2:
				if (weight_idx == 6'd16)
					next_state = 4'd3;
				else
					next_state = 4'd2;
			4'd3:
				if (weight_idx == 6'd32)
					next_state = 4'd4;
				else
					next_state = 4'd3;
			4'd4:
				if (weight_idx == 6'd48)
					next_state = 4'd5;
				else
					next_state = 4'd4;
			4'd5: next_state = 4'd6;
			4'd6: next_state = 4'd7;
			4'd7:
				if (weight_idx == 6'd52)
					next_state = 4'd8;
				else
					next_state = 4'd7;
			4'd8: next_state = 4'd0;
			default:;
		endcase
endmodule