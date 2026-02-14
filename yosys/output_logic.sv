module output_logic(
    input logic clk,
    input logic rst_n,
    input logic [31:0] in_data,
    input logic sel_upper,

    output logic [8:0] out_data
);

    logic [8:0] output_buffer;


    // select lower or upper half of the output
    always_comb begin
        if(sel_upper) begin
            out_data = output_buffer;
        end
        else begin
            out_data = in_data[8:0];
        end
    end

    // load new data into buffer
    always_ff @(posedge clk) begin
        if(!rst_n) begin
            output_buffer <= 0;
        end
        else begin
            output_buffer <= in_data[17:9];
        end
    end

endmodule