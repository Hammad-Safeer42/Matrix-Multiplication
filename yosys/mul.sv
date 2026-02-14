module mul(
  input logic [7:0] in_data,
  input logic [6:0] in_coeff,
  output logic [14:0] out_data
  

);

  // output
  assign out_data = in_data * in_coeff;

endmodule