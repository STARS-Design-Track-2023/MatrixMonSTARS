// FSM module block 

module WriteFSM (
input logic key_strobe, isop, isdig, isreg, clk, rst,
output logic store_dig, reg_num, result_ready
);

logic [2:0] state, next_state;
typedef enum logic [2:0] {idle1, dig1, idle2, dig2, idle3, assign_reg, result} state_t;

always_ff @(posedge clk, posedge rst) begin : flipflop
if (rst == 0)
    state <= next_state;
else 
    state <= idle1;
    
end

always_comb begin : FSMLogicBlock

if(key_strobe)
begin
    case(state)
    idle1: begin 
        if ((isdig && (isop == 0)) && (isreg == 0)) // idle1 = idle1
        next_state = dig1;
        else
        next_state = idle1;
        end
    dig1: next_state = idle2; //   dig1 = dig 1, moves immediately to idle2
    idle2: begin 
        if ((isdig && (isop == 0)) && (isreg == 0)) // idle2 = idle2
        next_state = dig2;
        else
        next_state = idle2;
        end
    dig2: next_state =  idle3; // dig2 = dig 2, moves immediately to   idle3
    idle3: begin            
        if (((isdig == 0) && (isop == 0)) && ( isreg == 1)) //    idle3 = idle3 
        next_state = assign_reg;
        else if (((isdig == 0) && (isop == 1)) && ( isreg == 0))
        next_state = result;
        else
        next_state = state;
        end
    assign_reg: next_state = idle1; // assign_reg = result
    result: next_state = idle1;
    default: next_state = state;
    endcase
end
else
begin
    next_state = state;
end
end

always_comb
begin
    if (key_strobe)
    begin
        if ((state == dig1) || (state == dig2)) // dig1 and and dig 2 states 
        begin
            store_dig = 1;
            reg_num = 0;
            result_ready = 0;
        end 
        else if (state == assign_reg) // result state 
        begin
            store_dig = 0;
            reg_num = 1;
            result_ready  = 0;
        end 
        else if (state == result) // result state 
        begin
            store_dig = 0;
            reg_num = 0;
            result_ready  = 1;
        end 
        else
        begin
            store_dig = 0;
            reg_num = 0;
            result_ready = 0;
        end 
    end
    else
    begin
            store_dig = 0;
            reg_num = 0;
            result_ready = 0;
    end
end

endmodule 