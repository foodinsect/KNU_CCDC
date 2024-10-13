module Up_Counter(
    input wire clk_i,
    input wire rstn_i,
    output wire [11:0] counted,
    output wire overflow_o
    );

    reg [11:0] counter;
    reg overflow;

    assign counted = counter;
    assign overflow_o = overflow;

    always @(posedge clk_i) begin
        if (~rstn_i) begin
            counter <= 12'h000;
            overflow <= 1'b0;
        end
        else if (counter == 12'hFFF) begin
            counter <= 12'h000;   // Reset counter to 0 after reaching 0xFFF
            overflow <= 1'b1;     // Set overflow signal
        end
        else begin
            counter <= counter + 1;
            overflow <= 1'b0;     // Reset overflow signal
        end
    end
endmodule
