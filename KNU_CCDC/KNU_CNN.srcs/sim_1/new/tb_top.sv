`timescale 1ns / 1ps

module tb_top();

    reg [7:0] pixels [0:783];                  // 28x28 image data
    reg [11:0] data_in [0:5];                 // 12 rows of input data (each 12 bits)

    wire done;
    reg clk;
    reg rstn;
    reg start_i;

    // Instantiate PE Array module
    top TOP_inst (
        .clk_i(clk),
        .rstn_i(rstn),
        .start_i(start_i),
        .valid_o(),
        .full_o(),
        .empty_o(),
        .fifo_out(),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Read image text file
    initial begin
        clk <= 1'b0;;
        rstn <= 1'b1;
        start_i = 1'b0;
        #10 rstn <= 1'b0;
        #10 rstn <= 1'b1;
        #10 start_i = 1'b1;
        #10 start_i = 1'b0;
    end



    // Finish simulation when done is high
    always @(posedge clk) begin
        if (done) begin
            $finish;  // End the simulation
        end
    end

endmodule

