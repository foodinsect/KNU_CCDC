`timescale 1ns / 1ps

module tb_top();
    /////////// MUST write VIVADO project location//////////////////////
    parameter VIVADO_PROJECT_LOCATION = "D:/Git_repo/KNU_CCDC/KNU_CCDC";
    ////////////////////////////////////////////////////////////////////
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
    wire [1:0] weight_sel;
    wire [1:0] bias_sel;
    wire image_rom_en;
    reg [11:0] image_6rows [0:5];


    //fc layer weights & control
    wire [79:0] weight_input_packed;
    wire weight_enable;
    wire [5:0]weight_indexing;
    //fc bias
    wire signed [7:0] fc_bias [0:9];

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

    // Instantiate PE Array module
    top TOP_inst (
        .clk_i(clk),
        .rstn_i(rstn),
        .start_i(start_i),
        
        .image_6rows(image_6rows),
        
        .weight_input_packed(weight_input_packed),//
        .fc_bias(fc_bias),//

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

        .weight_enable(weight_enable),
        .weight_indexing(weight_indexing),
        
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

    // Read image text file
    initial begin
        $readmemh({{VIVADO_PROJECT_LOCATION},{"/data/0_03.txt"}}, pixels);  // 3
        clk <= 1'b0;;
        rstn <= 1'b1;
        start_i = 1'b0;
        #10 rstn <= 1'b0;
        #10 rstn <= 1'b1;
        #10 start_i = 1'b1;
        #10 start_i = 1'b0;
        wait(done==1);
        $finish;
    end

/*   
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
*/
    integer i;
    // image rom
    always @(posedge clk or negedge rstn) begin
        if (!rstn|done) begin
            for (i = 0  ; i < 6; i = i + 1) begin
                image_6rows[i] <= 12'hxxx;  
            end 
        end
        else begin
            // Valid signal 
            if (image_rom_en) begin
                for (i = 0; i < 6; i = i + 1) begin
                    image_6rows[i] <= {4'h0, pixels[(i + cycle * 2) * 28 + image_idx]};  
                end
            end
            else begin
                for (i = 0  ; i < 6; i = i + 1) begin
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

    fc_weight_ROM#(
        .WEIGHT_FILE({{VIVADO_PROJECT_LOCATION},{"/data/fc_weight_transposed.txt"}})
    ) fc_weight_ROM_inst(
        .clk_i(clk),
        .weight_rom_en(weight_enable),
        .weight_idx(weight_indexing),

        .oDAT(weight_input_packed)
    );

    fc_bias_ROM#(
        .BIAS_FILE({{VIVADO_PROJECT_LOCATION},{"/data/fc_bias.txt"}})
    ) fc_bias_ROM_inst(
        .clk_i(clk),
        .bias_rom_en(weight_enable),
        .bias_idx(weight_indexing),

        .oDAT(fc_bias)
    );

    ROM_Weight #(
        .DATA_WIDTH(8),
        .WEIGHT_FILE_conv1_1({{VIVADO_PROJECT_LOCATION},{"/data/conv1_weight_1.txt"}}), 
        .WEIGHT_FILE_conv1_2({{VIVADO_PROJECT_LOCATION},{"/data/conv1_weight_2.txt"}}), 
        .WEIGHT_FILE_conv1_3({{VIVADO_PROJECT_LOCATION},{"/data/conv1_weight_3.txt"}}), 
        .WEIGHT_FILE_conv2_11({{VIVADO_PROJECT_LOCATION},{"/data/conv2_weight_11.txt"}}),
        .WEIGHT_FILE_conv2_12({{VIVADO_PROJECT_LOCATION},{"/data/conv2_weight_12.txt"}}),
        .WEIGHT_FILE_conv2_13({{VIVADO_PROJECT_LOCATION},{"/data/conv2_weight_13.txt"}}),
        .WEIGHT_FILE_conv2_21({{VIVADO_PROJECT_LOCATION},{"/data/conv2_weight_21.txt"}}),
        .WEIGHT_FILE_conv2_22({{VIVADO_PROJECT_LOCATION},{"/data/conv2_weight_22.txt"}}),
        .WEIGHT_FILE_conv2_23({{VIVADO_PROJECT_LOCATION},{"/data/conv2_weight_23.txt"}}),
        .WEIGHT_FILE_conv2_31({{VIVADO_PROJECT_LOCATION},{"/data/conv2_weight_31.txt"}}),
        .WEIGHT_FILE_conv2_32({{VIVADO_PROJECT_LOCATION},{"/data/conv2_weight_32.txt"}}),
        .WEIGHT_FILE_conv2_33({{VIVADO_PROJECT_LOCATION},{"/data/conv2_weight_33.txt"}})
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
    
    ROM_Bias#(
        .WEIGHT_FILE_bias_1({{VIVADO_PROJECT_LOCATION},{"/data/conv1_bias.txt"}}),
        .WEIGHT_FILE_bias_2({{VIVADO_PROJECT_LOCATION},{"/data/conv2_bias.txt"}})
    ) bias_rom(
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
