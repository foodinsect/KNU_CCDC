module global_controller(
    input wire          clk_i,
    input wire          rstn_i,
    input wire          start_i,
    input wire          iPE_valid_o,        // PE_valid_PEout_o 

    output reg          oacc_wr_en,
    output reg    [1:0] obuf_rd_mod,
    output reg          oPE_rstn,            //convlution phase 1 is done this value must be high
    output reg    [1:0] weight_sel,
    output reg    [1:0] bias_sel,
    output reg    [1:0] o_PE_mux_sel,       // 00: from out, 01:from buf1, 10:from buf2, 11:from buf3
    output reg          oBuf1_we,           // buffer1_we
    output reg          oBuf_adr_clr,       // buf1_adr_clr
    output reg          oBuf_valid_en,      // buf1_valid_en
    output reg          oPE_clr,            // PE_clr_o
    output reg          oPE_valid_i,        // PE_valid_PEin_o
    output reg          oimage_rom_en,      // rom_conv1_read
    output reg   [9:0]  oimage_idx,        // PEin_idx
    output reg   [5:0]  ocycle,              // cycle
    output reg          acc_rd_en,
    output reg          FIFO_valid,
    output reg          shift_en,
    output reg          conv_done
);

reg [4:0] current_state, next_state;

reg       idx_en;
reg       idx_clear;
reg       idx_clear_d1;
reg       oPE_clr_d1;
reg       buf_rd_mod_up;
reg       state12_cntEn;



always @(posedge clk_i) begin
    idx_clear <= idx_clear_d1;
    oPE_clr <= oPE_clr_d1;
end

always @(posedge clk_i) begin
    if(!rstn_i)begin
        obuf_rd_mod <= 2'b0;
    end
    else begin
        if(buf_rd_mod_up)begin
            obuf_rd_mod <= obuf_rd_mod + 2'b1;
        end
    end
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

