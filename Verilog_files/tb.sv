`timescale 1ns / 1ps

module tb;
    // DUT ports
    logic       clk = 0;
    logic       rst = 1;
    logic [7:0] i_input_data = 8'b0;
    logic       i_start = 1'b0;
    logic       i_read_ram = 1'b0;
    logic [8:0] o_read_data_out; // NOTE: Output width halved to reduce pin count - will be time-multiplexed
    logic       o_finish;
    logic [4:0] i_ram_addr;

    logic [7:0]  input_stimuli[2048];
  logic [31:0] expected_results[1024];
  logic [31:0] calculated_results[1024];


    localparam CLK_PERIOD = 10;
  	integer read_index = 0;

    // MM_TOP Device Under Test Instance
    // Change module and port names if different
    mm_top dut (
        .clk            (clk),
        .rst            (rst),
        .in_data        (i_input_data),
        .ram_slot       (i_ram_addr),
        .start          (i_start),
        .read           (i_read_ram),
        .out_data       (o_read_data_out),
        .finish         (o_finish)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

  task automatic load_matrix(input [7:0] matrix_idx,input [4:0] storage_slot);
      	
        integer stimuli_start = matrix_idx*32;      
      	integer stimuli_end = matrix_idx*32 + 32;
      	integer i;
        
        @(posedge clk);
      	i_start <= 1'b1;
      	i_ram_addr <= storage_slot;
      	for (i = stimuli_start; i < stimuli_end; i++) begin
          	
            i_input_data <= input_stimuli[i];
            @(posedge clk);
            i_ram_addr <= 0;
        end

        i_start = 1'b0;
    endtask

  
  	task read_result(input [4:0] storage_slot);
      integer limit = 16; // 16 values are read
      integer i;
      // Start read
      @(posedge clk);
      i_read_ram = 1;
      i_ram_addr <= storage_slot;
      @(posedge clk);
      i_read_ram = 0;
      @(posedge clk);
      // get data
      for(i = 0; i < limit; i++) begin
        calculated_results[read_index][8:0] <= o_read_data_out;
        @ (posedge clk);
        calculated_results[read_index][17:9] <= o_read_data_out;
        calculated_results[read_index][31:18] <= 14'b0;
        
       	@ (posedge clk);
        read_index++;
        
      end
    endtask

  
    initial begin
      	$dumpfile("wave.vcd");      // name of VCD file
      	$dumpvars(0, tb);           // dump everything under module "tb"
      
        // reset release - active high is assumed
        rst = 1;
      	repeat(5) @(posedge clk); 
      	rst = 0;
      	@(posedge clk);
      
        // Read the stimuli and result files to corresponding arrays
        $readmemb("input_stimuli.txt", input_stimuli);
        $readmemb("output_results.txt", expected_results);
		
		// First half is calculated
		for(int i = 0;i < 32; i++) begin
            load_matrix(i,i); //matrix i is written to slot i
            wait(o_finish);
            read_result(i);
            @(posedge clk);
		end

		//write second half
		for(int i = 0;i < 32; i++) begin
		  load_matrix(i+32,i);
		  wait(o_finish);
		end
		
		//read results of second half
		for(int i = 0;i < 32; i++) begin
		  read_result(i);
		end

      	$display("Start Comparison of Results");
      	
        for(int i = 0; i < 1024; i++) begin
            int matrix = i/16;
        
            if(expected_results[i] != calculated_results[i]) begin
                $display("ERROR in matrix %d at index %d: expected %h %h %h, calculated %h %h %h",matrix, i, expected_results[i][31:18],expected_results[i][17:9], expected_results[i][8:0],
                                                                                    calculated_results[i][31:18],calculated_results[i][17:9],calculated_results[i][8:0]);
                break;
            end
            else begin
                if((i%16 == 0) && (i != 0)) begin
                    $display("Matrix %d is correct",matrix);
                end
            end
        end
        $display("Comparison finished :)");
    
        $finish;
    end

endmodule