module FIFO_2x2 #(
    parameter DATA_WIDTH = 12  // Width of each stored data (for conv result)
)(
    input wire clk_i,
    input wire rstn_i,
    input wire wr_en_i,           // Write enable signal
    input wire rd_en_i,           // Read enable signal

    input wire [DATA_WIDTH-1:0] data_in [0:1],  // Data to be written (2 rows at a time)
    output reg [DATA_WIDTH-1:0] data_out [0:1][0:1], // Data to be read when FIFO is full
    output reg full_o,           // FIFO full flag
    output reg ready_o           // FIFO ready to send data flag
);
    // 2x2 FIFO memory
    reg [DATA_WIDTH-1:0] MEM [0:1][0:1]; // 2x2 FIFO memory

    reg wr_row_ptr, wr_col_ptr; // Write row and column pointers
    reg num_elements; // Number of elements in FIFO (updated to 2 bits)

    // Reset behavior and write logic
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            wr_row_ptr <= 0;
            wr_col_ptr <= 0;
            full_o <= 0;
            ready_o <= 0;
            num_elements <= 0;
        end else if (wr_en_i && !full_o) begin
            // Write 2 rows of data into MEM for the current column
            MEM[wr_row_ptr][wr_col_ptr] <= data_in[0];  // Store 1st row
            MEM[wr_row_ptr+1][wr_col_ptr] <= data_in[1];  // Store 2nd row

            // Move to the next column
            if (wr_col_ptr == 1) begin
                wr_col_ptr <= 0;
                wr_row_ptr <= wr_row_ptr + 1;  // Move to the next 2 rows
            end else begin
                wr_col_ptr <= wr_col_ptr + 1;
            end

            // Update the number of elements in the FIFO
            num_elements <= num_elements + 1;

            // Check if FIFO is full (2 data entries, since we are dealing with 2x2 FIFO)
            if (num_elements == 1) begin
                full_o <= 1;
                ready_o <= 1;  // FIFO is ready to send data
            end else begin
                full_o <= 0;
            end
        end
    end

    // Automatically output data when FIFO is full
    always @(posedge clk_i) begin
        if (full_o) begin
            // Output the entire 2x2 block
            data_out[0][0] <= MEM[0][0];  // First row, first column
            data_out[0][1] <= MEM[0][1];  // First row, second column
            data_out[1][0] <= MEM[1][0];  // Second row, first column
            data_out[1][1] <= MEM[1][1];  // Second row, second column
            MEM[0][0] <= 12'hzzz;
            MEM[0][1] <= 12'hzzz;
            MEM[1][0] <= 12'hzzz;
            MEM[1][1] <= 12'hzzz;
            ready_o <= 0;
        end
        else begin
            data_out[0][0] <= 12'hzzz;
            data_out[0][1] <= 12'hzzz;
            data_out[1][0] <= 12'hzzz;
            data_out[1][1] <= 12'hzzz;
        end
    end

endmodule
