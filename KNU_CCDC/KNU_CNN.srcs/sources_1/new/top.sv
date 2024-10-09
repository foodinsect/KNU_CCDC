module top (
    input wire clk_i,
    input wire rstn_i,
    input wire valid_i,
    input wire clear_i,
    input wire signed [11:0] data_in [0:5],             // 6 rows of input data (each 12 bits)
    input wire signed [7:0] filter1_weights [0:24],     // Weights for Filter 1 (5x5)
    input wire signed [7:0] filter2_weights [0:24],     // Weights for Filter 2 (5x5)
    input wire signed [7:0] filter3_weights [0:24],     // Weights for Filter 3 (5x5)
    input wire signed [7:0] bias_in [0:2],              // Bias inputs for each filter
    output wire signed [11:0] fifo_out [0:1][0:1],      // Output data from FIFO (2 rows at a time)
    input wire [5:0] cycle,
    input wire  buf1_adr_clr,
    input wire  buf1_valid_en,
    input wire  buffer1_we_i,
    output wire [11:0] buffer1_out [0:5],
    output wire valid_o,
    output wire full_o,                            // FIFO full flag
    output wire empty_o                            // FIFO empty flag
);

    // Internal connections between PE_Array and FIFO
    wire signed [11:0] conv_out1 [0:1];             // Filter 1 outputs (2 values)
    wire signed [11:0] conv_out2 [0:1];             // Filter 2 outputs (2 values)
    wire signed [11:0] conv_out3 [0:1];             // Filter 3 outputs (2 values)
    
    // Internal connections between FIFO and MaxPooling&ReLU
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
    


    // Instantiate PE_Array
    PE_Array PE_inst (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .valid_i(valid_i),
        .clear_i(clear_i),
        .data_in(data_in),
        .filter1_weights(filter1_weights),
        .filter2_weights(filter2_weights),
        .filter3_weights(filter3_weights),
        .bias_in(bias_in),
        .valid_o(valid_o),
        .conv_out1(conv_out1),      // Output from Filter 1
        .conv_out2(conv_out2),      // Output from Filter 2
        .conv_out3(conv_out3)       // Output from Filter 3
    );
    
    FIFO FIFO_Ch1(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .data_in_i(conv_out1),
        .valid_in_i(valid_o),
        
        .data_out_o(oFIFO_1),
        .valid_out_o(oMAX_En_1)
    );

    FIFO FIFO_Ch2(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .data_in_i(conv_out2),
        .valid_in_i(valid_o),
        
        .data_out_o(oFIFO_2),
        .valid_out_o(oMAX_En_2)
    );

    FIFO FIFO_Ch3(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .data_in_i(conv_out3),
        .valid_in_i(valid_o),
        
        .data_out_o(oFIFO_3),
        .valid_out_o(oMAX_En_3)
    );

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

    buffer1 BUF1(
        .clk_i(clk_i),
        .rstn_i(rstn_i & (~buf1_adr_clr)),
        .din_i(oMAX_1),
        .valid_i(oBuf_En_1 | buf1_valid_en),
        .buffer1_we(buffer1_we_i),
        .dout_o(buffer1_out) 
    );
    
    /*
    buffer1 BUF2(
        .clk_i(clk_i),
        .rstn_i(rstn_i & (~buf2_adr_clr)),
        .din_i(oMAX_2),
        .valid_i(oBuf_En_2 | buf2_valid_en),
        .buffer1_we(buffer2_we_i),
        .dout_o(buffer2_out) 
    );
    
    buffer1 BUF3(
        .clk_i(clk_i),
        .rstn_i(rstn_i & (~buf3_adr_clr)),
        .din_i(oMAX_3),
        .valid_i(oBuf_En_3 | buf3_valid_en),
        .buffer1_we(buffer3_we_i),
        .dout_o(buffer3_out) 
    );
    */
    

    
endmodule