always @(posedge clk_i) begin
    if (!rstn_i) begin
        shift_en <= 1'b0;
    end
    else begin
        if(state12_cntEn)begin
            if (oimage_idx > 10'd2)begin
                shift_en <= 1'b1;
            end
            else begin
                shift_en <= 1'b0;
            end
        end
        else begin
            shift_en <= 1'b0;
        end
    end
end

always @(*) begin
    case (current_state)
    5'd0:begin
        oacc_wr_en = 1'b0;
        buf_rd_mod_up = 1'b0;
        oPE_rstn = 1'b0;
        weight_sel = 2'b00;
        bias_sel = 2'b00;
        o_PE_mux_sel = 2'b00;
        oBuf1_we = 1'b1;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b0;
        idx_en = 1'b0;
        idx_clear_d1 = 1'b0;
        ocycle = 6'd0;
        acc_rd_en = 1'b0;
        FIFO_valid = 1'b0;
        state12_cntEn = 1'b0;
        conv_done = 1'b0;
    end 
    5'd1:begin
        oacc_wr_en = 1'b0;
        buf_rd_mod_up = 1'b0;
        oPE_rstn = 1'b0;
        weight_sel = 2'b00;
        bias_sel = 2'b00;
        o_PE_mux_sel = 2'b00;
        oBuf1_we = 1'b1;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b0;      
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b1;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b0;
        acc_rd_en = 1'b0;
        FIFO_valid = 1'b0;
        state12_cntEn = 1'b0;
        conv_done = 1'b0;
    end
    5'd2:begin
        oacc_wr_en = 1'b0;
        buf_rd_mod_up = 1'b0;
        oPE_rstn = 1'b0;
        weight_sel = 2'b00;
        bias_sel = 2'b00;
        o_PE_mux_sel = 2'b00;
        oBuf1_we = 1'b1;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b1;
        oimage_rom_en = 1'b1;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b0;
        acc_rd_en = 1'b0;
        FIFO_valid = 1'b0;
        state12_cntEn = 1'b0;
        conv_done = 1'b0;
    end
    5'd3:begin
        oacc_wr_en = 1'b0;
        buf_rd_mod_up = 1'b0;
        oPE_rstn = 1'b0;
        weight_sel = 2'b00;
        bias_sel = 2'b00;
        o_PE_mux_sel = 2'b00;
        oBuf1_we = 1'b1;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b1;
        oPE_valid_i = 1'b1;
        oimage_rom_en = 1'b1;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b1;
        ocycle = ocycle + 1;
        acc_rd_en = 1'b0;
        FIFO_valid = 1'b0;
        state12_cntEn = 1'b0;
        conv_done = 1'b0;
    end
    5'd4:begin // conv1 finish 
        oacc_wr_en = 1'b0;
        buf_rd_mod_up = 1'b0;
        oPE_rstn = 1'b0;
        weight_sel = 2'b00;
        bias_sel = 2'b00;
        o_PE_mux_sel = 2'b00;
        oBuf1_we = 1'b1;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b0;
        idx_en = 1'b0;
        idx_clear_d1 = 1'b0;
        ocycle = 0;        
        acc_rd_en = 1'b0;
        FIFO_valid = 1'b0;
        state12_cntEn = 1'b0;
        conv_done = 1'b0;
    end
    5'd5:begin
        // waiting for filling buffer1 complete
        oacc_wr_en = 1'b0;
        buf_rd_mod_up = 1'b0;
        oPE_rstn = 1'b0;
        weight_sel = 2'b00;
        bias_sel = 2'b00;
        o_PE_mux_sel = 2'b00;
        oBuf1_we = 1'b1;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b0;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b0;
        ocycle = 0;   
        acc_rd_en = 1'b0;
        FIFO_valid = 1'b0;
        state12_cntEn = 1'b0;
        conv_done = 1'b0;
    end
    5'd6:begin
        oacc_wr_en = 1'b0;
        buf_rd_mod_up = 1'b0;
        oPE_rstn = 1'b0;
        weight_sel = 2'b00;
        bias_sel = 2'b00;
        o_PE_mux_sel = 2'b00;
        oBuf1_we = 1'b0;
        oBuf_valid_en = 1'b0;
        oBuf_adr_clr = 1'b1;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b0;
        idx_en = 1'b0;
        idx_clear_d1 = 1'b1;
        ocycle = 0;     
        acc_rd_en = 1'b0;
        FIFO_valid = 1'b0;
        state12_cntEn = 1'b0;
        conv_done = 1'b0;
    end
    5'd7:begin
        oacc_wr_en = 1'b0;
        buf_rd_mod_up = 1'b0;
        oPE_rstn = 1'b1; 
        weight_sel = weight_sel + 2'd1;
        bias_sel = 2'b10;
        o_PE_mux_sel = o_PE_mux_sel + 2'd1;
        oBuf1_we = 1'b0;
        oBuf_valid_en = 1'b0; 
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b0;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b0;
        ocycle = ocycle;     
        acc_rd_en = 1'b0;
        FIFO_valid = 1'b0;
        state12_cntEn = 1'b0;
        conv_done = 1'b0;
    end
    5'd8:begin
        oacc_wr_en = 1'b1;
        buf_rd_mod_up = 1'b0;
        oPE_rstn = 1'b0;
        weight_sel = weight_sel;
        bias_sel = 2'b10;
        o_PE_mux_sel = o_PE_mux_sel;
        oBuf1_we = 1'b0;
        oBuf_valid_en = 1'b1; 
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b1;
        oimage_rom_en = 1'b0;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b0;
        ocycle = ocycle;   
        acc_rd_en = 1'b0;
        FIFO_valid = 1'b0;
        state12_cntEn = 1'b0;
        conv_done = 1'b0;
    end
    5'd9:begin // PE CLEAR
        oacc_wr_en = 1'b1;
        buf_rd_mod_up = 1'b1;
        oPE_rstn = 1'b0;
        weight_sel = weight_sel;
        bias_sel = 2'b10;
        o_PE_mux_sel = o_PE_mux_sel;
        oBuf1_we = 1'b0;
        oBuf_valid_en = 1'b1; 
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b1;
        oPE_valid_i = 1'b1;
        oimage_rom_en = 1'b0;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b1;
        ocycle = ocycle;   
        acc_rd_en = 1'b0; 
        FIFO_valid = 1'b0;
        state12_cntEn = 1'b0;
        conv_done = 1'b0;
    end

    5'd10:begin 
        oacc_wr_en = 1'b1;
        buf_rd_mod_up = 1'b0;
        oPE_rstn = 1'b0;
        weight_sel = weight_sel;
        bias_sel = 2'b10;
        o_PE_mux_sel = o_PE_mux_sel;
        oBuf1_we = 1'b0;
        oBuf_valid_en = 1'b0; 
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b1;
        oimage_rom_en = 1'b0;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b0;
        ocycle = ocycle; 
        acc_rd_en = 1'b0;   
        FIFO_valid = 1'b0;
        state12_cntEn = 1'b0;
        conv_done = 1'b0;
    end
    5'd11:begin
        oacc_wr_en = 1'b0;
        buf_rd_mod_up = 1'b0;
        oPE_rstn = 1'b1;
        weight_sel = weight_sel;
        bias_sel = 2'b10;
        o_PE_mux_sel = o_PE_mux_sel;
        oBuf1_we = 1'b0;
        oBuf_valid_en = 1'b0; 
        oBuf_adr_clr = 1'b1;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b0;
        idx_en = 1'b0;
        idx_clear_d1 = 1'b1;
        ocycle = ocycle + 1;  
        acc_rd_en = 1'b0;
        FIFO_valid = 1'b0;
        state12_cntEn = 1'b0;
        conv_done = 1'b0;
    end
    5'd12:begin
        oacc_wr_en = 1'b0;
        buf_rd_mod_up = 1'b0;
        oPE_rstn = 1'b0;
        weight_sel = weight_sel;
        bias_sel = 2'b10;
        o_PE_mux_sel = o_PE_mux_sel;
        oBuf1_we = 1'b0;
        oBuf_valid_en = 1'b0; 
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b0;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b0;
        ocycle = ocycle;  
        acc_rd_en = 1'b1;
        FIFO_valid = 1'b1;
        state12_cntEn = 1'b1;
        conv_done = 1'b0;
    end
    5'd13:begin
        oacc_wr_en = 1'b0;
        buf_rd_mod_up = 1'b0;
        oPE_rstn = 1'b0;
        weight_sel = weight_sel;
        bias_sel = 2'b10;
        o_PE_mux_sel = o_PE_mux_sel;
        oBuf1_we = 1'b0;
        oBuf_valid_en = 1'b0; 
        oBuf_adr_clr = 1'b0;
        oPE_clr_d1 = 1'b0;
        oPE_valid_i = 1'b0;
        oimage_rom_en = 1'b0;
        idx_en = 1'b0;
        idx_clear_d1 = 1'b1;
        ocycle = ocycle;  
        acc_rd_en = 1'b0;
        FIFO_valid = 1'b0;
        state12_cntEn = 1'b0;
        conv_done = 1'b1;
    end


    endcase
end



always @(*) begin
    case (current_state)
    5'd0: if(start_i) next_state = 5'd1; else next_state = 5'd0;
    5'd1: next_state = 5'd2;
    5'd2: if(oimage_idx == 10'd27) next_state = 5'd3; else next_state = 5'd2;
    5'd3: if(ocycle == 12) next_state = 5'd4; else next_state = 5'd2;
    5'd4: next_state = 5'd5;
    5'd5: if(oimage_idx == 10'd3) next_state = 5'd6; else next_state = 5'd5;
    5'd6: next_state = 5'd7;
    5'd7: next_state = 5'd8;
    5'd8: if(oimage_idx == 10'd11) next_state = 5'd9; else next_state = 5'd8;
    5'd9: if(obuf_rd_mod != 3) next_state = 5'd8; else next_state = 5'd10;
    5'd10:if(oimage_idx == 10'd1) next_state = 5'd11; else next_state = 5'd10;
    5'd11:if(ocycle != 3)next_state = 5'd7;else next_state = 5'd12;
    5'd12:if(oimage_idx == 10'd66) next_state = 5'd13; else next_state = 5'd12;
    default:;
    endcase
end
    
endmodule