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

 keyencoder_binary u1(.clk(hwclk), .nrst(~reset), .is_op(isop), .keypad(pb[1:0]),.is_result(is_result), .is_enter(is_reg), .store_dig(store_dig), .enter(enter), .write_en(write),.keycode(digit), .r_en(pb[3]), .w_en(pb[2]));
 neg_input u2(.digit(digit), .digit_con(digit_con));
 opcode_encoder u3(.clk(hwclk), .nrst(~reset), .in(pb[12:10]), .out(opcode), .is_op(isop), .is_result(is_result), .is_enter(is_enter));  
 new_operand_buffer u4(.clk(hwclk), .nrst(~reset), .sign1(sign), .o_flag1(o_flag),.store_digit(store_dig), .enter(enter), .result_ready(result_ready), .digit(digit), .digit_con(digit_con),.op1(op), .sign(blue), .o_flag(red),.result(result), .ssdec(seg));
 register_decoder u6(.clk(hwclk), .nrst(~reset), .register_button(pb[19:16]), .is_reg(is_reg), .reg_num(reg_num));
 reg_file u5(.clk(hwclk), .nrst(~reset), .reg_num(reg_num), .reg_sel(reg_sel), .op(op), .reg_val(reg_val), .write(write));
 read_fsm u7(.clk(hwclk), .nrst(~reset), .r_en(pb[3]), .reg_num(reg_num), .opcode(opcode), .reg_sel(reg_sel), .alu_en(alu_en), .assign_op1(assign_op1),.assign_op2(assign_op2), .result_ready(result_ready));
 alu u8(.clk(hwclk), .nrst(~reset), .op(reg_val), .opcode(opcode), .alu_en(alu_en), .assign_op1(assign_op1), .assign_op2(assign_op2), .res1(right), .res2(left), .result(result));
 ssdec u9(.result({1'b0,seg}),.segments({ss1[6:0], ss0[6:0]}));

endmodule


