module global_controller(
    input wire          clk_i,
    input wire          rstn_i,
    input wire          start_i,
    input wire          iPE_valid_o,        // PE_valid_PEout_o 

    output reg          oBuf1_we,           // buffer1_we
    output reg          oBuf_adr_clr,       // buf1_adr_clr
    output reg          oBuf_valid_en,      // buf1_valid_en
    output reg          oPE_clr,            // PE_clr_o
    output reg          oPE_valid_i,        // PE_valid_PEin_o
    output reg          oimage_rom_en,      // rom_conv1_read
    output reg   [9:0]  oimage_idx,         // PEin_idx
    output reg   [5:0]  ocycle              // cycle
);

reg [3:0] current_state, next_state;
reg       idx_en;
reg       idx_clear;
reg       idx_clear_d1;
reg       oPE_clr_d1;

always @(posedge clk_i) begin
    idx_clear <= idx_clear_d1;
    oPE_clr <= oPE_clr_d1;
end


always @(posedge clk_i) begin
    if (!rstn_i) current_state <= 4'd0;
    else current_state <= next_state;
end

always @(posedge clk_i) begin
    if (!rstn_i | idx_clear_d1) begin
        oimage_idx <= 10'd0;
    end
    else begin
        if(idx_en) begin
            oimage_idx <= oimage_idx + 1;
        end
    end
end

always @(*) begin
    case (current_state)
    4'd0:begin
        oBuf1_we = 1'b1;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b0;
        idx_en = 1'b0;
        idx_clear_d1 = 1'b0;
        ocycle = 6'd0;
    end 
    4'd1:begin
        oBuf1_we = 1'b1;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b0;      
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b1;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b0;
    end
    4'd2:begin
        oBuf1_we = 1'b1;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b1;
        oimage_rom_en = 1'b1;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b0;
    end
    4'd3:begin
        oBuf1_we = 1'b1;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b1;
        oPE_valid_i = 1'b1;
        oimage_rom_en = 1'b1;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b1;
        ocycle = ocycle + 1;
    end
    4'd4:begin // conv1 finish 
        oBuf1_we = 1'b1;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b0;
        idx_en = 1'b0;
        idx_clear_d1 = 1'b0;
        ocycle = 0;        
    end
    4'd5:begin
        // waiting for filling buffer1 complete
        oBuf1_we = 1'b1;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b0;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b0;
        ocycle = 0;   
    end
    4'd6:begin
        oBuf1_we = 1'b0;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b1;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b0;
        idx_en = 1'b0;
        idx_clear_d1 = 1'b1;
        ocycle = 0;     
    end
    4'd7:begin
        oBuf1_we = 1'b0;
        oBuf_valid_en = 1'b1;
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b0;
        idx_en = 1'b0;
        idx_clear_d1 = 1'b0;
        ocycle = 0;     
    end
    endcase
end



always @(*) begin
    case (current_state)
    4'd0: if(start_i) next_state = 4'd1; else next_state = 4'd0;
    4'd1: next_state = 4'd2;
    4'd2: if(oimage_idx == 10'd27) next_state = 4'd3; else next_state = 4'd2;
    4'd3: if(ocycle == 12) next_state = 4'd4; else next_state = 4'd2;
    4'd4: next_state = 4'd5;
    4'd5: if(oimage_idx == 10'd3) next_state = 4'd6; else next_state = 4'd5;
    4'd6: next_state = 4'd7;
    default:;
    endcase
end
    
endmodule