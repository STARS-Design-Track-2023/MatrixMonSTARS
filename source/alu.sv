module alu (
    input logic [7:0] op1, op2,
    input logic [2:0] opcode,
    output logic MSD_c_out,
    output logic [7:0] result
);
    logic [3:0] int_sum_lsd, int_sum_msd;
    logic [3:0] int_lsd_c, int_msd_c;
    logic final_logic_lsd, final_logic_msd;
    logic [3:0] carry_lsd, carry_msd;
    logic max_logic_lsd, max_logic_msd;
    logic [7:0] new_op1, new_op2;
    logic LSD_c_out, MSD_final_c_out, LSD_final_c_out;

    always_comb begin : ALUCOMPUTATION
    new_op1 = op1;
    new_op2 = op2;

        //two's complement conditional
        if (opcode == 2'b10)  begin 
          new_op2[8] = ~op2[8]; //flip most sig bit to indicate sign
          new_op2[3:0] = 4'b1001 - (op2[3:0]) + 1; //9's comp
          new_op2[7:4] = 4'b1001 - (op2[7:4]);
        end

        //lsd sequence
        //first lsd addition
        {int_lsd_c, int_sum_lsd} = new_op2[3:0] + op1[3:0];
        max_logic_lsd = (int_sum_lsd[3] && int_sum_lsd[2]) || (int_sum_lsd[3] && int_sum_lsd[1]); 
        final_logic_lsd = (max_logic_lsd | int_lsd_c);
        carry_lsd = {1'b0, final_logic_lsd, final_logic_lsd, 1'b0}; //assigning value for second adder
        
        //second lsd addition
        {LSD_final_c_out, result[3:0]} = carry_lsd + int_sum_lsd; 
        LSD_c_out = (LSD_final_c_out | int_lsd_c);

        //msd sequence
        //first msd addition
        new_op1[7:4] = op1[7:4] + {3'b000, LSD_c_out}; //take LSD_c_out into account (might have bit issue?)
        {int_msd_c, int_sum_msd} = new_op2[7:4] + new_op1[7:4]; 
        max_logic_msd = (int_sum_msd[3] & int_sum_msd[2]) | (int_sum_msd[3] & int_sum_msd[1]);
        final_logic_msd = (max_logic_msd | int_msd_c);
        carry_msd = {1'b0, final_logic_msd, final_logic_msd, 1'b0};

        //second msd addition
        {MSD_final_c_out, result[7:4]} = carry_msd + int_sum_msd;
        MSD_c_out = (MSD_final_c_out | int_msd_c);
    end
endmodule






// always_comb begin : ALUCOMPUTATION
//     new_op1 = op1;
//     new_op2 = op2;

//         //two's complement conditional
//         if (opcode[1]) begin 
//             new_op2[3:0] = ~op2[3:0] + 1;
//             new_op2[7:4] = ~op2[7:4] + 1;
//         end

//         //lsd sequence
//         //first lsd addition
//         int_sum_lsd = new_op2[3:0] + op1[3:0];
//         max_logic_lsd = (int_sum_lsd[3] && int_sum_lsd[2]) || (int_sum_lsd[3] && int_sum_lsd[1]); //FIX THIS LINE
//         carry_lsd = {1'b0, max_logic_lsd, max_logic_lsd, 1'b0}; //assigning value for second adder
        
//         //second lsd addition
//         {LSD_c_out, result[3:0]} = carry_lsd + int_sum_lsd; //check this concatenation method

//         //msd sequence
//         //first msd addition
//         new_op1[7:4] = op1[7:4] + {3'b000, LSD_c_out}; //take LSD_c_out into account (might have bit issue?)
//         int_sum_msd = new_op2[7:4] + new_op1[7:4]; 
//         max_logic_msd = (int_sum_msd[3] & int_sum_msd[2]) | (int_sum_msd[3] & int_sum_msd[1]);
//         carry_msd = {1'b0, max_logic_msd, max_logic_msd, 1'b0};

//         //second msd addition
//         {MSD_c_out,result[7:4]} = carry_msd + int_sum_msd;
//     end
