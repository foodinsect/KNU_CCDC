module fc_weight_ROM #(
    parameter WEIGHT_FILE = "D:/Git_repo/KNU_CCDC/KNU_CNN.srcs/CNN_MNIST/fc_weight_transposed.txt"
)(
    input wire clk_i,
    input wire weight_rom_en,
    input wire [5:0] weight_idx,

    output reg [8*10-1:0] oDAT
);

    reg [8*10-1:0] weight [0:47]; // packed 타입으로 선언된 1차원 배열

    initial begin
        if (WEIGHT_FILE != "") begin
            $readmemh(WEIGHT_FILE, weight);
        end 
        else begin
            $error("WEIGHT_FILE not specified.");
        end
    end

    always @(posedge clk_i) begin
        if (weight_rom_en) begin
            oDAT[79:0] <= weight[weight_idx];
        end
    end


endmodule
