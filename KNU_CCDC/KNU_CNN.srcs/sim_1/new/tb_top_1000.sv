`timescale 1ns / 1ps

module tb_top_1000();

    reg clk;
    reg rstn;
    reg start_i;

    reg [7:0] pixels [0:783999];                     // 28x28 image data
    reg [3:0] true_labels [0:999];                   // True labels for the input images

    reg signed [7:0] conv1_weight_1 [0:24];
    reg signed [7:0] conv1_weight_2 [0:24];
    reg signed [7:0] conv1_weight_3 [0:24];
    reg signed [7:0] bias_1 [0:2];

    reg signed [7:0] conv2_weight_11 [0:24];
    reg signed [7:0] conv2_weight_12 [0:24];
    reg signed [7:0] conv2_weight_13 [0:24];
    reg signed [7:0] conv2_weight_21 [0:24];
    reg signed [7:0] conv2_weight_22 [0:24];
    reg signed [7:0] conv2_weight_23 [0:24];
    reg signed [7:0] conv2_weight_31 [0:24];
    reg signed [7:0] conv2_weight_32 [0:24];
    reg signed [7:0] conv2_weight_33 [0:24];
    reg signed [7:0] bias_2 [0:2];

    // Image roms
    wire [5:0] cycle;
    wire [9:0] image_idx;
    wire [1:0] weight_sel;
    wire [1:0] bias_sel;
    wire image_rom_en;
    reg [11:0] image_6rows [0:5];

    //pe bias in
    reg  signed[7:0]  zero_bias [0:2];
    wire signed [7:0] bias_in [0:2];
    wire signed [7:0] conv1_bias[0:2];
    wire signed [7:0] conv2_bias[0:2];

    // pe weight in
    wire signed [7:0] conv_weight_in1 [0:24];
    wire signed [7:0] conv_weight_in2 [0:24];
    wire signed [7:0] conv_weight_in3 [0:24];

    wire done;
    wire ready;
    wire [3:0] result;
    integer img_offset; // image index offset counter for next image
    reg [3:0] done_z;

    integer accuracy;   // To store the accuracy count
    integer img_count;  // To keep track of processed images

    always @(posedge clk) begin
        done_z[0] <= done;
        done_z[1] <= done_z[0];
        done_z[2] <= done_z[1];
        done_z[3] <= done_z[2];

    end
    
    // Instantiate PE Array module
    top TOP_inst (
        .clk_i(clk),
        .rstn_i(rstn),
        .start_i(start_i|done_z[3]),
        
        .image_6rows(image_6rows),
        
        .conv1_weight_1 (conv_weight_in1),
        .conv1_weight_2 (conv_weight_in2),
        .conv1_weight_3 (conv_weight_in3),
        .bias_1(bias_in),

        /*.conv2_weight_11 (conv2_weight_11),
        .conv2_weight_12 (conv2_weight_12),
        .conv2_weight_13 (conv2_weight_13),
        .conv2_weight_21 (conv2_weight_21),
        .conv2_weight_22 (conv2_weight_22),
        .conv2_weight_23 (conv2_weight_23),
        .conv2_weight_31 (conv2_weight_31),
        .conv2_weight_32 (conv2_weight_32),
        .conv2_weight_33 (conv2_weight_33),
        .bias_2(bias_2),
        */

        .cycle(cycle),
        .image_idx(image_idx),
        .image_rom_en(image_rom_en),
        .weight_sel(weight_sel),
        .bias_sel(bias_sel),
        .ready(ready),
        .result(result),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Initial setup
    initial begin
        $readmemh("E:/cnn_verilog/data/input_1000.txt", pixels);
        $readmemh("E:/cnn_verilog/data/labels_1000.txt", true_labels);  // Load true labels
        clk <= 1'b0;;
        rstn <= 1'b1;
        start_i <= 1'b0;
        img_offset <= 0;  // image index offset initialized to 0
        accuracy <= 0;    // Initialize accuracy
        img_count <= 0;   // Initialize image count
        #10 rstn <= 1'b0;
        #10 rstn <= 1'b1;
        #10 start_i <= 1'b1;
        #10 start_i <= 1'b0;
    end

    
    initial begin
        // Read weights and biases for conv1
        $readmemh("E:/cnn_verilog/data/conv1_weight_1.txt", conv1_weight_1);
        $readmemh("E:/cnn_verilog/data/conv1_weight_2.txt", conv1_weight_2);
        $readmemh("E:/cnn_verilog/data/conv1_weight_3.txt", conv1_weight_3);
        $readmemh("E:/cnn_verilog/data/conv1_bias.txt", bias_1);

        // Read weights and biases for conv2
        $readmemh("E:/cnn_verilog/data/conv2_weight_11.txt", conv2_weight_11);
        $readmemh("E:/cnn_verilog/data/conv2_weight_12.txt", conv2_weight_12);
        $readmemh("E:/cnn_verilog/data/conv2_weight_13.txt", conv2_weight_13);
        $readmemh("E:/cnn_verilog/data/conv2_weight_21.txt", conv2_weight_21);
        $readmemh("E:/cnn_verilog/data/conv2_weight_22.txt", conv2_weight_22);
        $readmemh("E:/cnn_verilog/data/conv2_weight_23.txt", conv2_weight_23);
        $readmemh("E:/cnn_verilog/data/conv2_weight_31.txt", conv2_weight_31);
        $readmemh("E:/cnn_verilog/data/conv2_weight_32.txt", conv2_weight_32);
        $readmemh("E:/cnn_verilog/data/conv2_weight_33.txt", conv2_weight_33);
        $readmemh("E:/cnn_verilog/data/conv2_bias.txt", bias_2);
    end

    // image rom with image index offset
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            img_offset <= 0;  // Reset the image index offset
        end else if (done) begin
            img_count <= img_count + 1;  // Move to the next image
            img_offset <= img_offset + 784;  // Move to the next image
            // Compare predicted result with true label
            if (result == true_labels[img_count]) begin
                accuracy <= accuracy + 1;
                $display("Image %0d: Success, Prediction = %0d, True Label = %0d", img_count, result, true_labels[img_count]);
            end else begin
                $display("Image %0d: Fail, Prediction = %0d, True Label = %0d", img_count, result, true_labels[img_count]);
            end
        end
        if (img_count == 10'd1000) begin
            $display("\n\n------ Final Accuracy for 1000 Input Image ------");
            $display("Accuracy : %3d%%", accuracy/10);
            $stop;
        end
    end

    integer i;
    // image 6 rows input handling
    always @(posedge clk or negedge rstn) begin
        if (!rstn || done) begin
            for (i = 0; i < 6; i = i + 1) begin
                image_6rows[i] <= 12'hxxx;  
            end
        end else begin
            if (image_rom_en) begin
                for (i = 0; i < 6; i = i + 1) begin
                    // Apply img_offset to handle image index shift for next images
                    image_6rows[i] <= {4'h0, pixels[(i + cycle * 2) * 28 + image_idx + img_offset]};  
                end
            end else begin
                for (i = 0; i < 6; i = i + 1) begin
                    image_6rows[i] <= 12'hxxx;  
                end
            end
        end
    end

// weight MUX 

assign conv_weight_in1 = (weight_sel == 2'b00 ? conv1_weight_1 :
                          weight_sel == 2'b01 ? conv2_weight_11:
                          weight_sel == 2'b10 ? conv2_weight_12:
                          conv2_weight_13);

assign conv_weight_in2 = (weight_sel == 2'b00 ? conv1_weight_2 :
                          weight_sel == 2'b01 ? conv2_weight_21:
                          weight_sel == 2'b10 ? conv2_weight_22:
                          conv2_weight_23);

assign conv_weight_in3 = (weight_sel == 2'b00 ? conv1_weight_3 :
                          weight_sel == 2'b01 ? conv2_weight_31:
                          weight_sel == 2'b10 ? conv2_weight_32:
                          conv2_weight_33);

// bias mux
assign bias_in = (bias_sel == 2'b00 ? conv1_bias :
                  bias_sel == 2'b01 ? conv2_bias :
                  zero_bias);


initial begin
    zero_bias[0] = 8'd0;
    zero_bias[1] = 8'd0;
    zero_bias[2] = 8'd0;
end


    ROM_Weight #(
        .DATA_WIDTH(8)
    ) weight_rom(
        .oDAT_conv1_1(conv1_weight_1),
        .oDAT_conv1_2(conv1_weight_2),
        .oDAT_conv1_3(conv1_weight_3),
        .oDAT_conv2_11(conv2_weight_11),
        .oDAT_conv2_12(conv2_weight_12),
        .oDAT_conv2_13(conv2_weight_13),
        .oDAT_conv2_21(conv2_weight_21),
        .oDAT_conv2_22(conv2_weight_22),
        .oDAT_conv2_23(conv2_weight_23),
        .oDAT_conv2_31(conv2_weight_31),
        .oDAT_conv2_32(conv2_weight_32),
        .oDAT_conv2_33(conv2_weight_33)
    );
    
    ROM_Bias bias_rom(
        .oDAT_bias_1(conv1_bias),
        .oDAT_bias_2(conv2_bias)
    );
    
    // Finish simulation when done is high
    // always @(posedge clk) begin
    //     if (done) begin
    //         $finish;  // End the simulation
    //     end
    // end

/*
////////////////////////////////////////////////////////////////////
// ROMs inst
    ROM_Image image_rom(
        .clk_i(clk),
        .rstn_i(rstn),
        .image_rom_en(image_rom_en),
        .image_idx(image_idx),
        .cycle(cycle),
        .done(done),
        .oDAT(image_6rows)
    );
    
    ROM_Weight #(
        .DATA_WIDTH(8)
    ) weight_rom(
        .oDAT_conv1_1(conv1_weight_1),
        .oDAT_conv1_2(conv1_weight_2),
        .oDAT_conv1_3(conv1_weight_3),
        .oDAT_conv2_11(conv2_weight_11),
        .oDAT_conv2_12(conv2_weight_12),
        .oDAT_conv2_13(conv2_weight_13),
        .oDAT_conv2_21(conv2_weight_21),
        .oDAT_conv2_22(conv2_weight_22),
        .oDAT_conv2_23(conv2_weight_23),
        .oDAT_conv2_31(conv2_weight_31),
        .oDAT_conv2_32(conv2_weight_32),
        .oDAT_conv2_33(conv2_weight_33)
    );
    
    ROM_Bias bias_rom(
        .oDAT_bias_1(conv1_bias),
        .oDAT_bias_2(conv2_bias)
    );
*/


endmodule