(* blackbox *)
module RM_IHPSG13_1P_512x32_c2_bm_bist (
    input  [8:0]  A_ADDR,
    input  [31:0] A_DIN,
    input  [31:0] A_BM,
    input         A_MEN,
    input         A_WEN,
    input         A_REN,
    input         A_CLK,
    input         A_DLY,
    output [31:0] A_DOUT,

    input         A_BIST_EN,
    input  [8:0]  A_BIST_ADDR,
    input  [31:0] A_BIST_DIN,
    input  [31:0] A_BIST_BM,
    input         A_BIST_MEN,
    input         A_BIST_WEN,
    input         A_BIST_REN,
    input         A_BIST_CLK,

    input         VDD,
    input         VDDARRAY,
    input         VSS
);
endmodule
