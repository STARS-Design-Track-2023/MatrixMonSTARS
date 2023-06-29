`default_nettype none

module calculator 
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

  logic keystrobe1, isdig, isop, is_enter, is_result, store_dig, enter, result_ready;
  logic [2:0] opcode;
  logic [8:0] op1, digit_con; 
  logic sign, o_flag;
  logic [8:0] op2;
  logic [8:0] result, digit;
  logic [7:0] seg;

  keyencoder_binary u1(.clk(hwclk), .nrst(~reset), .is_op(isop), .keypad(pb[1:0]),.is_result(is_result), .is_enter(is_enter), .store_dig(store_dig), .enter(enter), .result_ready(result_ready), .keycode(digit));
  neg_input u10(.digit(digit), .digit_con(digit_con));
  opcode_encoder u2(.clk(hwclk), .nrst(~reset), .in(pb[12:10]), .out(opcode), .is_op(isop), .is_result(is_result), .is_enter(is_enter));  
  new_operand_buffer u5(.clk(hwclk), .nrst(~reset), .sign1(sign), .o_flag1(o_flag),.store_digit(store_dig), .enter(enter), .result_ready(result_ready), .digit(digit), .digit_con(digit_con),.op1(op1), .sign(blue), .o_flag(red),.result(result), .ssdec(seg));
  last_operand_buffer u6(.clk(hwclk), .nrst(~reset), .enter(enter), .op1(op1), .op2(op2));
  alu u7(.op1(op2), .op2(op1), .opcode(opcode), .result(result), .o_flag(o_flag), .sign(sign));
  ssdec u8(.result({1'b0,seg}),.segments({ss1[6:0], ss0[6:0]}));
endmodule