module fc_bias_ROM #(
	parameter BIAS_FILE = ""
)(
	input wire clk_i,
	input wire bias_rom_en,
	input wire [3:0] bias_idx,
	output reg [79:0] oDAT
);
	
	reg [7:0] bias [0:9];
	integer i;
	initial 
	if (BIAS_FILE != "")
		$readmemh(BIAS_FILE, bias);
	else
		$display("Error [%0t] fc_bias_ROM.sv \n msg: ", $time, "IMAGE_FILE not specified.");
	
	always @(posedge clk_i) begin
		if (bias_rom_en)
			for (i = 0; i < 10; i = i + 1)
				oDAT[(9 - i) * 8+:8] <= bias[i];
	end
endmodule