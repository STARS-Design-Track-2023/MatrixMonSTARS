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

  logic keystrobe1, isdig, isop, is_enter, is_result, store_dig, enter, result_ready;
  logic [2:0] opcode;
  logic [8:0] op1; 
  logic sign;
  logic [8:0] op2;
  logic [8:0] result, digit;
  logic [7:0] seg;

  keyencoder_binary u1(.clk(hwclk), .nrst(~reset), .is_op(isop), .keypad(pb[1:0]),.is_result(is_result), .is_enter(is_enter), .store_dig(store_dig), .enter(enter), .result_ready(result_ready), .keycode(digit));
  opcode_encoder u2(.clk(hwclk), .nrst(~reset), .in(pb[12:10]), .out(opcode), .is_op(isop), .is_result(is_result), .is_enter(is_enter));  
  new_operand_buffer u5(.clk(hwclk), .nrst(~reset), .store_digit(store_dig), .enter(enter), .result_ready(result_ready), .digit(digit), .op1(op1), .sign(sign), .result(result), .ssdec(seg));

  last_operand_buffer u6(.clk(hwclk), .nrst(~reset), .enter(enter), .op1(op1), .op2(op2));

  alu u7(.op1(op1), .op2(op2), .opcode(opcode), .result(result));
   
  ssdec u8(.result({1'b0,seg}), .sign(sign),.segments({ss1[6:0], ss0[6:0]}), .negsign(blue));
endmodule


// `default_nettype none

// module top 
// (
//   // I/O ports
//   input  logic hwclk, reset,
//   input  logic [20:0] pb,
//   output logic [7:0] left, right,
//          ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
//   output logic red, green, blue,

//   // UART ports
//   output logic [7:0] txdata,
//   input  logic [7:0] rxdata,
//   output logic txclk, rxclk,
//   input  logic txready, rxready
// );
//   logic [3:0] keycode1, digit;
//   logic keystrobe1, isdig, isop, store_dig, enter, result_ready;
//   logic [2:0] opcode;
//   logic [8:0] op1; 
//   logic sign;
//   logic [8:0] op2;
//   logic [8:0] result;
  
//   key_encoder u1(.clk(hwclk), .nrst(~pb[19]), .keypad(pb[12:0]), .keycode(keycode1), .keystrobe(keystrobe1));
  
//   digit_decoder u2(.keystrobe(keystrobe1), .keycode(keycode1), .isdig(red), .digitCode(left[3:0]));

//   opcode_decoder u3(.key_strobe(keystrobe1), .in(keycode1), .is_op(blue), .out(right[2:0]));

//   //fsm u4(.clk(hwclk), .nrst(~pb[19]), .is_op(isop), .is_dig(isdig), .store_dig(right[0]), .enter(right[1]), .result_ready(right[2]), .key_strobe(keystrobe1));
  
//   // new_operand_buffer u5(.clk(hwclk), .nrst(~pb[19]), .store_digit(store_dig), .enter(enter), .result_ready(result_ready), .digit(digit), .op1(op1), .sign(sign), .result(result));

//   // last_operand_buffer u6(.clk(hwclk), .nrst(~pb[19]), .enter(enter), .op1(op1), .op2(op2));

//   // alu u7(.op1(op1), .op2(op2), .opcode(opcode), .result(result));

//   // ssdec u8(.result(result), .segments({ss1[6:0], ss0[6:0]}), .negsign(red));
// endmodule