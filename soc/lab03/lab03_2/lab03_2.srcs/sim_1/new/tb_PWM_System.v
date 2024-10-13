`timescale 1ns / 1ps

module tb_PWM_System();

    reg clk;
    reg rstn;
    reg wr_en;
    reg strobe;
    reg [31:0] addr;
    reg [31:0] data_in;
    
    wire oPWM0;
    wire oPWM1;
    wire ack0;
    wire ack1;
    wire [31:0] data_out0;
    wire [31:0] data_out1;

    PWM_System pwm_inst (
        .clk_i(clk),
        .rstn_i(rstn),
        .wr_en_i(wr_en),
        .strobe_i(strobe),
        .addr_i(addr),
        .data_in_i(data_in),
        .oPWM0_o(oPWM0),
        .oPWM1_o(oPWM1),
        .ack0_o(ack0),
        .ack1_o(ack1),
        .data_out0_o(data_out0),
        .data_out1_o(data_out1)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

        ////////////////////////////RESET///////////////////////////
    initial begin
        rstn = 1;

        #10
        rstn = 0;
        wr_en = 0;
        strobe = 0;
        addr = 32'h0000_0000;
        data_in = 32'h0000_0000;

        #10 rstn = 1;

        ////////////////////////////PWM_2000 read, write test ///////////////////////////
        addr = 32'h0200_2000;
        data_in = 32'h0000_0000;
        wr_en = 0;
        strobe = 0;

        #20
        addr = 32'h0200_2000;
        data_in = 32'h0000_0400;
        wr_en = 1;
        strobe = 1;

        #20
        addr = 32'h0200_2000;
        data_in = 32'h0000_0400;
        wr_en = 0;
        strobe = 1;

        #20
        addr = 32'h0200_2000;
        data_in = 32'h0000_0400;
        wr_en = 0;
        strobe = 0;
        
         ////////////////////////////PWM_2000 oPWM test ///////////////////////////
        
        #500000
        addr = 32'h0200_2000;
        data_in = 32'h0000_0000;
        wr_en = 1;
        strobe = 1;
        #20 strobe = 0; wr_en = 0; 

        #500000 
        addr = 32'h0200_2000;
        data_in = 32'h0000_0400;
        wr_en = 1;
        strobe = 1;
        #20 strobe = 0; wr_en = 0;

        #500000
        addr = 32'h0200_2000;
        data_in = 32'h0000_0800; 
        wr_en = 1;
        strobe = 1;
        #20 strobe = 0; wr_en = 0; 

        #500000
        addr = 32'h0200_2000;
        data_in = 32'h0000_0C00; 
        wr_en = 1;
        strobe = 1;
        #20 strobe = 0; wr_en = 0;

        #500000
        addr = 32'h0200_2000;
        data_in = 32'h0000_0FFF;
        wr_en = 1;
        strobe = 1;
        #20 strobe = 0; wr_en = 0;
        
        #500000
        addr = 32'h0200_2000;
        data_in = 32'h0000_0000;
        wr_en = 1;
        strobe = 1;
        #20 strobe = 0; wr_en = 0;
        
        //////////////////////////// PWM_3000 oPWM test  ///////////////////////////
        
        #500000
        addr = 32'h0200_3000;
        data_in = 32'h0000_0000;
        wr_en = 1;
        strobe = 1;
        #20 strobe = 0; wr_en = 0; 

        #500000 
        addr = 32'h0200_3000;
        data_in = 32'h0000_0400;
        wr_en = 1;
        strobe = 1;
        #20 strobe = 0; wr_en = 0;

        #500000
        addr = 32'h0200_3000;
        data_in = 32'h0000_0800; 
        wr_en = 1;
        strobe = 1;
        #20 strobe = 0; wr_en = 0; 

        #500000
        addr = 32'h0200_3000;
        data_in = 32'h0000_0C00; 
        wr_en = 1;
        strobe = 1;
        #20 strobe = 0; wr_en = 0;

        #500000
        addr = 32'h0200_3000;
        data_in = 32'h0000_0FFF;
        wr_en = 1;
        strobe = 1;
        #20 strobe = 0; wr_en = 0;
        
        #500000
        addr = 32'h0200_3000;
        data_in = 32'h0000_0000;
        wr_en = 1;
        strobe = 1;
        #20 strobe = 0; wr_en = 0;
        $finish;
    end
endmodule
