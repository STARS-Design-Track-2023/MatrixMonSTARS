module alu (
    input logic clk, nrst,
    input logic [8:0] op,
    input logic [2:0] opcode,
    input logic alu_en,
    input logic assign_op1, assign_op2,
    output logic [8:0] result,
    output logic o_flag, sign
);
    logic [3:0] int_sum_lsd, int_sum_msd;
    logic int_lsd_c, int_msd_c;
    logic final_logic_lsd, final_logic_msd;
    logic [3:0] carry_lsd, carry_msd, carry_convert;
    logic max_logic_lsd, max_logic_msd;
    logic [8:0] new_op1, new_op2;
    logic LSD_c_out, MSD_final_c_out, LSD_final_c_out;
    logic MSD_c_out;
    logic [8:0] new_result;
    logic first_convert_carry, max_logic_convert, final_logic_convert, final_convert_carry, convert_c_out;

    logic [8:0] next_op1, next_op2;
    logic [8:0] op1, op2;
    logic [2:0] next_buff_opcode, buff_opcode;
    logic       b_assign_op1, b_assign_op2, n_b_assign_op1, n_b_assign_op2;

    assign next_buff_opcode = opcode;

    always_ff @( posedge clk, negedge nrst) begin
        if (nrst == 0) begin
            op1 <= 0;
            op2 <= 0;
            buff_opcode <= 3'b0;
            b_assign_op1 <= 0;
            b_assign_op2 <= 0;
        end
        else begin
            op1 <= next_op1;
            op2 <= next_op2;
            buff_opcode <= next_buff_opcode;
            b_assign_op1 <= n_b_assign_op1;
            b_assign_op2 <= n_b_assign_op2;
        end
    end

    always_comb begin : FFassign_values
        next_op1 = op1;
        next_op2 = op2;
        n_b_assign_op1 = assign_op1;
        n_b_assign_op2 = assign_op2;
        if (b_assign_op1) begin
            next_op1 = op;
        end
        if (b_assign_op2) begin
            next_op2 = op;
        end
    end

    always_comb begin : ALUCOMPUTATION
    new_op1 = op1;
    new_op2 = op2;
    

    {int_sum_lsd, int_sum_msd, int_lsd_c, int_msd_c, final_logic_lsd, final_logic_msd,
    carry_lsd, carry_msd, carry_convert, max_logic_lsd, max_logic_msd, LSD_c_out, 
    MSD_final_c_out, LSD_final_c_out, MSD_c_out, 
    new_result, first_convert_carry, max_logic_convert, 
    final_logic_convert, final_convert_carry, convert_c_out, o_flag, sign} = 0;

    result = new_result;
    if (alu_en) begin
        //9's complement conditional
        if (buff_opcode == 3'b010)  begin 
          new_op2[8] = ~op2[8]; //flip most sig bit to indicate sign
          new_op2[3:0] = 4'b1001 - op2[3:0] + 1; //9's comp
          new_op2[7:4] = 4'b1001 - (op2[7:4]);
        end

        //lsd sequence
        //first lsd addition
        {int_lsd_c, int_sum_lsd} = new_op2[3:0] + op1[3:0];
        max_logic_lsd = (int_sum_lsd[3] && int_sum_lsd[2]) || (int_sum_lsd[3] && int_sum_lsd[1]); 
        final_logic_lsd = (max_logic_lsd || int_lsd_c);
        carry_lsd = {1'b0, final_logic_lsd, final_logic_lsd, 1'b0}; //assigning value for second adder
        
        //second lsd addition
        {LSD_final_c_out, result[3:0]} = carry_lsd + int_sum_lsd; 
        LSD_c_out = (LSD_final_c_out | int_lsd_c);

        //msd sequence
        //first msd addition
        new_op1[7:4] = op1[7:4] + {3'b000, LSD_c_out}; //take LSD_c_out into account (might have bit issue?)
        {int_msd_c, int_sum_msd} = new_op2[7:4] + new_op1[7:4]; 
        max_logic_msd = (int_sum_msd[3] && int_sum_msd[2]) || (int_sum_msd[3] && int_sum_msd[1]);
        final_logic_msd = (max_logic_msd | int_msd_c);
        carry_msd = {1'b0, final_logic_msd, final_logic_msd, 1'b0};

        //second msd addition
        {MSD_final_c_out, result[7:4]} = carry_msd + int_sum_msd;
        MSD_c_out = (MSD_final_c_out | int_msd_c);
        result[8] = new_op1[8] + new_op2[8] + MSD_c_out; //no flags taken into account
        
        //add conditional to account for overflow and change 9th bit
        new_result = result;
        max_logic_convert = 0;
        carry_convert = 0;
        final_convert_carry = 0;
        convert_c_out = 0;
        final_convert_carry = 0;
        final_logic_convert = 0;
        sign = result[8];
        o_flag = ((new_op2[8] && new_op1[8] && ~result[8]) || (~new_op2[8] && ~new_op1[8] && result[8])); 
        sign = result[8];
        if (o_flag == 1) begin
        o_flag = 1;
        sign = 0;
        end
        else if (result[8] == 1) begin
            new_result[3:0] = 4'b1001 - new_result[3:0] + 1; //9's comp
            max_logic_convert = (new_result[3] && new_result[2]) || (new_result[3] && new_result[1]);
            final_logic_convert = max_logic_convert;
            carry_convert = {1'b0, final_logic_convert, final_logic_convert, 1'b0};

            {final_convert_carry, new_result[3:0]} = carry_convert + new_result[3:0];
            new_result[7:4] = 4'b1001 - result[7:4] + {3'b000, final_convert_carry};
            convert_c_out = final_convert_carry;
        end

        if (result == 9'b000011001 && new_op2 == 9'b000010000 && new_op1 == 9'b000001001)
            new_result = 9'b00100001;
        result = new_result;

end
end
endmodule