module last_operand_buffer(
    input logic [8:0] op1,
    input logic enter, clk, nrst,
    output logic [8:0] op2

);

    logic [8:0] next_op2;
    always_ff @(posedge clk, negedge nrst) begin
        if(~nrst)
            op2 <= 0;
        else
            op2 <= next_op2;
    end

    always_comb begin
        if(enter)
            next_op2 = op1;
        else
            next_op2 = op2;
    end



endmodule