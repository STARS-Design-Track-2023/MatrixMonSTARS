module calculator 
(
  input  logic        clk, nrst,
  input  logic [9:0]  pb,
  output logic [13:0] ss,
  output logic        red, blue
);

  // Intermediate Signals
  logic       isdig, isop, is_enter, is_result, store_dig, result_ready, is_reg;
  logic       sign, o_flag, alu_en, assign_op1, assign_op2, enter, write;
  logic [2:0] opcode, reg_num, reg_sel;
  logic [7:0] seg;
  logic [8:0] op, digit_con, result, digit, reg_val;

  // Module Instanciations and Connections
  keyencoder_binary u1
  (
    .clk(clk), 
    .nrst(nrst), 
    .is_op(isop), 
    .keypad(pb[1:0]),
    .is_result(is_result), 
    .is_enter(is_reg), 
    .store_dig(store_dig), 
    .enter(enter), 
    .write_en(write),
    .keycode(digit), 
    .r_en(pb[3]), 
    .w_en(pb[2])
  );

  neg_input u2
  (
    .digit(digit), 
    .digit_con(digit_con)
  );

  opcode_encoder u3
  (
    .clk(clk), 
    .nrst(nrst), 
    .in(pb[5:4]), 
    .out(opcode), 
    .is_op(isop), 
    .is_result(is_result), 
    .is_enter(is_enter)
  );

  new_operand_buffer u4
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
    .op1(op), 
    .sign(blue), 
    .o_flag(red),
    .result(result), 
    .ssdec(seg)
  );

  register_decoder u6
  ( 
    .clk(clk), 
    .nrst(nrst), 
    .register_button(pb[9:6]), 
    .is_reg(is_reg), 
    .reg_num(reg_num)
  );

  reg_file u5
  (
    .clk(clk), 
    .nrst(nrst), 
    .reg_num(reg_num), 
    .reg_sel(reg_sel), 
    .op(op), 
    .reg_val(reg_val), 
    .write(write)
  );

  read_fsm u7
  (
    .clk(clk), 
    .nrst(nrst), 
    .r_en(pb[3]), 
    .reg_num(reg_num), 
    .opcode(opcode), 
    .reg_sel(reg_sel), 
    .alu_en(alu_en), 
    .assign_op1(assign_op1),
    .assign_op2(assign_op2), 
    .result_ready(result_ready)
  );

  alu u8
  (
    .clk(clk), 
    .nrst(nrst), 
    .op(reg_val), 
    .opcode(opcode), 
    .alu_en(alu_en), 
    .assign_op1(assign_op1), 
    .assign_op2(assign_op2), 
    .result(result), 
    .o_flag(o_flag), 
    .sign(sign)
  );

  ssdec u9
  (
    .result({1'b0,seg}),
    .segments(ss)
  );

endmodule