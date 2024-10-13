`timescale 1ns / 1ps

module tb_top();

    reg clk;
    reg rstn;
    reg start_i;

    reg [7:0] pixels [0:783];                  // 28x28 image data

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
    wire image_rom_en;
    reg done;
    reg [11:0] image_6rows [0:5];



    // Instantiate PE Array module
    top TOP_inst (
        .clk_i(clk),
        .rstn_i(rstn),
        .start_i(start_i),
        
        .image_6rows(image_6rows),
        
        .conv1_weight_1 (conv1_weight_1),
        .conv1_weight_2 (conv1_weight_2),
        .conv1_weight_3 (conv1_weight_3),
        .bias_1(bias_1),

        .conv2_weight_11 (conv2_weight_11),
        .conv2_weight_12 (conv2_weight_12),
        .conv2_weight_13 (conv2_weight_13),
        .conv2_weight_21 (conv2_weight_21),
        .conv2_weight_22 (conv2_weight_22),
        .conv2_weight_23 (conv2_weight_23),
        .conv2_weight_31 (conv2_weight_31),
        .conv2_weight_32 (conv2_weight_32),
        .conv2_weight_33 (conv2_weight_33),
        .bias_2(bias_2),

        .cycle(cycle),
        .image_idx(image_idx),
        .image_rom_en(image_rom_en),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Read image text file
    initial begin
        $readmemh("E:/Verilog/CNN_MNIST/0_01.txt", pixels);
        clk <= 1'b0;;
        rstn <= 1'b1;
        start_i = 1'b0;
        #10 rstn <= 1'b0;
        #10 rstn <= 1'b1;
        #10 start_i = 1'b1;
        #10 start_i = 1'b0;
    end

    
    initial begin
        // Read weights and biases for conv1
        $readmemh("E:/Verilog/CNN_MNIST/conv1_weight_1.txt", conv1_weight_1);
        $readmemh("E:/Verilog/CNN_MNIST/conv1_weight_2.txt", conv1_weight_2);
        $readmemh("E:/Verilog/CNN_MNIST/conv1_weight_3.txt", conv1_weight_3);
        $readmemh("E:/Verilog/CNN_MNIST/conv1_bias.txt", bias_1);

        // Read weights and biases for conv2
        $readmemh("E:/Verilog/CNN_MNIST/conv2_weight_11.txt", conv2_weight_11);
        $readmemh("E:/Verilog/CNN_MNIST/conv2_weight_12.txt", conv2_weight_12);
        $readmemh("E:/Verilog/CNN_MNIST/conv2_weight_13.txt", conv2_weight_13);
        $readmemh("E:/Verilog/CNN_MNIST/conv2_weight_21.txt", conv2_weight_21);
        $readmemh("E:/Verilog/CNN_MNIST/conv2_weight_22.txt", conv2_weight_22);
        $readmemh("E:/Verilog/CNN_MNIST/conv2_weight_23.txt", conv2_weight_23);
        $readmemh("E:/Verilog/CNN_MNIST/conv2_weight_31.txt", conv2_weight_31);
        $readmemh("E:/Verilog/CNN_MNIST/conv2_weight_32.txt", conv2_weight_32);
        $readmemh("E:/Verilog/CNN_MNIST/conv2_weight_33.txt", conv2_weight_33);
        $readmemh("E:/Verilog/CNN_MNIST/conv2_bias.txt", bias_2);
    end

    
    // image rom
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            done <= 1'b0;
        end
        else begin
            integer i;
            // Valid signal 
            if (image_rom_en) begin
                for (i = 0; i < 6; i = i + 1) begin
                    image_6rows[i] <= {4'h0, pixels[(i + cycle * 2) * 28 + image_idx]};  
                end

                for (i = 6; i < 12; i = i + 1) begin
                    image_6rows[i] <= {4'h0, pixels[(i + (cycle * 2) - 6) * 28 + image_idx]};  
                end
            end

            if (cycle == 12) begin
                done <= 1'b1;
            end
        end
    end

    // Finish simulation when done is high
    always @(posedge clk) begin
        if (done) begin
            $finish;  // End the simulation
        end
    end

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

