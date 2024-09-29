`timescale 1ns / 1ps

module tb_Max_Pooling_ReLU;

    // Inputs
    reg clk_i;
    reg rstn_i;
    reg valid_i;
    reg signed [11:0] data_in [0:1];  // 2x2 input data for MaxPooling

    // Outputs
    wire [11:0] data_out;
    wire ready_o;

    // Instantiate the Unit Under Test (UUT)
    Max_Pooling_ReLU uut (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .valid_i(valid_i),
        .data_in(data_in),
        .data_out(data_out),
        .ready_o(ready_o)
    );

    // Clock generation
    always #5 clk_i = ~clk_i;  // 10ns clock period

    // Test procedure
    initial begin
        // Initialize inputs
        clk_i = 0;
        rstn_i = 0;
        valid_i = 0;
        data_in[0] = 12'h000;
        data_in[1] = 12'h000;

        // Apply reset
        #15;
        rstn_i = 1;  // Release reset

        // Test case 1: Simple positive input data
        #10;
        valid_i = 1; 
        data_in[0] = 12'h00A;   // 10 in decimal
        data_in[1] = 12'h005;   // 5 in decimal

        #10;
        valid_i = 0;            // Wait for processing (20ns = 2 clock cycles)
        #20;
        $display("Test 1 - data_out: %h", data_out);  // Should be A (10 in decimal)

        // Test case 2: Negative input data
        #10;
        valid_i = 1;
        data_in[0] = 12'hFF8;   // -8 in decimal (two's complement)
        data_in[1] = 12'hFF1;   // -15 in decimal (two's complement)

        #10;
        valid_i = 0;
        #20;                   // Wait for processing
        $display("Test 2 - data_out: %h", data_out);  // Should be 0 due to ReLU

        // Test case 3: Mixed positive and negative input data
        #10;
        valid_i = 1;
        data_in[0] = 12'hFFD;   // -3 in decimal (two's complement)
        data_in[1] = 12'h007;   // 7 in decimal

        #10;
        valid_i = 0;
        #20;                   // Wait for processing
        $display("Test 3 - data_out: %h", data_out);  // Should be 7

        // Test case 4: Both inputs are zero
        #10;
        valid_i = 1;
        data_in[0] = 12'h000;    // 0
        data_in[1] = 12'h000;    // 0

        #10;
        valid_i = 0;
        #20;                   // Wait for processing
        $display("Test 4 - data_out: %h", data_out);  // Should be 0

        // Finish simulation
        #10;
        $finish;
    end

endmodule
