`timescale 1ns / 1ps

module ROM_Weight #(
    parameter DATA_WIDTH = 8, 
    parameter WEIGHT_FILE_conv1_1 = "E:/cnn_verilog/data/conv1_weight_1.txt", 
    parameter WEIGHT_FILE_conv1_2 = "E:/cnn_verilog/data/conv1_weight_2.txt", 
    parameter WEIGHT_FILE_conv1_3 = "E:/cnn_verilog/data/conv1_weight_3.txt",
    parameter WEIGHT_FILE_conv2_11 = "E:/cnn_verilog/data/conv2_weight_11.txt",
    parameter WEIGHT_FILE_conv2_12 = "E:/cnn_verilog/data/conv2_weight_12.txt",
    parameter WEIGHT_FILE_conv2_13 = "E:/cnn_verilog/data/conv2_weight_13.txt",
    parameter WEIGHT_FILE_conv2_21 = "E:/cnn_verilog/data/conv2_weight_21.txt",
    parameter WEIGHT_FILE_conv2_22 = "E:/cnn_verilog/data/conv2_weight_22.txt",
    parameter WEIGHT_FILE_conv2_23 = "E:/cnn_verilog/data/conv2_weight_23.txt",
    parameter WEIGHT_FILE_conv2_31 = "E:/cnn_verilog/data/conv2_weight_31.txt",
    parameter WEIGHT_FILE_conv2_32 = "E:/cnn_verilog/data/conv2_weight_32.txt",
    parameter WEIGHT_FILE_conv2_33 = "E:/cnn_verilog/data/conv2_weight_33.txt"
) (
    output wire signed [DATA_WIDTH-1:0] oDAT_conv1_1 [0:24],
    output wire signed [DATA_WIDTH-1:0] oDAT_conv1_2 [0:24],
    output wire signed [DATA_WIDTH-1:0] oDAT_conv1_3 [0:24],
    output wire signed [DATA_WIDTH-1:0] oDAT_conv2_11 [0:24],
    output wire signed [DATA_WIDTH-1:0] oDAT_conv2_12 [0:24],
    output wire signed [DATA_WIDTH-1:0] oDAT_conv2_13 [0:24],
    output wire signed [DATA_WIDTH-1:0] oDAT_conv2_21 [0:24],
    output wire signed [DATA_WIDTH-1:0] oDAT_conv2_22 [0:24],
    output wire signed [DATA_WIDTH-1:0] oDAT_conv2_23 [0:24],
    output wire signed [DATA_WIDTH-1:0] oDAT_conv2_31 [0:24],
    output wire signed [DATA_WIDTH-1:0] oDAT_conv2_32 [0:24],
    output wire signed [DATA_WIDTH-1:0] oDAT_conv2_33 [0:24]
);

    // Declare weight arrays for each output
    reg signed [DATA_WIDTH-1:0] rWeight_conv1_1 [0:24];
    reg signed [DATA_WIDTH-1:0] rWeight_conv1_2 [0:24];
    reg signed [DATA_WIDTH-1:0] rWeight_conv1_3 [0:24];
    reg signed [DATA_WIDTH-1:0] rWeight_conv2_11 [0:24];
    reg signed [DATA_WIDTH-1:0] rWeight_conv2_12 [0:24];
    reg signed [DATA_WIDTH-1:0] rWeight_conv2_13 [0:24];
    reg signed [DATA_WIDTH-1:0] rWeight_conv2_21 [0:24];
    reg signed [DATA_WIDTH-1:0] rWeight_conv2_22 [0:24];
    reg signed [DATA_WIDTH-1:0] rWeight_conv2_23 [0:24];
    reg signed [DATA_WIDTH-1:0] rWeight_conv2_31 [0:24];
    reg signed [DATA_WIDTH-1:0] rWeight_conv2_32 [0:24];
    reg signed [DATA_WIDTH-1:0] rWeight_conv2_33 [0:24];

    // Initial block to load weight files
    initial begin
        if (WEIGHT_FILE_conv1_1 != "") begin
            $readmemh(WEIGHT_FILE_conv1_1, rWeight_conv1_1);
        end else begin
            $error("Weight file conv1_1 not specified.");
        end

        if (WEIGHT_FILE_conv1_2 != "") begin
            $readmemh(WEIGHT_FILE_conv1_2, rWeight_conv1_2);
        end else begin
            $error("Weight file conv1_2 not specified.");
        end

        if (WEIGHT_FILE_conv1_3 != "") begin
            $readmemh(WEIGHT_FILE_conv1_3, rWeight_conv1_3);
        end else begin
            $error("Weight file conv1_3 not specified.");
        end

        if (WEIGHT_FILE_conv2_11 != "") begin
            $readmemh(WEIGHT_FILE_conv2_11, rWeight_conv2_11);
        end else begin
            $error("Weight file conv2_11 not specified.");
        end

        if (WEIGHT_FILE_conv2_12 != "") begin
            $readmemh(WEIGHT_FILE_conv2_12, rWeight_conv2_12);
        end else begin
            $error("Weight file conv2_12 not specified.");
        end

        if (WEIGHT_FILE_conv2_13 != "") begin
            $readmemh(WEIGHT_FILE_conv2_13, rWeight_conv2_13);
        end else begin
            $error("Weight file conv2_13 not specified.");
        end

        if (WEIGHT_FILE_conv2_21 != "") begin
            $readmemh(WEIGHT_FILE_conv2_21, rWeight_conv2_21);
        end else begin
            $error("Weight file conv2_21 not specified.");
        end

        if (WEIGHT_FILE_conv2_22 != "") begin
            $readmemh(WEIGHT_FILE_conv2_22, rWeight_conv2_22);
        end else begin
            $error("Weight file conv2_22 not specified.");
        end

        if (WEIGHT_FILE_conv2_23 != "") begin
            $readmemh(WEIGHT_FILE_conv2_23, rWeight_conv2_23);
        end else begin
            $error("Weight file conv2_23 not specified.");
        end

        if (WEIGHT_FILE_conv2_31 != "") begin
            $readmemh(WEIGHT_FILE_conv2_31, rWeight_conv2_31);
        end else begin
            $error("Weight file conv2_31 not specified.");
        end

        if (WEIGHT_FILE_conv2_32 != "") begin
            $readmemh(WEIGHT_FILE_conv2_32, rWeight_conv2_32);
        end else begin
            $error("Weight file conv2_32 not specified.");
        end

        if (WEIGHT_FILE_conv2_33 != "") begin
            $readmemh(WEIGHT_FILE_conv2_33, rWeight_conv2_33);
        end else begin
            $error("Weight file conv2_33 not specified.");
        end
    end

    // Assign each weight array to its respective output
    assign oDAT_conv1_1 = rWeight_conv1_1;
    assign oDAT_conv1_2 = rWeight_conv1_2;
    assign oDAT_conv1_3 = rWeight_conv1_3;
    assign oDAT_conv2_11 = rWeight_conv2_11;
    assign oDAT_conv2_12 = rWeight_conv2_12;
    assign oDAT_conv2_13 = rWeight_conv2_13;
    assign oDAT_conv2_21 = rWeight_conv2_21;
    assign oDAT_conv2_22 = rWeight_conv2_22;
    assign oDAT_conv2_23 = rWeight_conv2_23;
    assign oDAT_conv2_31 = rWeight_conv2_31;
    assign oDAT_conv2_32 = rWeight_conv2_32;
    assign oDAT_conv2_33 = rWeight_conv2_33;

endmodule
