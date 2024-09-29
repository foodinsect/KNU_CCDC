module PE_Array (
    input wire clk_i,
    input wire rstn_i,
    input wire valid_i,
    input wire clear_i,
    input wire signed [11:0] data_in [0:6],           // 12 rows of input data (each 12 bits)
    input wire signed [7:0] filter1_weights [0:24],    // Weights for Filter 1 (5x5)
    input wire signed [7:0] filter2_weights [0:24],    // Weights for Filter 2 (5x5)
    input wire signed [7:0] filter3_weights [0:24],    // Weights for Filter 3 (5x5)
    input wire signed [7:0] bias_in [0:2],
    output reg valid_o,
    output wire signed [11:0] conv_out1 [0:1],         // Output for Filter 1 (5x8 PE Array)
    output wire signed [11:0] conv_out2 [0:1],         // Output for Filter 2 (5x8 PE Array)
    output wire signed [11:0] conv_out3 [0:1]          // Output for Filter 3 (5x8 PE Array)
);
 
    // Declare the shared data_slice for each PE
    genvar i, j;

    reg [1:0] clear_d;
    reg [2:0] buffer_count;                         // To track when 5 data_in cycles are complete


//    wire [11:0] data_slice [0:1][0:4]; // 8 PE arrays, each with 5-element slice
//    // Generate sliding window for data_in based on i
//    generate
//        for (i = 0; i < 2; i = i + 1) begin : SLIDING_WINDOW
//            for (j = 0; j < 5; j = j + 1) begin
//                // Each PE gets a unique slice of 5 consecutive data elements
//                assign data_slice[i][j] = data_in[i+j]; // Sliding window: shift by i
//            end
//        end
//    endgenerate


    // Instantiate Filter 1 (5x8 PE Array)
    generate
        for (i = 0; i < 2; i = i + 1) begin : PE_ARRAY1
            conv2d_pe Ch1 (
                .clk_i(clk_i),
                .rstn_i(rstn_i),
                .valid_i(valid_i),
                .clear_i(clear_i),
                .data_in(data_in[i:5+i]),            // Input data slice for this PE
                .weight_in(filter1_weights),     // Filter 1 weights
                .bias_in(bias_in[0]),
                .pe_out(conv_out1[i])            // Output of each PE in the 5x8 array
            );
        end
    endgenerate

    // Instantiate Filter 2 (5x8 PE Array)
    generate
        for (i = 0; i < 2; i = i + 1) begin : PE_ARRAY2
            conv2d_pe Ch2 (
                .clk_i(clk_i),
                .rstn_i(rstn_i),
                .valid_i(valid_i),
                .clear_i(clear_i),
                .data_in(data_in[i:5+i]),            // Input data slice for this PE
                .weight_in(filter2_weights),     // Filter 2 weights
                .bias_in(bias_in[1]),
                .pe_out(conv_out2[i])            // Output of each PE in the 5x8 array
            );
        end
    endgenerate

    // Instantiate Filter 3 (5x8 PE Array)
    generate
        for (i = 0; i < 2; i = i + 1) begin : PE_ARRAY3
            conv2d_pe Ch3 (
                .clk_i(clk_i),
                .rstn_i(rstn_i),
                .valid_i(valid_i),
                .clear_i(clear_i),
                .data_in(data_in[i:5+i]),            // Input data slice for this PE
                .weight_in(filter3_weights),     // Filter 3 weights
                .bias_in(bias_in[2]),
                .pe_out(conv_out3[i])            // Output of each PE in the 5x8 array
            );
        end
    endgenerate


    // delay clear signal
    always @(posedge clk_i) begin
        clear_d[0] <= clear_i;
        clear_d[1] <= clear_d[0];
    end
    
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
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
                buffer_count <= 3'b010;  // Reset buffer count for the next set
            end
        end
    end
    
endmodule