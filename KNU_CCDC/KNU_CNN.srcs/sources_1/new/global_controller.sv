module global_controller(
    input wire          clk_i,
    input wire          rstn_i,
    input wire          start_i,

    input wire          PE_valid_PEout_o,
    output reg          buffer1_we,
    output reg          buf1_adr_clr,          
    output reg          buf1_valid_en,
    output reg          PE_clr_o,
    output reg          PE_valid_PEin_o,
    output reg          rom_conv1_read,
    output reg   [9:0]  PEin_idx,
    output reg   [5:0]  cycle
);

reg [3:0] current_state, next_state;
reg       idx_en;
reg       idx_clear;
reg       idx_clear_d1;
reg       PE_clr_o_d1;

always @(posedge clk_i) begin
    idx_clear <= idx_clear_d1;
    PE_clr_o <= PE_clr_o_d1;
end


always @(posedge clk_i) begin
    if (!rstn_i) current_state <= 4'd0;
    else current_state <= next_state;
end

always @(posedge clk_i) begin
    if (!rstn_i | idx_clear_d1) begin
        PEin_idx <= 10'd0;
    end
    else begin
        if(idx_en) begin
            PEin_idx <= PEin_idx + 1;
        end
    end
end

always @(*) begin
    case (current_state)
    4'd0:begin
        buffer1_we = 1'b1;
        buf1_valid_en = 1'b0;
        buf1_adr_clr = 1'b0;
        PE_clr_o_d1 = 1'b0;
        PE_valid_PEin_o = 1'b0;
        rom_conv1_read = 1'b0;
        idx_en = 1'b0;
        idx_clear_d1 = 1'b0;
        cycle = 6'd0;
    end 
    4'd1:begin
        buffer1_we = 1'b1;
        buf1_valid_en = 1'b0;
        buf1_adr_clr = 1'b0;      
        PE_clr_o_d1 = 1'b0;
        PE_valid_PEin_o = 1'b0;
        rom_conv1_read = 1'b1;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b0;
    end
    4'd2:begin
        buffer1_we = 1'b1;
        buf1_valid_en = 1'b0;
        buf1_adr_clr = 1'b0;
        PE_clr_o_d1 = 1'b0;
        PE_valid_PEin_o = 1'b1;
        rom_conv1_read = 1'b1;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b0;
    end
    4'd3:begin
        buffer1_we = 1'b1;
        buf1_valid_en = 1'b0;
        buf1_adr_clr = 1'b0;
        PE_clr_o_d1 = 1'b1;
        PE_valid_PEin_o = 1'b1;
        rom_conv1_read = 1'b1;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b1;
        cycle = cycle + 1;
    end
    4'd4:begin // conv1 finish 
        buffer1_we = 1'b1;
        buf1_valid_en = 1'b0;
        buf1_adr_clr = 1'b0;
        PE_clr_o_d1 = 1'b0;
        PE_valid_PEin_o = 1'b0;
        rom_conv1_read = 1'b0;
        idx_en = 1'b0;
        idx_clear_d1 = 1'b0;
        cycle = 0;        
    end
    4'd5:begin
        // waiting for filling buffer1 complete
        buffer1_we = 1'b1;
        buf1_valid_en = 1'b0;
        buf1_adr_clr = 1'b0;
        PE_clr_o_d1 = 1'b0;
        PE_valid_PEin_o = 1'b0;
        rom_conv1_read = 1'b0;
        idx_en = 1'b1;
        idx_clear_d1 = 1'b0;
        cycle = 0;   
    end
    4'd6:begin
        buffer1_we = 1'b0;
        buf1_valid_en = 1'b0;
        buf1_adr_clr = 1'b1;
        PE_clr_o_d1 = 1'b0;
        PE_valid_PEin_o = 1'b0;
        rom_conv1_read = 1'b0;
        idx_en = 1'b0;
        idx_clear_d1 = 1'b1;
        cycle = 0;     
    end
    4'd7:begin
        buffer1_we = 1'b0;
        buf1_valid_en = 1'b1;
        buf1_adr_clr = 1'b0;
        PE_clr_o_d1 = 1'b0;
        PE_valid_PEin_o = 1'b0;
        rom_conv1_read = 1'b0;
        idx_en = 1'b0;
        idx_clear_d1 = 1'b0;
        cycle = 0;     
    end
    endcase
end



always @(*) begin
    case (current_state)
    4'd0: if(start_i) next_state = 4'd1; else next_state = 4'd0;
    4'd1: next_state = 4'd2;
    4'd2: if(PEin_idx == 10'd27) next_state = 4'd3; else next_state = 4'd2;
    4'd3: if(cycle == 12) next_state = 4'd4; else next_state = 4'd2;
    4'd4: next_state = 4'd5;
    4'd5: if(PEin_idx == 10'd3) next_state = 4'd6; else next_state = 4'd5;
    4'd6: next_state = 4'd7;
    default:;
    endcase
end
    
endmodule