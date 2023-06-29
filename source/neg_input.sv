module neg_input(
  input logic [8:0] digit,
  output logic [8:0] digit_con
);

  logic max_logic_lsd, max_logic_msd, carry_lsd;
  logic [3:0] correction_lsd, correction_msd;
  always_comb begin
    {max_logic_lsd, max_logic_msd, carry_lsd, correction_lsd, correction_msd} = 0;
    digit_con = digit;
    if(digit == 9'b100000000) begin
      digit_con = 9'b000000000;
    end
    else if(digit[8] == 1) begin
      digit_con[3:0] = 4'b1001 - digit[3:0] + 1;
      max_logic_lsd = (digit_con[3] && digit_con[2]) || (digit_con[3] && digit_con[1]);
      correction_lsd = {1'b0, max_logic_lsd, max_logic_lsd, 1'b0};

      {carry_lsd, digit_con[3:0]} = digit_con[3:0] + correction_lsd;
      digit_con[7:4] = 4'b1001 - digit[7:4] + {3'b000, carry_lsd};
      max_logic_msd = (digit_con[7] && digit_con[6]) || (digit_con[7] && digit_con[5]);
      correction_msd = {1'b0, max_logic_msd, max_logic_msd, 1'b0};
      digit_con[7:4] = digit_con[7:4] + correction_msd;
    end
  end
endmodule