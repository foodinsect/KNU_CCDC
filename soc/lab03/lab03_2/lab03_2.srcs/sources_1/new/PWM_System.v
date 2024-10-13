module PWM_System(
    input wire clk_i,
    input wire rstn_i,
    input wire wr_en_i,
    input wire strobe_i,
    input wire [31:0] addr_i,
    input wire [31:0] data_in_i,

    output wire oPWM0_o,
    output wire oPWM1_o,
    output wire ack0_o,
    output wire ack1_o,
    output wire [31:0] data_out0_o,
    output wire [31:0] data_out1_o
    );

    wire STB_PWM0;
    wire STB_PWM1;

    Decoder Address_Decoder(
        .addr_i(addr_i),
        .strobe_i(strobe_i),
        .STB_PWM0_o(STB_PWM0),
        .STB_PWM1_o(STB_PWM1)
    );

    PWM #(
        .reset_value(12'h800)
    ) PWM_2000 (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .wr_en_i(wr_en_i),
        .strobe_i(STB_PWM0),
        .addr_i(addr_i[3:0]),
        .data_in_i(data_in_i),

        .data_out_o(data_out0_o),
        .ack_o(ack0_o),
        .oPWM(oPWM0_o)
    );

    PWM #(
        .reset_value(12'h800)
    ) PWM_3000 (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .wr_en_i(wr_en_i),
        .strobe_i(STB_PWM1),
        .addr_i(addr_i[3:0]),
        .data_in_i(data_in_i),

        .data_out_o(data_out1_o),
        .ack_o(ack1_o),
        .oPWM(oPWM1_o)
    );
endmodule
