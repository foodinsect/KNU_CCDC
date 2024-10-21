module comparator(
    input wire signed [11:0] data_in_i [1:0],
    output reg signed [11:0] data_out_o
);

    always @(*) begin
        if (data_in_i[1] >= data_in_i[0]) begin
            data_out_o = data_in_i[1];
        end
        else begin
            data_out_o = data_in_i[0];
        end
    end

endmodule