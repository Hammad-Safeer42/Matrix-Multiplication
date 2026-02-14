module mac_unit(
  input logic [14:0] in_data,
  input logic clk,
  input logic rst_n,
  input logic en,

  output logic [17:0] out_data
);

  logic [17:0] acc_reg;
  always_ff @(posedge clk) begin
    if(!rst_n) begin
      acc_reg <= 0;
    end else begin
      if(en) begin
        acc_reg <= acc_reg + in_data;
      end
    end

  end

  // output
  assign out_data = acc_reg;

endmodule