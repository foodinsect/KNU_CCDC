module top (
    input wire clk_i,
    input wire rstn_i,
    input wire start_i,
    
    input wire [11:0] image_6rows [0:5],

    input wire signed [7:0] conv1_weight_1 [0:24],
    input wire signed [7:0] conv1_weight_2 [0:24],
    input wire signed [7:0] conv1_weight_3 [0:24],
    input wire signed [7:0] bias_1 [0:2],

 /*   input wire signed [7:0] conv2_weight_11 [0:24],
    input wire signed [7:0] conv2_weight_12 [0:24],
    input wire signed [7:0] conv2_weight_13 [0:24],
    input wire signed [7:0] conv2_weight_21 [0:24],
    input wire signed [7:0] conv2_weight_22 [0:24],
    input wire signed [7:0] conv2_weight_23 [0:24],
    input wire signed [7:0] conv2_weight_31 [0:24],
    input wire signed [7:0] conv2_weight_32 [0:24],
    input wire signed [7:0] conv2_weight_33 [0:24],
    input wire signed [7:0] bias_2 [0:2],
   */ 

    output wire [5:0] cycle,
    output wire [9:0] image_idx,
    output wire image_rom_en,
    output wire [1:0] weight_sel,
    output wire [1:0] bias_sel,
    output wire ready,
    output wire done,
    output wire [3:0] result
);

////////////////////////////////////////////////////////////////////
// Signal Declaration
    // Control Signal
    wire            buf_valid_en;
    wire            buffer1_we;
    wire            buf_adr_clr;
    wire    [1:0]   buf_rd_mod;
    
    wire            PE_rstn; //convlution phase 1 is done this value must be high
    wire            PE_valid_o;
    wire            PE_clr_o;
    wire            PE_valid_i;
    wire    [1:0]   PE_mux_sel;
    
    wire            acc_wr_en;
    wire            acc_rd_en;

    wire            FIFO_valid;

    wire            shift_en;
    
    wire            conv_done;

    //PE input data wire
    wire [11:0]     PE_data_i [0:5];
    
    // Internal connections between PE_Array and FIFO
    wire signed [11:0] conv_out1 [0:1];             // Filter 1 outputs (2 values)
    wire signed [11:0] conv_out2 [0:1];             // Filter 2 outputs (2 values)
    wire signed [11:0] conv_out3 [0:1];             // Filter 3 outputs (2 values)
    
    // Internal connections between FIFO and MaxPooling&ReLU
    wire signed [11:0] conv_sum_1 [0:1];               // FIFO 1 outputs (1 values)
    wire signed [11:0] conv_sum_2 [0:1];               // FIFO 1 outputs (1 values)
    wire signed [11:0] conv_sum_3 [0:1];               // FIFO 1 outputs (1 values)
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
    wire  [11:0] buffer1_out [0:5];
    wire  [11:0] buffer2_out [0:5];
    wire  [11:0] buffer3_out [0:5];
    
    // shiftBuffer wire
    wire signed [11:0] shiftBuffer1_out;
    wire signed [11:0] shiftBuffer2_out;
    wire signed [11:0] shiftBuffer3_out;


    //////////////////////// fc_layer wire declaration ////////////////////////////////////////////
    wire [2:0] shifter_en_decoded ;


///////////////////////////////////////////////////////////////////
// PE input Muxing 
assign PE_data_i =  (PE_mux_sel == 2'b00 ? image_6rows :
                     PE_mux_sel == 2'b01 ? buffer1_out :
                     PE_mux_sel == 2'b10 ? buffer2_out :
                     buffer3_out);

// PE weight input Muxing




////////////////////////////////////////////////////////////////////
// Controller and PE Inst
    global_controller controller (
        // Input port
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .start_i(start_i),
        .iPE_valid_o(PE_valid_o),
        .fc_done_i(done),

        // Output port
        .oacc_wr_en(acc_wr_en),
        .obuf_rd_mod(buf_rd_mod),
        .oPE_rstn(PE_rstn),
        .weight_sel(weight_sel),
        .bias_sel(bias_sel),
        .o_PE_mux_sel(PE_mux_sel),
        .oBuf1_we(buffer1_we),
        .oBuf_adr_clr(buf_adr_clr),
        .oBuf_valid_en(buf_valid_en),
        .oPE_clr(PE_clr_o),
        .oPE_valid_i(PE_valid_i),
        .oimage_rom_en(image_rom_en),
        .oimage_idx(image_idx),
        .ocycle(cycle),
        .acc_rd_en(acc_rd_en),
        .FIFO_valid(FIFO_valid),
        .shift_en(shift_en),
        .conv_done(conv_done),
        .ready(ready)
    );
    
