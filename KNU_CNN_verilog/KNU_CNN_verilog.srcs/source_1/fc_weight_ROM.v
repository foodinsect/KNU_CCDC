module fc_weight_ROM #(
	parameter WEIGHT_FILE = ""
)(
	input wire clk_i,
	input wire weight_rom_en,
	input wire [5:0] weight_idx,
	output reg [79:0] oDAT
);
	
	reg [79:0] weight [0:47];
	initial 
	if (WEIGHT_FILE != "")
		$readmemh(WEIGHT_FILE, weight);

	else
		$display("Error [%0t] fc_weight_ROM.sv ", $time, "WEIGHT_FILE not specified.");
	
	always @(posedge clk_i)
		if (weight_rom_en)
			oDAT[79:0] <= weight[weight_idx];

endmodule