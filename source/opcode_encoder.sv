
module opcode_encoder(
  input logic clk, nrst,
  input logic [1:0] in,
  output logic [2:0] out,
  output logic is_op, is_result, is_enter
);


logic [1:0] keypad_async, keypad_sync, keypad_13;
logic keystrobe;

always_ff @(posedge clk, negedge nrst) begin
    if(0 == nrst) begin
        keypad_async <= 0;
        keypad_sync <= 0;
        keypad_13 <= 0;
    end
    else begin
        keypad_async <= in;
        keypad_sync <= keypad_async;
        keypad_13 <= keypad_sync;
    end
end

always_comb begin
    if((|keypad_sync) && ~(|keypad_13)) begin
        keystrobe = 1'b1;
    end
    else begin
        keystrobe = 1'b0;
    end
end

always_comb begin : OpcodeCombinationalLogic
    out = 'b0;
    is_op = 'b0;
    is_result = 'b0;
    is_enter = 'b0;
    if(keystrobe) begin
        case(keypad_sync)
        2'b01: begin // added
                out = 3'b001;
                is_op = 1;
                is_result = 1;
                is_enter = 0;
                end 
        2'b10: begin //substracted
                out = 3'b010;
                is_op = 1;
                is_result = 1;
                is_enter = 0;
                end 
        endcase
    end
    end
endmodule
    
