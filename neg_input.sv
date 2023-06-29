module neg_input(
  input logic [8:0] digit,
  output logic [8:0] digit_con
);
  always_comb begin
  digit_con = digit;
    if(digit[8] == 1) begin
      digit_con[3:0] = 4'b1001 - digit[3:0] + 1;
      digit_con[7:4] = 4'b1001 - digit[3:0];
    end
    else
      digit_con = digit;
  end
endmodule