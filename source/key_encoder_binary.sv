module key_encoder_binary(
    input logic clk, nrst, 
    input logic [1:0]keypad,
    output logic [3:0] keycode,
    output logic move_on
);

    // Declare Internal Signals
    logic [1:0] keypad_async, keypad_sync, keypad_i; 
    logic strobe, next_move_on,code_choice, use_code;
    logic [3:0] state, next_state, partial_code, next_partial_code, keycode_next;
    typedef enum logic [3:0] {s0, s1, s2, s3, s4, s5} digit_state;

    // Flip Flops to syncronize, detect edge, and keep keycode
    always_ff @(posedge clk, negedge nrst) begin
        if(nrst == 0) begin
            keypad_async <= 2'b0;
            keypad_sync  <= 2'b0;
            keypad_i     <= 2'b0;
            state        <= s0;
            keycode      <= 4'b0;
        end
        else begin
            keypad_async <= keypad;
            keypad_sync  <= keypad_async;
            keypad_i     <= keypad_sync;
            state        <= next_state;
            keycode      <= partial_code;
    end
    end

    // Edge detector logic. This detects a rising edge
    always_comb begin
        if((|keypad_sync) && ~(|keypad_i)) begin
            strobe = 1'b1;
        end
        else begin
            strobe = 1'b0;
        end
    end

    // FSM logic. It only moves forward if a strobe is detected
    always_comb begin
        next_state = state;
        case(state)
            s0: begin
                if(strobe) begin
                    next_state = s1;
                end
                else begin
                    next_state = s0;
                end
            end
            s1: begin
                if(strobe) begin
                    next_state = s2;
                end
                else begin
                    next_state = s1;
                end
            end
            s2: begin
                if(strobe) begin
                    next_state = s3;
                end
                else begin
                    next_state = s2;
                end
            end
            s3: begin
                if(strobe) begin
                    next_state = s4;
                end
                else begin
                    next_state = s3;
                end
            end
            s4: begin
                if(move_on) begin
                    next_state = s0;
                end
                else begin
                    next_state = s4;
                end
            end
            
            default: begin
                next_state = state;
            end
        endcase
    end  
    always_comb begin
        case(state)
            s0: move_on = 1'b0;
            s1: move_on = 1'b0;
            s2: move_on = 1'b0;
            s3: move_on = 1'b0;
            s4: move_on = 1'b1;
            default: move_on = 1'b0;
        endcase
    end
    //Shift register logic. It shifts each input to create the code
    always_comb begin
        partial_code = keycode;
        if(state == s0 && use_code && strobe) begin
            partial_code = {keycode[2:0], code_choice};
        end
        else if(state == s1 && use_code && strobe) begin
            partial_code = {keycode[2:0], code_choice};
        end
        else if(state == s2 && use_code && strobe) begin
            partial_code = {keycode[2:0], code_choice};
        end
        else if(state == s3 && use_code && strobe) begin
            partial_code = {keycode[2:0], code_choice};
        end
        else if(state == s4 && use_code && strobe) begin
            partial_code = {keycode[2:0], code_choice};
        end
    end

    // Assiges a value to the keycode
    always_comb begin
        if(strobe) begin
            case(keypad_sync)
                2'b01: begin
                    code_choice = 1'b0;
                    use_code = 1'b1;
                end
                2'b10: begin
                    code_choice = 1'b1;
                    use_code = 1'b1;
                end
                default: begin
                    code_choice = 1'b0;
                    use_code = 1'b0;
                end
            endcase
        end
        else begin
            code_choice = 1'b0;
            use_code = 1'b0;
        end
    end
endmodule