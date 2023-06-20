module alu (
    input logic [7:0] op1, op2
    input logic [1:0] opcode,
    output logic msb_carry_out,
    output logic [7:0] result
):
    logic [3:0] int_sum_lsd, int_sum_msd;
    logic [3:0] carry_lsd, carry_msd;
    logic carry_logic_lsd, carry_logic_msd;
    logic LSD_c_out;

    always_ff @( clock ) begin : blockName
    end

    always_comb begin : ALUCOMPUTATION

        //two's complement conditional
        if (opcode[1]) begin 
            op2[3:0] = ~op2[3:0] + 1;
            op2[7:4] = ~op2[7:4] + 1;
        end

        //lsd sequence
        //first lsd addition
        int_sum_lsd = op2[3:0] + op1[3:0];
        carry_logic_lsd = (int_sum_lsd[3] & int_sum_lsd[2]) | (int_sum_lsd[3] & int_sum_lsd[1]);
        carry_lsd = {1'b0, carry_logic_lsd, carry_logic_lsd, 1'b0}; //assigning value for second adder
        
        //second lsd addition
        {LSD_c_out[4], result[3:0]} = carry_lsd + int_sum_lsd; //check this concatenation method

        //msd sequence
        //first msd addition
        int_sum_msd = op2[7:4] + op1[7:4]; //how to take LSD_c_out into account here?
        carry_logic_msd = (int_sum_msd[3] & int_sum_msd[2]) | (int_sum_msd[3] & int_sum_msd[1]);
        carry_msd = {1'b0, carry_logic_msd, carry_logic_msd, 1'b0};

        //second msd addition
    end

endmodule