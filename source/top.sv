`default_nettype none

module top 
(
  // I/O ports
  input  logic hwclk, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);
  logic isdig, isop, is_enter, is_result, store_dig, result_ready, is_reg, alu_en, assign_op1, assign_op2, enter, write;
  logic [2:0] opcode;
  logic [8:0] op, digit_con; 
  logic sign, o_flag;
  logic [8:0] result, digit;
  logic [7:0] seg;
  logic [2:0] reg_num, reg_sel;
  logic [8:0] reg_val;
  
  calculator CALC
  (
    .clk(hwclk),
    .nrst(~reset),
    .pb({pb[19:16], pb[11:10], pb[3:2],pb[1:0]}),
    .ss({ss1[6:0], ss0[6:0]}),
    .red(red),
    .blue(blue)
  );
endmodule