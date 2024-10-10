module top (
    input wire clk_i,
    input wire rstn_i,
    input wire start_i,
    
    input wire [11:0] image_6rows [0:5],

    input wire signed [7:0] conv1_weight_1 [0:24],
    input wire signed [7:0] conv1_weight_2 [0:24],
    input wire signed [7:0] conv1_weight_3 [0:24],
    input wire signed [7:0] bias_1 [0:2],

    input wire signed [7:0] conv2_weight_11 [0:24],
    input wire signed [7:0] conv2_weight_12 [0:24],
    input wire signed [7:0] conv2_weight_13 [0:24],
    input wire signed [7:0] conv2_weight_21 [0:24],
    input wire signed [7:0] conv2_weight_22 [0:24],
    input wire signed [7:0] conv2_weight_23 [0:24],
    input wire signed [7:0] conv2_weight_31 [0:24],
    input wire signed [7:0] conv2_weight_32 [0:24],
    input wire signed [7:0] conv2_weight_33 [0:24],
    input wire signed [7:0] bias_2 [0:2],

    output wire [5:0] cycle,
    output wire [9:0] image_idx,
    output wire image_rom_en,
    input wire done
);

////////////////////////////////////////////////////////////////////
// Signal Declaration
    // Control Signal
    wire            buf_valid_en;
    wire            buffer1_we;
    wire            buf_adr_clr;
    
    wire            PE_valid_o;
    wire            PE_clr_o;
    wire            PE_valid_i;
    
    // Internal connections between PE_Array and FIFO
    wire signed [11:0] conv_out1 [0:1];             // Filter 1 outputs (2 values)
    wire signed [11:0] conv_out2 [0:1];             // Filter 2 outputs (2 values)
    wire signed [11:0] conv_out3 [0:1];             // Filter 3 outputs (2 values)
    
    // Internal connections between FIFO and MaxPooling&ReLU
    wire signed [11:0] conv_sum [0:1];               // FIFO 1 outputs (1 values)
    wire signed [11:0] oFIFO_1 [0:1];               // FIFO 1 outputs (1 values)
    wire signed [11:0] oFIFO_2 [0:1];               // FIFO 2 outputs (1 values)
    wire signed [11:0] oFIFO_3 [0:1];               // FIFO 3 outputs (1 values)
    wire oMAX_En_1, oMAX_En_2, oMAX_En_3;
    
    // Internal connections between MaxPooling&ReLU and Buffer
    wire signed [11:0] oMAX_1;                      // MaxPooling 1 outputs (1 values)
    wire signed [11:0] oMAX_2;                      // MaxPooling 2 outputs (1 values)
    wire signed [11:0] oMAX_3;                      // MaxPooling 3 outputs (1 values)
    wire oBuf_En_1, oBuf_En_2, oBuf_En_3;
    
    // Internal connections between Buffer and Conv Layer 2
    wire signed [11:0] buffer1_out [0:5];
    wire signed [11:0] buffer2_out [0:5];
    wire signed [11:0] buffer3_out [0:5];
    
////////////////////////////////////////////////////////////////////
// Controller and PE Inst
    global_controller controller (
        // Input port
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .start_i(start_i),
        .iPE_valid_o(PE_valid_o),
        
        // Output port
        .oBuf1_we(buffer1_we),
        .oBuf_adr_clr(buf_adr_clr),
        .oBuf_valid_en(buf_valid_en),
        .oPE_clr(PE_clr_o),
        .oPE_valid_i(PE_valid_i),
        .oimage_rom_en(image_rom_en),
        .oimage_idx(image_idx),
        .ocycle(cycle)
    );
    
