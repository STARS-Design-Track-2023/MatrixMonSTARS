`default_nettype none

module calculator 
(
  // I/O ports
  input  logic        clk, nrst,
  input  logic [4:0]  pb,
  output logic [13:0] ss,
  output logic        red, blue
);

  // Intermediate Signals
  logic keystrobe1, isdig, isop, is_enter, is_result, store_dig, enter, result_ready;
  logic [2:0] opcode;
  logic [8:0] op1, digit_con; 
  logic sign, o_flag;
  logic [8:0] op2;
  logic [8:0] result, digit;
  logic [7:0] seg;

  keyencoder_binary u1
  (
    .clk(clk), 
    .nrst(nrst), 
    .is_op(isop), 
    .keypad(pb[1:0]),
    .is_result(is_result), 
    .is_enter(is_enter), 
    .store_dig(store_dig), 
    .enter(enter), 
    .result_ready(result_ready), 
    .keycode(digit)
  );

  neg_input u10 
  (
    .digit(digit), 
    .digit_con(digit_con)
  );

  opcode_encoder u2
  (
    .clk(clk), 
    .nrst(nrst), 
    .in(pb[12:10]), 
    .out(opcode), 
    .is_op(isop), 
    .is_result(is_result), 
    .is_enter(is_enter)
  );  

  new_operand_buffer u5 
  (
    .clk(clk), 
    .nrst(nrst), 
    .sign1(sign), 
    .o_flag1(o_flag),
    .store_digit(store_dig), 
    .enter(enter), 
    .result_ready(result_ready), 
    .digit(digit), 
    .digit_con(digit_con),
    .op1(op1), .sign(blue), 
    .o_flag(red),
    .result(result), 
    .ssdec(seg)
  );

  last_operand_buffer u6
  (
    .clk(clk), 
    .nrst(nrst), 
    .enter(enter), 
    .op1(op1), 
    .op2(op2)
  );

  alu u7 
  (
    .op1(op2), 
    .op2(op1), 
    .opcode(opcode), 
    .result(result), 
    .o_flag(o_flag), 
    .sign(sign)
  );

  ssdec u8 
  (
    .result({1'b0,seg}),
    .segments(ss)
  );

endmodule