module max_finder ( //2024.10.13 update
    input wire clk_i,
    input wire rstn_i,
    input wire valid_i,
    input wire signed [11:0] inputs_i [0:9],
    output reg [3:0] result_o
);

    reg signed [11:0] max_value;
    reg [3:0] max_index;
    integer i;

    always @(posedge clk_i) begin
        if (!rstn_i) begin
            max_value <= -12'sd2048;
            max_index <= 4'd0;
            result_o <= 4'd0;
        end 
        else if (valid_i) begin
            max_value = inputs_i[0];
            max_index = 4'd0;
            
            for (i = 1; i < 10; i = i + 1) begin
                if (inputs_i[i] > max_value) begin
                    max_value = inputs_i[i];
                    max_index = i;
                end
            end
            
            result_o <= max_index;
        end
    end

endmodule