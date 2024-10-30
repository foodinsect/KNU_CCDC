module fc_bias_ROM #(
    parameter BIAS_FILE = ""
)(  
    input wire clk_i,
    input wire bias_rom_en,
    input wire [3:0] bias_idx,

    output reg [7:0] oDAT [0:9]
    );

    reg [7:0] bias [0:9];

    initial begin
        if (BIAS_FILE != "") begin
            $readmemh(BIAS_FILE, bias);
        end
        else begin
            $error("IMAGE_FILE not specified.");
        end
    end

    always @(posedge clk_i) begin
        integer i;
        if (bias_rom_en) begin
            for (i = 0; i < 10; i = i + 1) begin
                oDAT[i] <= bias[i];
            end
        end
    end
endmodule