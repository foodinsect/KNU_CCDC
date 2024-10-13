module PWM #(
    parameter reset_value = 12'h000 
)(
    input wire clk_i,
    input wire rstn_i,
    input wire wr_en_i,
    input wire strobe_i,
    input wire [3:0] addr_i,
    input wire [31:0] data_in_i,

    output reg [31:0] data_out_o,
    output wire ack_o,
    output wire oPWM
    );

    assign ack_o = strobe_i;

    reg [11:0] duty_register;
    wire [11:0] counter;

    Up_Counter Up_Counter_12bit(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .counted(counter)
    );

    // writing
    always @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            duty_register <= reset_value;
        end
        else begin
            if (strobe_i & wr_en_i & (addr_i == 4'b0)) begin
                duty_register <= data_in_i[11:0];
            end
        end
    end

    // reading
    always @(*) begin
        if (strobe_i & ~wr_en_i & (addr_i == 4'b0)) begin
            data_out_o = {20'h00000, duty_register};
        end
        else begin
            data_out_o = 32'hxxxx_xxxx;
        end
    end

    assign oPWM = (counter < duty_register);

endmodule
