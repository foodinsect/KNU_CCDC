`timescale 1ns / 1ps

module Accumulator(
    input wire clk_i,
    input wire rstn_i,
    input wire en_i,
    input wire signed [11:0] conv_in1 [0:1],
    input wire signed [11:0] conv_in2 [0:1],
    input wire signed [11:0] conv_in3 [0:1],
    output wire signed [11:0] conv_sum [0:1]
);
    reg signed [19:0] acc [0:1];
    
    assign conv_sum[0] = acc[0][19:8];
    assign conv_sum[1] = acc[1][19:8];
    
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            acc[0] <= 20'h0;
            acc[1] <= 20'h0;
        end
        else begin
            if (en_i) begin
                acc[0] <= conv_in1[0] + conv_in2[0] + conv_in3[0];
                acc[1] <= conv_in1[1] + conv_in2[1] + conv_in3[1];
            end
            else begin
                acc[0] <= 20'hz;
                acc[1] <= 20'hz;
            end
        end
    end
    
    
endmodule
