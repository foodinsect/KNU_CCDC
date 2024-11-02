module PE_Array (
    input wire clk_i,
    input wire rstn_i,
    input wire PE_rstn_i,
    input wire valid_i,
    input wire clear_i,
    input wire acc_wr_en_i,
    input wire acc_rd_en_i,

    input wire signed [11:0] data_in [0:5],           // 12 rows of input data (each 12 bits)
    input wire signed [7:0] filter1_weights [0:24],    // Weights for Filter 1 (5x5)
    input wire signed [7:0] filter2_weights [0:24],    // Weights for Filter 2 (5x5)
    input wire signed [7:0] filter3_weights [0:24],    // Weights for Filter 3 (5x5)
    input wire signed [7:0] bias_in [0:2],
    output reg valid_o,
    output wire acc_full_o,
    output wire signed [11:0] conv_out1 [0:1],         // Output for Filter 1 (2 PE Array)
    output wire signed [11:0] conv_out2 [0:1],         // Output for Filter 2 (2 PE Array)
    output wire signed [11:0] conv_out3 [0:1]          // Output for Filter 3 (2 PE Array)
);
 
    // Declare the shared data_slice for each PE
    genvar i, j;

    reg [1:0] clear_d;
    reg [2:0] buffer_count;                         // To track when 5 data_in cycles are complete
    
    reg signed [19:0] pe_out1 [0:1];
    reg signed [19:0] pe_out2 [0:1];
    reg signed [19:0] pe_out3 [0:1];

    reg signed [11:0] conv_sum1 [0:1];
    reg signed [11:0] conv_sum2 [0:1];
    reg signed [11:0] conv_sum3 [0:1];

    wire signed [11:0] PE_Slice1 [0:1];
    wire signed [11:0] PE_Slice2 [0:1];
    wire signed [11:0] PE_Slice3 [0:1];

    wire [2:0] acc_full;


    // Instantiate Filter 1 (2 PE Array)
    generate
        for (i = 0; i < 2; i = i + 1) begin : PE_ARRAY1
            conv2d_pe Ch1 (
                .clk_i(clk_i),
                .rstn_i(rstn_i),
                .valid_i(valid_i),
                .clear_i(clear_i),
                .data_in(data_in[i:4+i]),            // Input data slice for this PE
                .weight_in(filter1_weights),     // Filter 1 weights
                .pe_out(pe_out1[i])            // Output of each PE in the 2 array
            );
            assign PE_Slice1[i] = (acc_wr_en_i) ? $signed(pe_out1[i][19:8]) : $signed(pe_out1[i][19:8]) + $signed(bias_in[0]);
        end
    endgenerate

    // Instantiate Filter 2 (2 PE Array)
    generate
        for (i = 0; i < 2; i = i + 1) begin : PE_ARRAY2
            conv2d_pe Ch2 (
                .clk_i(clk_i),
                .rstn_i(rstn_i),
                .valid_i(valid_i),
                .clear_i(clear_i),
                .data_in(data_in[i:4+i]),            // Input data slice for this PE
                .weight_in(filter2_weights),     // Filter 2 weights
                .pe_out(pe_out2[i])            // Output of each PE in the 2 array
            );
            assign PE_Slice2[i] = (acc_wr_en_i) ? $signed(pe_out2[i][19:8]) : $signed(pe_out2[i][19:8]) + $signed(bias_in[1]);
        end
    endgenerate

    // Instantiate Filter 3 (2 PE Array)
    generate
        for (i = 0; i < 2; i = i + 1) begin : PE_ARRAY3
            conv2d_pe Ch3 (
                .clk_i(clk_i),
                .rstn_i(rstn_i),
                .valid_i(valid_i),
                .clear_i(clear_i),
                .data_in(data_in[i:4+i]),            // Input data slice for this PE
                .weight_in(filter3_weights),     // Filter 3 weights
                .pe_out(pe_out3[i])            // Output of each PE in the 2 array
            );
            assign PE_Slice3[i] = (acc_wr_en_i) ? $signed(pe_out3[i][19:8]) : $signed(pe_out3[i][19:8]) + $signed(bias_in[2]);
        end
    endgenerate


    // delay clear signal
    always @(posedge clk_i) begin
        clear_d[0] <= clear_i;
        clear_d[1] <= clear_d[0];
    end
    
    always @(posedge clk_i) begin
        if (!(rstn_i & ~PE_rstn_i)) begin
            // Reset all values and buffers
            valid_o <= 1'b0;
            buffer_count <= 0;
        end
        else begin
            if(valid_i) begin
                // Valid_o on when buffer_count reaches 5
                if (buffer_count > 4) begin
                    valid_o <= 1'b1;  // Set output valid signal
                end
                else begin
                    // Increment the buffer count and total data count
                    buffer_count <= buffer_count + 1;
                end
            end
            if (clear_d[0]) begin
                valid_o <= 1'b0;
                buffer_count <= 3'b001;  // Reset buffer count for the next set
            end
        end
    end

    ////////////////////////////////////////////////////////////////////
    // ACC
    Accumulator ACC_Ch1(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .valid_i(valid_o & acc_wr_en_i),                    // enable signal from controller + PE_valid_o
        .rd_en_i(acc_rd_en_i),
        .bias_i(bias_in[0]),
        .conv_in(pe_out1),
        .conv_sum(conv_sum1),
        .acc_full_o(acc_full[0])
    );
    
    Accumulator ACC_Ch2(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .valid_i(valid_o & acc_wr_en_i),                    // enable signal from controller + PE_valid_o
        .rd_en_i(acc_rd_en_i),
        .bias_i(bias_in[1]),
        .conv_in(pe_out2),
        .conv_sum(conv_sum2),
        .acc_full_o(acc_full[1])
    );

    Accumulator ACC_Ch3(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .valid_i(valid_o & acc_wr_en_i),                    // enable signal from controller + PE_valid_o
        .rd_en_i(acc_rd_en_i),
        .bias_i(bias_in[2]),
        .conv_in(pe_out3),
        .conv_sum(conv_sum3),
        .acc_full_o(acc_full[2])
    );

    assign acc_full_o = &acc_full;
    assign conv_out1 = (acc_rd_en_i) ? conv_sum1 : PE_Slice1;
    assign conv_out2 = (acc_rd_en_i) ? conv_sum2 : PE_Slice2;
    assign conv_out3 = (acc_rd_en_i) ? conv_sum3 : PE_Slice3;


endmodule