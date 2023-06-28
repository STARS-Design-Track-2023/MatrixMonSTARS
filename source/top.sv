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
  logic [3:0] keycode1, digit;
  logic keystrobe1, isdig, isop, is_enter, is_result, store_dig, enter, result_ready, is_reg, r_en;
  logic [2:0] opcode;
  logic [8:0] op; 
  logic sign;
  logic [8:0] result;
  logic [7:0] seg;
  logic alu_en;
  logic [2:0] reg_sel;
  logic [8:0] reg_val;
  logic [2:0] reg_num;
  logic assign_op1, assign_op2;


  // assign store_dig = 1'b0;
  // //assign is_reg = 1'b1;
  // assign result_ready = 1'b0;
  // assign digit = 'b0;
  // assign op = 9'b010010101;
  // assign r_en = 1'b1;
  // assign opcode = 3'b010;

  key_encoder u1(.clk(hwclk), .nrst(~reset), .keypad(pb[12:0]), .keycode(keycode1), .keystrobe(keystrobe1));
  
  digit_decoder u2(.clk(hwclk), .nrst(~reset), .keystrobe(keystrobe1), .keycode(keycode1), .isdig(isdig), .digitCode(digit));

  opcode_decoder u3(.clk(hwclk), .nrst(~reset), .key_strobe(keystrobe1), .in(keycode1), .is_op(isop), .out(opcode), .is_enter(is_enter), .is_result(is_result));

  fsm u10(.clk(hwclk), .nrst(~reset), .opcode(opcode), .is_op(isop), .is_dig(isdig), .is_enter(is_reg), .is_result(is_result), .store_dig(store_dig), .enter(enter), .result_ready(result_ready), .key_strobe(keystrobe1));

  register_decoder u4(.clk(hwclk), .nrst(~reset), .register_button(pb[19:16]), .is_reg(is_reg), .reg_num(reg_num));

  new_operand_buffer u5(.clk(hwclk), .nrst(~reset), .store_digit(store_dig), .is_reg(is_reg), .result_ready(result_ready), .digit(digit), .op1(op), .sign(sign), .result(result), .ssdec(seg));

  read_fsm u6(.clk(hwclk), .nrst(~reset), .r_en(r_en), .reg_num(reg_num), .opcode(opcode), .reg_sel(reg_sel), .alu_en(alu_en), .assign_op1(assign_op1), .assign_op2(assign_op2));

  reg_file u7(.clk(hwclk), .nrst(~reset), .reg_num(reg_num), .reg_sel(reg_sel), .op(op), .reg_val(reg_val));

  alu u8(.clk(hwclk), .nrst(~reset), .assign_op1(assign_op1), .assign_op2(assign_op2), .op(op), .alu_en(alu_en), .opcode(opcode), .result(result));
   
  ssdec u9(.result({1'b0,seg}), .sign(sign),.segments({ss1[6:0], ss0[6:0]}), .negsign(red));
endmodule