////////////////////////////////////////////////////////////////////
// PE Inst
    PE_Array PE_inst (
        .clk_i(clk_i),
        .rstn_i(rstn_i & ~done),
        .PE_rstn_i(PE_rstn),
        .valid_i(PE_valid_i),
        .clear_i(PE_clr_o),
        .acc_wr_en_i(acc_wr_en),
        .acc_rd_en_i(acc_rd_en),
                                            // conv1 : image data       |    conv2 :        1st         ->      2nd         ->      3rd
        .data_in(PE_data_i),              // conv1 : image_6rows      |    conv2 : buf1 data          -> buf2 data        -> buf3 data
        .filter1_weights(conv1_weight_1),   // conv1 : conv1_weight_1   |    conv2 : conv2_weight_11    -> conv2_weight_12  -> conv2_weight_13
        .filter2_weights(conv1_weight_2),   // conv1 : conv1_weight_2   |    conv2 : conv2_weight_21    -> conv2_weight_22  -> conv2_weight_23
        .filter3_weights(conv1_weight_3),   // conv1 : conv1_weight_3   |    conv2 : conv2_weight_31    -> conv2_weight_32  -> conv2_weight_33
        .bias_in(bias_1),                   // conv1 :      bias_1      |    conv2 :     bias_2
        
        .valid_o(PE_valid_o),
        .acc_full_o(),
        .conv_out1(conv_out1),      // Output from Filter 1
        .conv_out2(conv_out2),      // Output from Filter 2
        .conv_out3(conv_out3)       // Output from Filter 3
    );
    

////////////////////////////////////////////////////////////////////
// FIFO
    FIFO FIFO_Ch1(
        .clk_i(clk_i),
        .rstn_i(rstn_i & ~ready),
        .data_in_i(conv_out1),      // conv1 : conv_out1       |    conv2 : conv_sum
        .valid_in_i(PE_valid_o|FIFO_valid),
        
        .data_out_o(oFIFO_1),
        .valid_out_o(oMAX_En_1)
    );

    FIFO FIFO_Ch2(
        .clk_i(clk_i),
        .rstn_i(rstn_i & ~ready),
        .data_in_i(conv_out2),      // conv1 : conv_out2       |    conv2 : conv_sum
        .valid_in_i(PE_valid_o|FIFO_valid),
        
        .data_out_o(oFIFO_2),
        .valid_out_o(oMAX_En_2)
    );

    FIFO FIFO_Ch3(
        .clk_i(clk_i),
        .rstn_i(rstn_i & ~ready),
        .data_in_i(conv_out3),      // conv1 : conv_out3       |    conv2 : conv_sum
        .valid_in_i(PE_valid_o|FIFO_valid),
        
        .data_out_o(oFIFO_3),
        .valid_out_o(oMAX_En_3)
    );
    
