module conv2d_pe (
    input wire clk_i,
    input wire rstn_i,                                  // Reset signal (when 1, initialize)
    input wire valid_i,                                 // Valid signal (perform calculations only when data is valid)
    input wire clear_i,
    input wire signed [11:0] data_in [0:4],             // 5 input data values (input one row at a time)
    input wire signed [7:0] weight_in [0:24],           // 5x5 filter weights
    input wire signed [7:0] bias_in,                    // Bias input (added after convolution)
    output reg signed [11:0] pe_out                     // Final convolution output
);
    // Declare 5 line buffers to store 5 rows
    reg [11:0] line_buffer1 [0:4];  
    reg [11:0] line_buffer2 [0:4];
    reg [11:0] line_buffer3 [0:4];
    reg [11:0] line_buffer4 [0:4];
    reg [11:0] line_buffer5 [0:4];
    

    reg signed [19:0] partial_sum;                  // Accumulator for intermediate multiplication results
    

    integer i;
    
    always @(posedge clk_i) begin
        if (valid_i) begin
            // Store the new input data in line_buffer[4]
            line_buffer1[4] <= data_in[0];
            line_buffer2[4] <= data_in[1];
            line_buffer3[4] <= data_in[2];
            line_buffer4[4] <= data_in[3];
            line_buffer5[4] <= data_in[4];
            
            for (i = 0; i < 4; i = i + 1) begin
                line_buffer1[i] <= line_buffer1[i+1];
                line_buffer2[i] <= line_buffer2[i+1];
                line_buffer3[i] <= line_buffer3[i+1];
                line_buffer4[i] <= line_buffer4[i+1];
                line_buffer5[i] <= line_buffer5[i+1];
            end
            
            // Perform Convolution
            partial_sum = 0;  // Initialize accumulation result
            for (i = 0; i < 5; i = i + 1) begin
                partial_sum = partial_sum + ($signed(line_buffer1[i]) * $signed(weight_in[i])) +
                                            ($signed(line_buffer2[i]) * $signed(weight_in[i+5])) +
                                            ($signed(line_buffer3[i]) * $signed(weight_in[i+10])) +
                                            ($signed(line_buffer4[i]) * $signed(weight_in[i+15])) +
                                            ($signed(line_buffer5[i]) * $signed(weight_in[i+20]));
            end
            // After the convolution result is calculated, add the bias
            pe_out <= $signed(partial_sum[19:8]) + $signed(bias_in);  // Add signed bias after accumulation
        end
        // Clear logic
        if (clear_i) begin
            for (i = 0; i < 4; i = i + 1) begin
                line_buffer1[i] <= 12'hxx;
                line_buffer2[i] <= 12'hxx;
                line_buffer3[i] <= 12'hxx;
                line_buffer4[i] <= 12'hxx;
                line_buffer5[i] <= 12'hxx;
            end
        end
    end
    
endmodule