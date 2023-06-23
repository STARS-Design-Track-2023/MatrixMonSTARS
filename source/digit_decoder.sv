module digit_decoder(
    input logic keystrobe,
    input logic [3:0] keycode,
    output logic isdig,
    output logic [3:0] digitCode
 );

 always_comb begin
    if(keystrobe && keycode < 4'b1010) begin
        digitCode = keycode;
        isdig = 1;
    end
    else begin
        digitCode = 4'b0000;
        isdig = 0;
    end
 end
endmodule