////////////////////////////////////////////////////////////////////
// MaxPooling & ReLU
    Max_Pooling_ReLU MaxPooling_Ch1(
        .clk_i(clk_i),
        .rstn_i(rstn_i & ~ready),
        .valid_i(oMAX_En_1),
        .data_in(oFIFO_1),
        .data_o(oMAX_1),
        .valid_o(oBuf_En_1)
    );
    
    Max_Pooling_ReLU MaxPooling_Ch2(
        .clk_i(clk_i),
        .rstn_i(rstn_i & ~ready),
        .valid_i(oMAX_En_2),
        .data_in(oFIFO_2),
        .data_o(oMAX_2),
        .valid_o(oBuf_En_2)
    );
    
    Max_Pooling_ReLU MaxPooling_Ch3(
        .clk_i(clk_i),
        .rstn_i(rstn_i & ~ready),
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
        .clear_i(ready),
        .din_i(oMAX_1),
        .valid_i(oBuf_En_1 | buf_valid_en),
        .buffer1_we(buffer1_we),
        .rd_mod(buf_rd_mod),
        .dout_o(buffer1_out) 
    );
    
    buffer1 BUF2(
        .clk_i(clk_i),
        .rstn_i(rstn_i & (~buf_adr_clr)),
        .clear_i(ready),
        .din_i(oMAX_2),
        .valid_i(oBuf_En_2 | buf_valid_en),
        .buffer1_we(buffer1_we),
        .rd_mod(buf_rd_mod),
        .dout_o(buffer2_out) 
    );
    
    buffer1 BUF3(
        .clk_i(clk_i),
        .rstn_i(rstn_i & (~buf_adr_clr)),
        .clear_i(ready),
        .din_i(oMAX_3),
        .valid_i(oBuf_En_3 | buf_valid_en),
        .buffer1_we(buffer1_we),
        .rd_mod(buf_rd_mod),
        .dout_o(buffer3_out) 
    );
    
    shiftBuffer shiftBuffer1(
        .clk_i(clk_i),
        .data_i(oMAX_1),
        .shift_en((oBuf_En_1 & shift_en) | (shifter_en_decoded[0])),
        .data_o(shiftBuffer1_out)
    );

    shiftBuffer shiftBuffer2(
        .clk_i(clk_i),
        .data_i(oMAX_2),
        .shift_en((oBuf_En_2 & shift_en) | (shifter_en_decoded[1])),
        .data_o(shiftBuffer2_out)
    );

    shiftBuffer shiftBuffer3(
        .clk_i(clk_i),
        .data_i(oMAX_3),
        .shift_en((oBuf_En_3 & shift_en) | (shifter_en_decoded[2])),
        .data_o(shiftBuffer3_out)
    );
////////////////////////////////////////////////////////////////////
// fc_layer Inst
/*assign PE_data_i =  (PE_mux_sel == 2'b00 ? image_6rows :
                     PE_mux_sel == 2'b01 ? buffer1_out :
                     PE_mux_sel == 2'b10 ? buffer2_out :
                     buffer3_out);*/
    wire en;
    wire clear;
    wire next_step;
    wire signed [11:0] fc_data;
    wire [1:0]  fc_data_sel;
    wire [79:0] weight_input_packed;
    wire [7:0]  weight_input_unpacked [9:0];

    wire signed [7:0] fc_bias [0:9]; 


    // Unpacking process
    genvar k;
    for (k = 0; k < 10 ; k = k + 1) begin
        assign weight_input_unpacked[k] = weight_input_packed[k*8 +: 8];
    end

    assign fc_data = (fc_data_sel == 2'b01 ? shiftBuffer1_out :
                        fc_data_sel == 2'b10 ? shiftBuffer2_out :
                        fc_data_sel == 2'b11 ? shiftBuffer3_out : 12'hxxx);

    // shift enable decode process
    assign shifter_en_decoded = (fc_data_sel == 2'b00 ? 3'b000:
                                 fc_data_sel == 2'b01 ? 3'b001:
                                 fc_data_sel == 2'b10 ? 3'b010:3'b100);

    wire            weight_enable;
    wire [5:0]      weight_indexing;

    FC_layer fc_layer(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .en_i(en),
        .clear_i(clear),
        .flatten_input_i(fc_data),
        .weight_input_i(weight_input_unpacked),
        .bias_input_i(fc_bias),
    
        .result_o(result),//3bit
        .done_o(next_step)
    );

    FC_controller fc_controller(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .start_i(conv_done),
        .next_i(next_step), //from fc_layer
        .select_o(fc_data_sel),
        .clear_o(clear),
        .en_o(en),
        .weight_en(weight_enable),
        .weight_idx(weight_indexing),
        .done(done)
    );

    fc_weight_ROM fc_weight_ROM_inst(
        .clk_i(clk_i),
        .weight_rom_en(weight_enable),
        .weight_idx(weight_indexing),

        .oDAT(weight_input_packed)
    );

    fc_bias_ROM fc_bias_ROM_inst(
        .clk_i(clk_i),
        .bias_rom_en(weight_enable),
        .bias_idx(weight_indexing),

        .oDAT(fc_bias)
    );


endmodule