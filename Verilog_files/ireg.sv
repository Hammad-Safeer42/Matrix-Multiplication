module ireg (
    input logic clk,
    input logic rst_n,

    input logic write,
    input logic [7:0] data_in,
    input logic [4:0] addr_in,

    output logic [7:0] data_out_1,
    output logic [7:0] data_out_2,
    output logic [7:0] data_out_3,
    output logic [7:0] data_out_4,

    input logic [4:0] addr_out_1,
    input logic [4:0] addr_out_2,
    input logic [4:0] addr_out_3,
    input logic [4:0] addr_out_4
    );

    logic [7:0] registers [0:31];
  
  // read_logic
  assign data_out_1 = registers[addr_out_1];
  assign data_out_2 = registers[addr_out_2];
  assign data_out_3 = registers[addr_out_3];
  assign data_out_4 = registers[addr_out_4];
  
  // write logic
  always_ff @(posedge clk) begin

    if (!rst_n) begin
      for(int i = 0; i < 32; i++) begin
        registers[i] <= 0;
      end

    end else begin	
      if(write) begin
        registers[addr_in] <= data_in;
      end
    end
  end

endmodule;