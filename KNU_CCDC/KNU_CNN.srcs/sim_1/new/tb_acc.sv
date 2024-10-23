`timescale 1ns / 1ps

module tb_acc;
    // Inputs to DUT (Device Under Test)
    reg clk_i;
    reg rstn_i;
    reg valid_i;
    reg signed [11:0] conv_in [0:1];
    reg rd_en_i;   // Read enable signal to read output sequentially

    // Outputs from DUT
    wire signed [11:0] conv_sum [0:1];
    wire done;

    // Instantiate the DUT
    Accumulator dut (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .valid_i(valid_i),
        .conv_in(conv_in),
        .conv_sum(conv_sum),
        .done(done),
        .rd_en_i(rd_en_i)  // Connect the read enable input
    );

    // Clock generation: 10ns period, 50% duty cycle
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end

    // Initial reset and setup
    initial begin
        rstn_i = 0;
        valid_i = 0;
        conv_in[0] = 0;
        conv_in[1] = 0;
        rd_en_i = 0;

        #15 rstn_i = 1;  // Release reset after 15ns
    end

    // Test phases for sending input values
    integer count = 0;
    reg [1:0] phase = 0; // Phase indicator: 0, 1, 2

    // Sending values in each phase using an always block
    always @(posedge clk_i) begin
        if (rstn_i) begin
            case (phase)
                2'd0: begin
                    valid_i <= 1; // Enable valid for phase 1
                    conv_in[0] <= conv_in[0] + 1;  // Increment value for channel 0
                    conv_in[1] <= conv_in[1] + 2;  // Increment value for channel 1
                    count <= count + 1;
                    
                    if (count == 32) begin
                        valid_i <= 0;   // Disable valid between phases
                        phase <= 1;     // Move to phase 2
                        count <= 0;     // Reset count for next phase
                        #50;            // Wait for 50ns between phases
                    end
                end
                
                2'd1: begin
                    valid_i <= 1; // Enable valid for phase 2
                    conv_in[0] <= conv_in[0] + 1;
                    conv_in[1] <= conv_in[1] + 2;
                    count <= count + 1;

                    if (count == 32) begin
                        valid_i <= 0;   // Disable valid between phases
                        phase <= 2;     // Move to phase 3
                        count <= 0;     // Reset count for next phase
                        #50;            // Wait for 50ns between phases
                    end
                end
                
                2'd2: begin
                    valid_i <= 1; // Enable valid for phase 3
                    conv_in[0] <= conv_in[0] + 1;
                    conv_in[1] <= conv_in[1] + 2;
                    count <= count + 1;

                    if (count == 32) begin
                        valid_i <= 0;   // Disable valid after last phase
                        count <= 0;
                        phase <= 3;     // Indicate end of phases
                    end
                end
            endcase
        end
    end

    // Checking the done signal and enabling rd_en
    always @(posedge clk_i) begin
        if (done) begin
            rd_en_i <= 1'b1;  // Activate read enable when done signal is high
            $display("Done signal activated, starting read sequence.");
        end
        else if (rd_en_i) begin
            // Display read output values for verification
            $display("Read conv_sum[0] = %0d, conv_sum[1] = %0d", conv_sum[0], conv_sum[1]);
        end
    end

    // Finish simulation after read sequence
    initial begin
        wait (done);            // Wait until done signal is asserted
        #10 rd_en_i <= 1'b1;    // Enable reading after done signal
        #640 rd_en_i <= 1'b0;   // Finish reading all 64 values (assuming 64 * 10ns = 640ns)
        $display("Reading sequence completed.");
        #10 $finish;            // End the simulation
    end
endmodule
