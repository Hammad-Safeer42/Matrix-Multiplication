module ram_mux(
    input logic [17:0] in_data_1,
    input logic [17:0] in_data_2,
    input logic [17:0] in_data_3,
    input logic [17:0] in_data_4,
    input logic [1:0] select,

    output logic [17:0] out_data
);
    always_comb begin

        case(select)
            2'b00 : out_data = in_data_1;
            2'b01 : out_data = in_data_2;
            2'b10 : out_data = in_data_3;
            default : out_data = in_data_4;
        endcase

    end

        


endmodule