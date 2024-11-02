module ROM_Image #(
	parameter IMAGE_FILE = ""
)(
	input wire clk_i,
	input wire rstn_i,
	input wire image_rom_en,
	input wire [9:0] image_idx,
	input wire [5:0] cycle,
	output reg done,
	output reg [71:0] oDAT
);
	
	reg [7:0] pixels [0:783];
	integer i;

	initial 
	if (IMAGE_FILE != "")
		$readmemh(IMAGE_FILE, pixels);
	else
		$display("Error [%0t] ROM_Image.sv:23:13 - ROM_Image.<unnamed_block>.<unnamed_block>\n msg: ", $time, "IMAGE_FILE not specified.");

	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i) begin
			done <= 1'b0;
		end
		else begin
			if (image_rom_en) begin
				for (i = 0; i < 6; i = i + 1)
					oDAT[(5 - i) * 12+:12] <= {4'h0, pixels[((i + (cycle * 2)) * 28) + image_idx]};
				for (i = 6; i < 12; i = i + 1)
					oDAT[(5 - i) * 12+:12] <= {4'h0, pixels[(((i + (cycle * 2)) - 6) * 28) + image_idx]};
			end
			if (cycle == 12)
				done <= 1'b1;
		end
endmodule