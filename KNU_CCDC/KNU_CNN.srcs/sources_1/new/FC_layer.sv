module FC_layer( //2024.10.13 update
    input wire clk_i,
    input wire rstn_i,
    input wire en_i,
    input wire clear_i,
    input wire signed [11:0] flatten_input_i,
    input wire signed [7:0] weight_input_i [0:9],
    input wire signed [7:0] bias_input_i [0:9],
    
    output wire [3:0] result_o,
    output wire done_o
);

    // Intermediate wires
    wire valid_out;
    wire signed [11:0] data_out [0:9];
    
    assign done_o = valid_out;
    
    // Instantiate FC_layer
    matmul matmul_inst (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .clear_i(clear_i),  // Assume clear is not used in this case
        .en_i(en_i),
        .flatten_i(flatten_input_i),
        .weight_i(weight_input_i),
        .bias_i(bias_input_i),
        .valid_out_o(valid_out),
        .data_out_o(data_out)
    );

    // Instantiate max_finder
    max_finder max_finder_inst (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .valid_i(valid_out),
        .inputs_i(data_out),
        .result_o(result_o)
    );

endmodule