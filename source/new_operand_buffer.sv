module new_operand_buffer(
    input logic clk, nrst, sign1, o_flag1,
    input logic [8:0] result,
    input logic store_digit, enter, result_ready,
    input logic [8:0] digit, digit_con,
    output logic [8:0] op1,
    output logic sign, o_flag,
    output logic [7:0] ssdec
);

    logic [8:0] next_op1;
    logic [7:0] next_ssdec;
    logic next_sign, next_o_flag;

    always_ff @( posedge clk, negedge nrst ) begin
        if (~nrst) begin
            op1 <= 0;
            ssdec <= 0;
            sign <= 0;
            o_flag <= 0;
        end
        else begin
            op1 <= next_op1;
            ssdec <= next_ssdec;
            sign <= next_sign;
            o_flag <= next_o_flag;
        end
    end

    always_comb begin
        next_op1 = op1;
        if(store_digit) begin
            next_op1 = digit_con;
        end
        else if (enter)
            next_op1 = 0;
    end

  always_comb begin
    next_sign = sign;
    next_o_flag = o_flag;
    if(store_digit) begin
        next_ssdec = digit[7:0];
        next_sign  = digit[8];
    end
    else if (enter) begin
        next_ssdec = 0;
        next_sign = 0;
        next_o_flag = 0;
    end
    else if (result_ready) begin
        next_ssdec = result[7:0];
        next_sign = sign1;
        next_o_flag = o_flag1;
    end
    else
        next_ssdec = ssdec;
    end
    
endmodule