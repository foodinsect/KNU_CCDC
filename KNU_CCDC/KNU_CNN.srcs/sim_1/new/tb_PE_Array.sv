`timescale 1ns / 1ps

module tb_top();
    reg clk, rst_n;
    reg [7:0] pixels [0:783];                  // 28x28 image data
    reg [11:0] data_in [0:6];                 // 12 rows of input data (each 12 bits)
    reg [9:0] idx;
    reg [5:0] cycle;
    reg valid_i;
    reg clear;
    reg done;
    // Conv1 filter and bias weights
    reg signed [7:0] weight_11 [0:24];
    reg signed [7:0] weight_12 [0:24];
    reg signed [7:0] weight_13 [0:24];
    reg signed [7:0] bias_1 [0:2];
    

    // Instantiate PE Array module
    top UUT (
        .clk_i(clk),
        .rstn_i(rst_n),
        .valid_i(valid_i),                         // Assume always valid for simplicity
        .clear_i(clear),
        .data_in(data_in),
        .filter1_weights(weight_11),
        .filter2_weights(weight_12),
        .filter3_weights(weight_13),
        .bias_in(bias_1),
        .cycle(cycle),
        .valid_o(),
        .full_o(),
        .empty_o(),
        .fifo_out()
    );

    // Clock generation
    always #5 clk = ~clk;

    // Read image text file
    initial begin
        $readmemh("E:/cnn_verilog/data/0_01.txt", pixels);
        clk <= 1'b0;
        clear <= 1'b0;
        rst_n <= 1'b1;
        idx = 0;
        done = 1'b0;  // Initialize done signal to 0
        #3 rst_n <= 1'b0;
        #3 rst_n <= 1'b1;
    end

    // Read weights and biases for conv1
    initial begin
        $readmemh("E:/cnn_verilog/data/conv1_weight_1.txt", weight_11);
        $readmemh("E:/cnn_verilog/data/conv1_weight_2.txt", weight_12);
        $readmemh("E:/cnn_verilog/data/conv1_weight_3.txt", weight_13);
        $readmemh("E:/cnn_verilog/data/conv1_bias.txt", bias_1);
    end

    // Feed data_in (12 rows) to PE_Array, 5-column sliding window style
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            idx <= 0;
            valid_i <= 1'b0;
            clear <= 1'b0;
            cycle <= 0;
        end
        else begin
            integer i;
    
            // Activate valid signal
            valid_i <= 1'b1;
    
            // Fetch 12 rows of data using sliding window technique
            for (i = 0; i < 6; i = i + 1) begin
                data_in[i] <= {4'h0, pixels[(i + cycle * 2) * 28 + idx]};  // Fetch rows with 2-row shift
            end
    
            for (i = 6; i < 12; i = i + 1) begin
                data_in[i] <= {4'h0, pixels[(i + (cycle * 2) - 6) * 28 + idx]};  // Fetch overlapping data
            end
    
            // Move to the next column
            idx <= idx + 1;
    
            // Transition to the next cycle after processing 28 columns
            if (idx == 28) begin
                idx <= 0;
                cycle <= cycle + 1;
                clear <= 1'b1;  // Activate clear signal after processing 28 columns
            end
            else begin
                clear <= 1'b0;  // Deactivate clear signal if 28 columns are not yet processed
            end
    
            // Deactivate valid signal after the last cycle
            if (cycle == 12) begin  // 22~27 rows are the last, so total 13 cycles (0~12)
                valid_i <= 1'b0;
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

endmodule

