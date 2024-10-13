`timescale 1ns / 1ps //2024.10.13 update

module tb_FC_layer();
    reg signed [11:0] flatten_mem [47:0]; // flatten data memory
    reg signed [7:0] weight_mem [479:0];   // weight data memory (48*10)

    reg clk;
    reg rstn;
    reg clear;
    reg en;
    
    reg signed [7:0] bias_input [0:9];
    reg signed [11:0] flatten_input;
    reg signed [7:0] weight_input [9:0];

    wire [3:0] result;

    // Instantiate Top_CNN module
    FC_layer uut (
        .clk_i(clk),
        .rstn_i(rstn),
        .en_i(en),
        .clear_i(clear),
        .flatten_input_i(flatten_input),
        .weight_input_i(weight_input),
        .bias_input_i(bias_input),
        .result_o(result)
    );

    integer i, cycle;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Initialize and load data
    initial begin
        rstn = 1;
        
        #10 
        rstn = 0;
        en = 0;
        clear = 0;
        cycle = 0;

        flatten_input = 0;
        weight_input[9] = 0;
        weight_input[8] = 0;
        weight_input[7] = 0;
        weight_input[6] = 0;
        weight_input[5] = 0;
        weight_input[4] = 0;
        weight_input[3] = 0;
        weight_input[2] = 0;
        weight_input[1] = 0;
        weight_input[0] = 0;

        $readmemh("E:/Verilog/CNN_MNIST/fc_input_test.txt", flatten_mem);
        $readmemh("E:/Verilog/CNN_MNIST/fc_weight_transposed.txt", weight_mem);
        $readmemh("E:/Verilog/CNN_MNIST/fc_bias.txt", bias_input);
        
        #10
        rstn = 1;
    end

    // Data input control logic
    always @(posedge clk) begin
        if (~rstn) begin
            cycle <= 0;
            en <= 0;
        end 
        else begin
            if (cycle < 48) begin
                en <= 1;
                flatten_input <= flatten_mem[cycle];
                weight_input[9] <= weight_mem[cycle*10 + 0];
                weight_input[8] <= weight_mem[cycle*10 + 1];
                weight_input[7] <= weight_mem[cycle*10 + 2];
                weight_input[6] <= weight_mem[cycle*10 + 3];
                weight_input[5] <= weight_mem[cycle*10 + 4];
                weight_input[4] <= weight_mem[cycle*10 + 5];
                weight_input[3] <= weight_mem[cycle*10 + 6];
                weight_input[2] <= weight_mem[cycle*10 + 7];
                weight_input[1] <= weight_mem[cycle*10 + 8];
                weight_input[0] <= weight_mem[cycle*10 + 9];
                
                cycle <= cycle + 1;
            end 
           else if (cycle == 48) begin
                en <= 0;
                clear <= 1;
                cycle <= cycle + 1;
            end 
            else if (cycle == 49) begin
                clear <= 0;
                cycle <= 0;
            end
        end
    end


    // Simulation end condition
    initial begin
        #5000 $finish;
    end
endmodule
