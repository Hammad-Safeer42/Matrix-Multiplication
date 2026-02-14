module read_asmd(

    input logic clk,
    input logic rst_n,
    input logic [4:0] in_addr,
    input logic read_en,

    output logic sel_upper,
    output logic read_new,
    output logic [8:0] read_addr

);

    typedef enum {idle, first_half, second_half} state_type;

    logic [4:0] base_addr;
    logic [3:0] counter; 

    state_type current_state, next_state;

    // // Update State Machine
    // always_ff @(posedge clk) begin
    //     if (!rst_n) begin
    //         current_state <= idle;
    //     end else begin	
    //         current_state <= next_state;
    //     end
    // end

    // // next state logic
    // always_comb begin
    //     next_state = current_state;
    //     case(current_state)
    //         idle: begin
    //             if(read_en == 1) begin
    //                 next_state = first_half;
    //             end
    //         end
    //         first_half: begin
    //             next_state = second_half;
    //         end
    //         second_half: begin
    //             next_state = first_half;
    //             if(counter == 15) begin
    //                 next_state = idle;
    //             end
    //         end  
    //     endcase
    // end

    // output logic
    assign read_addr = {base_addr,counter};
    always_comb begin
        read_new = 0; 
        sel_upper = 0;       
        case(current_state)
            idle: begin
                if(read_en == 1) begin
                    read_new = 1;
                end
            end
            first_half: begin
                // sel_upper = 0 and read_new = 0 are set by default
            end
            second_half: begin

                read_new = 1;
                sel_upper = 1;

                if(counter == 15) begin
                    read_new = 0;
                end
            end  
        endcase
    end


    // // update internal counters etc.
    // always_ff @(posedge clk) begin
    //     if(!rst_n) begin
    //         base_addr <= 0;
    //         counter <= 0;
    //     end
    //     if((current_state == idle) && read_en) begin
    //         base_addr <= in_addr;
    //     end
    //     if(current_state == second_half) begin
    //         counter <= counter + 1;
    //     end
    // end

endmodule