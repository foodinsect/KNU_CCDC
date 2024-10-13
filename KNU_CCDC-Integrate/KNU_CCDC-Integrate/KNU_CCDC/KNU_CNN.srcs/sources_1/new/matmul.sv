module matmul( //2024.10.13 update
    input wire clk_i,
    input wire rstn_i,
    input wire clear_i,
    input wire en_i,
    input wire signed [11:0] flatten_i,
    input wire signed [7:0] weight_i [9:0],
    input wire signed [7:0] bias_i [9:0],

    output wire valid_out_o,
    output wire signed [11:0] data_out_o [9:0]
);

    wire mac_valid;
    reg total_valid;
    reg [5:0] cycle_counter; // 48 cycles count

    assign valid_out_o = total_valid;
    
    always @(posedge clk_i) begin
        total_valid <= mac_valid;
    end

    always @(posedge clk_i) begin
        if (~rstn_i) begin
            total_valid <= 0;
            cycle_counter <= 0;
        end
        else begin
            if (clear_i) begin
                total_valid <= 0;
                cycle_counter <= 0;
            end
            else if (mac_valid) begin
                if (cycle_counter == 47) begin
                    total_valid <= 1;
                    cycle_counter <= 0;
                end 
                else begin
                    cycle_counter <= cycle_counter + 1;
                end
            end
        end
    end

    wire signed [19:0] mac_outputs [9:0];
    reg signed [19:0] sum_outputs [9:0];
    wire signed [19:0] final_outputs [9:0];

    generate
        genvar i;
        for (i = 0; i < 10; i = i + 1) begin : mac_inst
            MAC MAC_inst(
                .clk_i(clk_i),
                .rstn_i(rstn_i),
                .clr_i(clear_i),
                .mac_en_i(en_i),
                .weight_i(weight_i[i]),
                .input_i(flatten_i),
                .mac_out_o(mac_outputs[i]),
                .valid_out_o(mac_valid)
            );

            always @(posedge clk_i) begin
                if (~rstn_i | clear_i) begin
                    sum_outputs[i] <= 0;
                end 
                else begin
                    if (mac_valid) begin
                       sum_outputs[i] <= sum_outputs[i] + mac_outputs[i];
                    end
                end
            end

            assign final_outputs[i] = (total_valid) ? sum_outputs[i] + bias_i[i] : 20'hx;
            assign data_out_o[i] = final_outputs[i][19:8];
        end
    endgenerate

endmodule