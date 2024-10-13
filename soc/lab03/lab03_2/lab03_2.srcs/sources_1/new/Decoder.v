module Decoder(
    input wire [31:0] addr_i,
    input wire strobe_i,
    output wire STB_PWM0_o,
    output wire STB_PWM1_o
    );

    assign STB_PWM0_o = (strobe_i & (addr_i[31:0] & 32'hFFFF_FFF0) == 32'h0200_2000);
    assign STB_PWM1_o = (strobe_i & (addr_i[31:0] & 32'hFFFF_FFF0) == 32'h0200_3000);
endmodule