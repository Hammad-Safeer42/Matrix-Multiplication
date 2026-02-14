`include "ireg.sv"
`include "rom.sv"
`include "mul.sv"
`include "mac_unit.sv"
`include "ram_mux.sv"
`include "RM_IHPSG13_1P_512x32_c2_bm_bist.v"
`include "output_logic.sv"
`include "calc_asmd.sv"
`include "RM_IHPSG13_1P_512x32_c2_bm_bist.v"



module mm_top(
    input logic clk,
    input logic rst,

    input logic read,
    input logic start,

    input logic [7:0] in_data,
    input logic [4:0] ram_slot,

    output logic finish,
    output logic [8:0] out_data
);
// interconnect Signal
    logic ireg_write_en;
    logic [4:0] ireg_write_addr;

    logic [7:0] ireg_data_out_1;
    logic [7:0] ireg_data_out_2;
    logic [7:0] ireg_data_out_3;
    logic [7:0] ireg_data_out_4;

    logic [4:0] ireg_read_addr_1;
    logic [4:0] ireg_read_addr_2;
    logic [4:0] ireg_read_addr_3;
    logic [4:0] ireg_read_addr_4;

    logic [14:0] mul_output_1;
    logic [14:0] mul_output_2;
    logic [14:0] mul_output_3;
    logic [14:0] mul_output_4;

    logic [17:0] mac_out_1;
    logic [17:0] mac_out_2;
    logic [17:0] mac_out_3;
    logic [17:0] mac_out_4;

    logic mac_rst_n;
    logic mac_en;

    logic [1:0] ram_mux_select;
    logic [17:0] ram_mux_out;

    logic from_asmd_mac_rst_n;

    logic [3:0] rom_read_addr;

    logic [8:0] ram_addr;
    logic ram_write_en;

    logic [31:0] ram_read_data;
    logic [8:0] ram_read_addr; 

    logic read_sel_upper;

    logic [6:0] rom_coeff;
    logic rom_sel_upper;

    logic rst_n;


    assign rst_n = ~rst;

RM_IHPSG13_1P_512x32_c2_bm_bist ram_block(
    .A_ADDR(ram_addr),
    .A_DIN({14'b000000_00000000,ram_mux_out}),
  	.A_BM('hffffffff),
  	.A_MEN(1'b1),	// Memory enable input	-> if disabled, the memory is deactivated
    .A_WEN(ram_write_en),	// Common write enable input (bytes maskable with BM[23:0])
  	.A_REN(1'b1),	// Read enable input ->  if enabled for read access when WEN=1 --> Write-through
    .A_CLK(clk),	// Clock input
  	.A_DLY(1'b0),	// Delay selection signals
    .A_DOUT(ram_read_data),

    .A_BIST_EN(1'b0),
  	.A_BIST_ADDR(9'b0000_0000_0),
  	.A_BIST_DIN('h00000000),
  	.A_BIST_BM('h00000000),
    .A_BIST_MEN(1'b0),
    .A_BIST_WEN(1'b0),
    .A_BIST_REN(1'b0),
    .A_BIST_CLK(1'b0)


);

ireg input_register(
    .clk(clk),
    .rst_n(rst_n),
    .write(ireg_write_en),
    .data_in(in_data),
    .addr_in(ireg_write_addr),
    .data_out_1(ireg_data_out_1),
    .data_out_2(ireg_data_out_2),
    .data_out_3(ireg_data_out_3),
    .data_out_4(ireg_data_out_4),
    .addr_out_1(ireg_read_addr_1),
    .addr_out_2(ireg_read_addr_2),
    .addr_out_3(ireg_read_addr_3),
    .addr_out_4(ireg_read_addr_4)
);

rom rom_1(
    .in_addr(rom_read_addr),
    .sel_upper(rom_sel_upper),
    .out_data(rom_coeff)
);

mul mul_1(
    .in_data(ireg_data_out_1),
    .in_coeff(rom_coeff),
    .out_data(mul_output_1)
);
mul mul_2(
    .in_data(ireg_data_out_2),
    .in_coeff(rom_coeff),
    .out_data(mul_output_2)
);
mul mul_3(
    .in_data(ireg_data_out_3),
    .in_coeff(rom_coeff),
    .out_data(mul_output_3)
);
mul mul_4(
    .in_data(ireg_data_out_4),
    .in_coeff(rom_coeff),
    .out_data(mul_output_4)
);

mac_unit mac_1(
    .clk(clk),
    .rst_n(mac_rst_n),
    .in_data(mul_output_1),
    .out_data(mac_out_1),
    .en(mac_en)
);

mac_unit mac_2(
    .clk(clk),
    .rst_n(mac_rst_n),
    .in_data(mul_output_2),
    .out_data(mac_out_2),
    .en(mac_en)
);

mac_unit mac_3(
    .clk(clk),
    .rst_n(mac_rst_n),
    .in_data(mul_output_3),
    .out_data(mac_out_3),
    .en(mac_en)
);

mac_unit mac_4(
    .clk(clk),
    .rst_n(mac_rst_n),
    .in_data(mul_output_4),
    .out_data(mac_out_4),
    .en(mac_en)
);

assign mac_rst_n = rst_n && from_asmd_mac_rst_n;


ram_mux ram_mux_1(
    .in_data_1(mac_out_1),
    .in_data_2(mac_out_2),
    .in_data_3(mac_out_3),
    .in_data_4(mac_out_4),
    .select(ram_mux_select),
    .out_data(ram_mux_out)
);

output_logic op_logic(
    .clk(clk),
    .rst_n(rst_n),
    .in_data(ram_read_data),
    .sel_upper(read_sel_upper),
    .out_data(out_data)

);


calc_asmd calc_control(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .read(read),
    .in_addr(ram_slot),
    .finish(finish),
    .mac_en(mac_en),
    .mac_rst_n(from_asmd_mac_rst_n),

    .to_ireg_read_addr_1(ireg_read_addr_1),
    .to_ireg_read_addr_2(ireg_read_addr_2),
    .to_ireg_read_addr_3(ireg_read_addr_3),
    .to_ireg_read_addr_4(ireg_read_addr_4),

    .to_ireg_write_addr(ireg_write_addr),
    .to_ireg_write_en(ireg_write_en),
    .to_rom_sel_second(rom_sel_upper),
    .to_rom_read_addr(rom_read_addr),
    .to_ram_addr(ram_addr),
    .to_ram_write_en(ram_write_en),
    .sel_upper(read_sel_upper),
    .to_mux_select(ram_mux_select)
);

// read_asmd read_control(
//     .clk(clk),
//     .rst_n(rst_n),
//     .in_addr(ram_addr),
//     .read_en(read),

//     .sel_upper(read_sel_upper),
//     .read_new(read_new),
//     .read_addr(ram_read_addr)

// );


endmodule