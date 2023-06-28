module opcode_decoder(
    input logic key_strobe, clk, nrst,
    input logic [3:0] in, // keycode for opcode
    output logic is_op, is_result, is_enter, // isop logic for the FSM
    output logic [2:0] out //output opcode for the ALU 
);
logic [2:0] next_out;
always_ff @(posedge clk, negedge nrst) begin
    if(0 == nrst) begin
        out <= 0;
    end
    else begin
        out <= next_out;
    end
end

always_comb begin : OpcodeCombinationalLogic
    next_out = out;
    is_op = 0;
    is_result = 0;
    is_enter = 0;
    if (key_strobe)
    begin
    case(in)
    4'b1010: begin // added
            next_out = 3'b001;
            is_op = 1;
            is_result = 1;
            is_enter = 0;
            end 
    4'b1011: begin //substracted
            next_out = 3'b010;
            is_op = 1;
            is_result = 1;
            is_enter = 0;
            end 
    4'b1100: begin // entered
            next_out = 3'b011;
            is_op = 1;
            is_result = 0;
            is_enter = 1;
                end
    endcase
    end
end




endmodule
    