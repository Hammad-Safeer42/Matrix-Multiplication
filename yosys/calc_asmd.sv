module calc_asmd(
    input logic clk,
    input logic rst_n,

    input logic start,
    input logic read,
    input logic [4:0] in_addr,

    output logic finish,

    output logic mac_en,
    output logic mac_rst_n,

    output logic [4:0] to_ireg_read_addr_1,
    output logic [4:0] to_ireg_read_addr_2,
    output logic [4:0] to_ireg_read_addr_3,
    output logic [4:0] to_ireg_read_addr_4,

    output logic [4:0] to_ireg_write_addr,
    output logic to_ireg_write_en,

    output logic [3:0] to_rom_read_addr, // only range(16) because of two values per addres
    output logic to_rom_sel_second,

    // Logic for writing to the RAM;
    output logic [8:0] to_ram_addr,
    output logic to_ram_write_en,
    
    output logic [1:0] to_mux_select,

    output logic sel_upper

);
    typedef enum {idle, input_data, calc_collumn, write_collumn, read_first, read_second} state_type;

    state_type current_state, next_state;
    
    logic [4:0] ram_base_addr,ram_base_addr_next;  //Stores the base addr of the ram_slot to which data is written
    logic [4:0] input_counter,input_counter_next;  // used for input of data

    logic [2:0] calc_col_counter,calc_col_counter_next; // counts the step (during calculation of a collumn) the accellerator is working on
    logic [4:0] ireg_read_counter,ireg_read_counter_next; // keeps track of which input values have to be read

    logic [1:0] write_col_counter,write_col_counter_next; // counts from 0-3 since it needs 4 cycles to write all values to ram
    logic [1:0] calc_total_counter,calc_total_counter_next; // Counts the collumn the accellerator is working on

    logic [3:0] read_counter, read_counter_next;

    // Update State Machine
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            current_state <= idle;

            ram_base_addr <= 0;
            input_counter <= 0;
            calc_col_counter <= 0;
            ireg_read_counter <= 0;
            write_col_counter <= 0;
            calc_total_counter <= 0;
            read_counter <= 0;

        end else begin	
            current_state <= next_state;

            ram_base_addr <= ram_base_addr_next;
            input_counter <= input_counter_next;
            calc_col_counter <= calc_col_counter_next;
            ireg_read_counter <= ireg_read_counter_next;
            write_col_counter <= write_col_counter_next;
            calc_total_counter <= calc_total_counter_next;
            read_counter <= read_counter_next;


        end
    end

    // Transition logic
    always_comb begin
        next_state = current_state;

        case(current_state)
            

            input_data: begin
                if(input_counter == 31) begin
                    next_state = calc_collumn;
                end
            end

            calc_collumn: begin
                if(calc_col_counter == 7) begin
                    next_state = write_collumn;
                end
            end

            write_collumn: begin
                if(write_col_counter == 3) begin
                    if(calc_total_counter == 3) begin
                        next_state = idle;
                    end else begin
                        next_state = calc_collumn;
                    end
                end

            end

            read_first: begin
                next_state = read_second;
            end

            read_second: begin
                next_state = read_first;
                if(read_counter == 0) begin // Once an overflow has occured
                    next_state = idle;
                end
            end 

            default: begin // also the idle state
                if(start) begin
                    next_state = input_data;
                end else begin
                    if(read) begin
                        next_state = read_first;
                    end
                end
            
            end

        endcase
    end

    // Output logic
    //test commit
    assign to_rom_sel_second = calc_col_counter[0];
    assign to_mux_select = write_col_counter;
    assign to_rom_read_addr = {calc_total_counter,calc_col_counter[2:1]};
    
    
    always_comb begin
        finish = 0;
        to_ireg_read_addr_1 = 0;
        to_ireg_read_addr_2 = 0;
        to_ireg_read_addr_3 = 0;
        to_ireg_read_addr_4 = 0;

        to_ireg_write_addr = 0;
        to_ireg_write_en = 0;

        mac_en = 0;
        mac_rst_n = 1;

        to_ram_write_en = 0;

        sel_upper = 0; 

        to_ram_addr = 0; 

        case(current_state)
            input_data: begin
                to_ireg_write_addr = input_counter;
                to_ireg_write_en = 1;
            end

            calc_collumn: begin
                to_ireg_read_addr_1 = ireg_read_counter;
                to_ireg_read_addr_2 = ireg_read_counter +1;
                to_ireg_read_addr_3 = ireg_read_counter +2;
                to_ireg_read_addr_4 = ireg_read_counter +3;

                mac_en = 1;
            end

            write_collumn: begin
                to_ram_addr = {ram_base_addr,calc_total_counter,write_col_counter};
                to_ram_write_en = 1;

                if(write_col_counter == 3) begin
                    mac_rst_n = 0;
                    if(calc_total_counter == 3) begin
                        finish = 1;
                    end
                end

            end

            read_first: begin
                to_ram_addr = {ram_base_addr,read_counter};
                // sel_upper = 0 and are set by default
            end
            read_second: begin
                to_ram_addr = {ram_base_addr,read_counter};
                sel_upper = 1;
            end  

            default: begin // also the idle state
              	if(start) begin
                	to_ireg_write_en = 1;
                end else begin
                    if(read == 1) begin
                        to_ram_addr = {in_addr,4'b0000};
                    end
                end
            end

        endcase

    end

    // set counter_next
    always_comb begin
        ram_base_addr_next = ram_base_addr;
        input_counter_next = input_counter;
        calc_col_counter_next = calc_col_counter;
        ireg_read_counter_next = ireg_read_counter;
        write_col_counter_next = write_col_counter;
        calc_total_counter_next = calc_total_counter;

        read_counter_next = read_counter;

        case(current_state)
        

        input_data: begin
            input_counter_next = input_counter+1;
            
            if(input_counter == 31) begin
                calc_col_counter_next = 0;
                ireg_read_counter_next = 0;
            end
        end

        calc_collumn: begin
            calc_col_counter_next = calc_col_counter +1;
            ireg_read_counter_next = ireg_read_counter +4;

            
            if(calc_col_counter == 7) begin
                write_col_counter_next = 0;
            end

  
        end

        write_collumn: begin
            write_col_counter_next = write_col_counter +1;

            if(write_col_counter == 3) begin
                calc_col_counter_next = 0;
                calc_total_counter_next = calc_total_counter +1;


            end

        end
        read_first: begin
            read_counter_next = read_counter + 1;
        end

        read_second: begin
            // Nothing to be done
        end

        default: begin // also the idle state
            input_counter_next = 0;
            calc_total_counter_next = 0;
            if(start) begin
                input_counter_next = 1;
                ram_base_addr_next = in_addr;
            end else begin
                if(read) begin
                    ram_base_addr_next = in_addr;
                end
            end
        end

    endcase

    end

endmodule