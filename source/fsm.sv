module fsm (
  input logic key_strobe, is_op, is_dig, is_result, is_enter, clk, nrst,
  input logic [2:0] opcode, 
output logic store_dig, enter, result_ready
);

logic [2:0] state, next_state;
typedef enum logic [2:0] {s0, s1, s2, s3, s4, s5, s6} state_t;

  always_ff @(posedge clk, negedge nrst) begin : flipflop
    if (nrst == 0)
    state <= s0;
else 
    state <= next_state;
    
end

// always_comb begin : FSMLogicBlock
//     next_state = state;
//     case(state)
//     s0: begin 
//         if (is_dig) // s0 = idle1
//         next_state = s1;
//         else
//         next_state = s0;
//         end
//     s1: next_state = s2; // s1 = dig 1, moves immediately to s2
//     s2: begin 
//         if (is_dig) // s2 = idle2
//         next_state = s3;
//         else
//         next_state = s2;
//         end
//     s3: next_state = s4; // s3 = dig 2, moves immediately to s4
//     s4: begin            
//         if (is_op) // s4 = idle3 
//         next_state = s5;
//         else if (is_dig == 1)
//         next_state = s6;
//         else
//         next_state = state;
//         end
//     s5: next_state = s0; // s5 = result
//     s6: next_state = s0; // s6 = enter
//     default: next_state = state;
//     endcase
// end

always_comb begin : FSMLogicBlock
    next_state = state;
    case(state)
    s0: begin 
        if (is_dig) // s0 = idle1
        next_state = s1;
        else
        next_state = s0;
        end
    s1: next_state = s2; // s1 = dig 1, moves immediately to s2
    s2: begin 
        if (is_dig) // s2 = idle2
        next_state = s3;
        else
        next_state = s2;
        end
    s3: next_state = s4; // s3 = dig 2, moves immediately to s4
    s4: begin            
        if (is_op && is_enter) // s4 = idle3 
        next_state = s6;
        else if (is_op && is_result)
        next_state = s5;
        else
        next_state = state;
        end
    s5: next_state = s0; // s5 = result
    s6: next_state = s0; // s6 = enter
    default: next_state = state;
    endcase
end

always_comb
begin
        if ((state == s1) || (state == s3)) // dig1 and and dig 2 states 
        begin
            store_dig = 1;
            enter = 0;
            result_ready = 0;
        end 
        else if (state == s6) // enter state
        begin
            store_dig = 0;
            enter = 1;
            result_ready = 0;
        end 
        else if (state == s5) // result state 
        begin
            store_dig = 0;
            enter = 0;
            result_ready = 1;
        end 
        else
        begin
            store_dig = 0;
            enter = 0;
            result_ready = 0;
        end 
end
endmodule 