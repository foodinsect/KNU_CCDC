module top (
    input wire clk_i,
    input wire rstn_i,
    input wire valid_i,
    input wire clear_i,
    input wire signed [11:0] data_in [0:6],       // 12 rows of input data (each 12 bits)
    input wire signed [7:0] filter1_weights [0:24],// Weights for Filter 1 (5x5)
    input wire signed [7:0] filter2_weights [0:24],// Weights for Filter 2 (5x5)
    input wire signed [7:0] filter3_weights [0:24],// Weights for Filter 3 (5x5)
    input wire signed [7:0] bias_in [0:2],         // Bias inputs for each filter
    output wire signed [11:0] fifo_out [0:1][0:1],// Output data from FIFO (2 rows at a time)
    input wire [5:0] cycle,
    output wire valid_o,
    output wire full_o,                            // FIFO full flag
    output wire empty_o                            // FIFO empty flag
);

    // Internal connections between PE_Array and FIFO
    wire signed [11:0] conv_out1 [0:1];  // Filter 1 outputs (8 values)
    wire signed [11:0] conv_out2 [0:1];  // Filter 2 outputs (8 values)
    wire signed [11:0] conv_out3 [0:1];  // Filter 3 outputs (8 values)
    

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
    
    
/*
    reg [1:0] cycle_reg1;  // First delay register
    reg [1:0] cycle_reg2;  // Second delay register
    reg [1:0] cycle_delayed;
    
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            // Reset the delayed cycle signals
            cycle_reg1 <= 2'b00;
            cycle_reg2 <= 2'b00;
            cycle_delayed <= 2'b00;
        end
        else begin
            // Shift the cycle signal through two registers (2-cycle delay)
            cycle_reg1 <= cycle;         // First delay
            cycle_reg2 <= cycle_reg1;    // Second delay
            cycle_delayed <= cycle_reg2; // Output delayed signal
        end
    end
    
    // Instantiate FIFO
    FIFO_2x2 #(
        .DATA_WIDTH(12)
    ) FIFO_1 (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .wr_en_i(valid_o),              // Write enable (from top module control logic)
        .data_in(conv_out1), // FIFO receives 8 rows of convolution results
        .data_out(fifo_out),          // Output 2 rows from FIFO
        .full_o(full_o),              // FIFO full flag
        .ready_o(empty_o)             // FIFO empty flag
    );
   
   // Instantiate FIFO
    FIFO_2x2 #(
        .DATA_WIDTH(12)
    ) FIFO_2 (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .wr_en_i(valid_o),              // Write enable (from top module control logic)
        .data_in(conv_out2), // FIFO receives 8 rows of convolution results
        .data_out(fifo_out),          // Output 2 rows from FIFO
        .full_o(full_o),              // FIFO full flag
        .ready_o(empty_o)             // FIFO empty flag
    );
    
    // Instantiate FIFO
    FIFO_2x2 #(
        .DATA_WIDTH(12)
    ) FIFO_3 (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .wr_en_i(valid_o),              // Write enable (from top module control logic)
        .data_in(conv_out3), // FIFO receives 8 rows of convolution results
        .data_out(fifo_out),          // Output 2 rows from FIFO
        .full_o(full_o),              // FIFO full flag
        .ready_o(empty_o)             // FIFO empty flag
    );
    
*/



endmodule
