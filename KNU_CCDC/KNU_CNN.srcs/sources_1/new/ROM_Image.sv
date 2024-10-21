`timescale 1ns / 1ps

module ROM_Image #(
    parameter IMAGE_FILE = "D:/Git_repo/KNU_CCDC/KNU_CNN.srcs/CNN_MNIST/0_01.txt"
) (
    input wire clk_i,
    input wire rstn_i,
    input wire image_rom_en,
    input wire [9:0] image_idx,
    input wire [5:0] cycle,
    output reg done,
    output reg [11:0] oDAT [0:5]
);

    // Declare Image arrays for each output
    reg [7:0] pixels [0:783];                  // 28x28 image data

    // Initial block to load weight files
    initial begin
        if (IMAGE_FILE != "") begin
            $readmemh(IMAGE_FILE, pixels);
        end else begin
            $error("IMAGE_FILE not specified.");
        end
    end
    
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            done <= 1'b0;
        end
        else begin
            integer i;
            // Valid signal 
            if (image_rom_en) begin
                for (i = 0; i < 6; i = i + 1) begin
                    oDAT[i] <= {4'h0, pixels[(i + cycle * 2) * 28 + image_idx]};  
                end

                for (i = 6; i < 12; i = i + 1) begin
                    oDAT[i] <= {4'h0, pixels[(i + (cycle * 2) - 6) * 28 + image_idx]};  
                end
            end

            if (cycle == 12) begin
                done <= 1'b1;
            end
        end
    end

endmodule
