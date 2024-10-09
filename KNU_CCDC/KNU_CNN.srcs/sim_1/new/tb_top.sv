`timescale 1ns / 1ps

module tb_top();

    reg [7:0] pixels [0:783];                  // 28x28 image data
    reg [11:0] data_in [0:5];                 // 12 rows of input data (each 12 bits)
   

    reg signed [7:0] weight_11 [0:24];
    reg signed [7:0] weight_12 [0:24];
    reg signed [7:0] weight_13 [0:24];
    reg signed [7:0] bias_1 [0:2];

    reg done;
    reg clk;
    reg rstn;
    reg start_i;

    wire            buf1_valid_en;
    wire            buffer1_we;
    wire            buf_adr_clr;
    wire            PE_VALID_PEout;
    wire            PE_clr_o;
    wire            PE_valid_PEin;
    wire            rom_conv1_read;
    wire  [9:0]     PEin_idx;
    wire  [5:0]     cycle;
    wire  [11:0]    buffer1_ch1_out [0:5];

    // Instantiate the global_controller
    global_controller controller (
        .clk_i(clk),
        .rstn_i(rstn),
        .start_i(start_i),
        .PE_valid_PEout_o(PE_VALID_PEout),
        .buffer1_we(buffer1_we),
        .buf1_adr_clr(buf_adr_clr),
        .buf1_valid_en(buf1_valid_en),
        .PE_clr_o(PE_clr_o),
        .PE_valid_PEin_o(PE_valid_PEin),
        .rom_conv1_read(rom_conv1_read),
        .PEin_idx(PEin_idx),
        .cycle(cycle)
    );

    // Instantiate PE Array module
    top TOP_inst (
        .clk_i(clk),
        .rstn_i(rstn),
        .valid_i(PE_valid_PEin),                         // Assume always valid for simplicity
        .clear_i(PE_clr_o),
        .data_in(data_in),
        .filter1_weights(weight_11),
        .filter2_weights(weight_12),
        .filter3_weights(weight_13),
        .bias_in(bias_1),
        .cycle(cycle),
        .buf1_adr_clr(buf_adr_clr),
        .buf1_valid_en(buf1_valid_en),
        .buffer1_we_i(buffer1_we),
        .buffer1_out(buffer1_ch1_out),
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
        clk <= 1'b0;;
        rstn <= 1'b1;
        done = 1'b0;  // Initialize done signal to 0 
        start_i = 1'b0;
        #10 rstn <= 1'b0;
        #10 rstn <= 1'b1;
        #10 start_i = 1'b1;
        #10 start_i = 1'b0;
    end

    // Read weights and biases for conv1
    initial begin
        $readmemh("E:/cnn_verilog/data/conv1_weight_1.txt", weight_11);
        $readmemh("E:/cnn_verilog/data/conv1_weight_2.txt", weight_12);
        $readmemh("E:/cnn_verilog/data/conv1_weight_3.txt", weight_13);
        $readmemh("E:/cnn_verilog/data/conv1_bias.txt", bias_1);
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
        end
        else begin
            integer i;

            // Valid signal 
            if (rom_conv1_read) begin
                for (i = 0; i < 6; i = i + 1) begin
                    data_in[i] <= {4'h0, pixels[(i + cycle * 2) * 28 + PEin_idx]};  
                end

                for (i = 6; i < 12; i = i + 1) begin
                    data_in[i] <= {4'h0, pixels[(i + (cycle * 2) - 6) * 28 + PEin_idx]};  
                end
            end

            if (cycle == 12) begin
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

