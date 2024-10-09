module rom_8bit_25 (
    input logic enable,                  
    output logic [7:0] data_out [0:24]   
);

    logic [7:0] rom_data [0:24] = '{8'hA1, 8'hB2, 8'hC3, 8'hD4, 8'hE5, 8'hF6, 8'h07, 
                                   8'h18, 8'h29, 8'h3A, 8'h4B, 8'h5C, 8'h6D, 8'h7E, 
                                   8'h8F, 8'h90, 8'hA1, 8'hB2, 8'hC3, 8'hD4, 8'hE5, 
                                   8'hF6, 8'h07, 8'h18, 8'h29};

    int i;

    always_comb begin
        if (enable) begin
            for (i = 0; i < 25; i++) begin
                data_out[i] = rom_data[i];
            end
        end else begin
            for (i = 0; i < 25; i++) begin
                data_out[i] = 8'hxx;
            end
        end
    end

endmodule