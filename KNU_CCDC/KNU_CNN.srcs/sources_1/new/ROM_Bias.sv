`timescale 1ns / 1ps

module ROM_Bias #(
    parameter DATA_WIDTH = 8, 
    parameter WEIGHT_FILE_bias_1 = "", 
    parameter WEIGHT_FILE_bias_2 = ""
) (
    output wire signed [DATA_WIDTH-1:0] oDAT_bias_1 [0:2],
    output wire signed [DATA_WIDTH-1:0] oDAT_bias_2 [0:2]
);

    // Declare weight arrays for each output
    reg signed [DATA_WIDTH-1:0] rBias_conv1 [0:2];
    reg signed [DATA_WIDTH-1:0] rBias_conv2 [0:2];

    // Initial block to load weight files
    initial begin
        if (WEIGHT_FILE_bias_1 != "") begin
            $readmemh(WEIGHT_FILE_bias_1, rBias_conv1);
        end else begin
            $error("Weight file conv1_1 not specified.");
        end

        if (WEIGHT_FILE_bias_1 != "") begin
            $readmemh(WEIGHT_FILE_bias_2, rBias_conv2);
        end else begin
            $error("Weight file conv1_2 not specified.");
        end
    end

    // Assign each weight array to its respective output
    assign oDAT_bias_1 = rBias_conv1;
    assign oDAT_bias_2 = rBias_conv2;

endmodule
