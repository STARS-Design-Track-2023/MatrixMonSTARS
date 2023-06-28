module new_operand_buffer(
    input logic clk, nrst,
    input logic [8:0] result,
    input logic store_digit, enter, result_ready,
    input logic [8:0] digit,
    output logic [8:0] op1,
    output logic sign,
    output logic [7:0] ssdec
);

    logic [8:0] next_op1;
    logic [7:0] next_ssdec;
    logic next_sign;

    always_ff @( posedge clk, negedge nrst ) begin
        if (~nrst) begin
            op1 <= 0;
            ssdec <= 0;
            sign <= 0;
        end
        else begin
            op1 <= next_op1;
            ssdec <= next_ssdec;
            sign <= next_sign;
        end
    end

    always_comb begin
        next_op1 = op1;
        if(store_digit) begin
            next_op1 = digit;
        end
        else if (enter)
            next_op1 = 0;
    end

  always_comb begin
    next_sign = sign;
    if(store_digit) begin
        next_ssdec = next_op1[7:0];
        next_sign  = next_op1[8];
    end
    else if (enter) begin
        next_ssdec = 0;
        next_sign = 0;
    end
    else if (result_ready) begin
        next_ssdec = result[7:0];
        next_sign = result[8];
    end
    else
        next_ssdec = ssdec;
    end
    
    // assign next_ssdec = op1[7:0];
endmodule