////////////////////////////////////////////////////////////////////
// PE Inst
    PE_Array PE_inst (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .valid_i(PE_valid_i),
        .clear_i(PE_clr_o),
                                            // conv1 : image data       |    conv2 :        1st         ->      2nd         ->      3rd
        .data_in(image_6rows),              // conv1 : image_6rows      |    conv2 : buf1 data          -> buf2 data        -> buf3 data
        .filter1_weights(conv1_weight_1),   // conv1 : conv1_weight_1   |    conv2 : conv2_weight_11    -> conv2_weight_12  -> conv2_weight_13
        .filter2_weights(conv1_weight_2),   // conv1 : conv1_weight_2   |    conv2 : conv2_weight_21    -> conv2_weight_22  -> conv2_weight_23
        .filter3_weights(conv1_weight_3),   // conv1 : conv1_weight_3   |    conv2 : conv2_weight_31    -> conv2_weight_32  -> conv2_weight_33
        .bias_in(bias_1),                   // conv1 :      bias_1      |    conv2 :     bias_2
        
        .valid_o(PE_valid_o),
        .conv_out1(conv_out1),      // Output from Filter 1
        .conv_out2(conv_out2),      // Output from Filter 2
        .conv_out3(conv_out3)       // Output from Filter 3
    );
    
////////////////////////////////////////////////////////////////////
// ACC
    Accumulator ACC(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .en_i(),                    // enable signal from controller + PE_valid_o
        .conv_in1(conv_out1),
        .conv_in2(conv_out2),
        .conv_in3(conv_out3),
        .conv_sum(conv_sum)
    );
    
////////////////////////////////////////////////////////////////////
// FIFO
    FIFO FIFO_Ch1(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .data_in_i(conv_out1),      // conv1 : conv_out1       |    conv2 : conv_sum
        .valid_in_i(PE_valid_o),
        
        .data_out_o(oFIFO_1),
        .valid_out_o(oMAX_En_1)
    );

    FIFO FIFO_Ch2(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .data_in_i(conv_out2),      // conv1 : conv_out2       |    conv2 : conv_sum
        .valid_in_i(PE_valid_o),
        
        .data_out_o(oFIFO_2),
        .valid_out_o(oMAX_En_2)
    );

    FIFO FIFO_Ch3(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .data_in_i(conv_out3),      // conv1 : conv_out3       |    conv2 : conv_sum
        .valid_in_i(PE_valid_o),
        
        .data_out_o(oFIFO_3),
        .valid_out_o(oMAX_En_3)
    );
    
////////////////////////////////////////////////////////////////////
// MaxPooling & ReLU
    Max_Pooling_ReLU MaxPooling_Ch1(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .valid_i(oMAX_En_1),
        .data_in(oFIFO_1),
        .data_o(oMAX_1),
        .valid_o(oBuf_En_1)
    );
    
    Max_Pooling_ReLU MaxPooling_Ch2(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .valid_i(oMAX_En_2),
        .data_in(oFIFO_2),
        .data_o(oMAX_2),
        .valid_o(oBuf_En_2)
    );
    
    Max_Pooling_ReLU MaxPooling_Ch3(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .valid_i(oMAX_En_3),
        .data_in(oFIFO_3),
        .data_o(oMAX_3),
        .valid_o(oBuf_En_3)
    );
    
////////////////////////////////////////////////////////////////////
// Buf Inst

    buffer1 BUF1(
        .clk_i(clk_i),
        .rstn_i(rstn_i & (~buf_adr_clr)),
        .din_i(oMAX_1),
        .valid_i(oBuf_En_1 | buf_valid_en),
        .buffer1_we(buffer1_we),
        .dout_o(buffer1_out) 
    );
    
    buffer1 BUF2(
        .clk_i(clk_i),
        .rstn_i(rstn_i & (~buf_adr_clr)),
        .din_i(oMAX_2),
        .valid_i(oBuf_En_2 | buf_valid_en),
        .buffer1_we(buffer1_we),
        .dout_o(buffer2_out) 
    );
    
    buffer1 BUF3(
        .clk_i(clk_i),
        .rstn_i(rstn_i & (~buf_adr_clr)),
        .din_i(oMAX_3),
        .valid_i(oBuf_En_3 | buf_valid_en),
        .buffer1_we(buffer1_we),
        .dout_o(buffer3_out) 
    );
    



endmodule