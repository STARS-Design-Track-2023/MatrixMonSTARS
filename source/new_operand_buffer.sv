module new_operand_buffer(
    input logic clk, nrst,
    input logic [8:0] result,
    input logic store_digit, is_reg, result_ready,
    input logic [3:0] digit,
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
        next_sign = result[8];
        next_op1 = op1;
        if(store_digit)
            next_op1 = {1'b0, op1[3:0], digit};
        else if (is_reg)
            next_op1 = 0;
    end

  always_comb begin
    if(store_digit)
        next_ssdec = next_op1[7:0];
    else if (is_reg)
        next_ssdec = 0;
    else if (result_ready)
        next_ssdec = result[7:0];
    else
        next_ssdec = ssdec;
    end
    
    // assign next_ssdec = op1[7:0];
endmodule