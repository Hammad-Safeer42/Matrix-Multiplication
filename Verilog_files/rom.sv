module rom(
    input logic [3:0] in_addr,
    input logic sel_upper,

    output logic [6:0] out_data

);

    logic [13:0] sel_word;


    always_comb begin
        case(in_addr)
            0: sel_word = 14'b00000110010110;
            1: sel_word = 14'b11110011111111;
            2: sel_word = 14'b00010000000011;
            3: sel_word = 14'b00000010000010;
            4: sel_word = 14'b00010001111101;
            5: sel_word = 14'b00000100000100;
            6: sel_word = 14'b11110000000110;
            7: sel_word = 14'b00000010000010;
            8: sel_word = 14'b00100100101000;
            9: sel_word = 14'b00000110000010;
            10: sel_word = 14'b00100000001001;
            11: sel_word = 14'b00000010000010;
            12: sel_word = 14'b00000010001010;
            13: sel_word = 14'b00001000000000;
            14: sel_word = 14'b00000100001100;
            default: sel_word = 14'b00000010000010;

        endcase 

        if(~sel_upper) begin // inverted, because the rom data is ordered left to right :(
            out_data = sel_word[13:7];
        end else begin
            out_data = sel_word[6:0];
        end
    end


endmodule