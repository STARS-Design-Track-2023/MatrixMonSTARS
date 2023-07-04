module keyencoder_binary
(
    input logic clk, nrst, is_op, is_result, is_enter, w_en, r_en, 
    input logic [1:0] keypad,
    output logic [8:0] keycode,
    output logic store_dig, enter, write_en
);

    // Declare Internal Signals
    logic [1:0] keypad_async, keypad_sync, keypad_i; 
    logic strobe,code_choice, use_code, p_w_en, p_r_en;
    logic [3:0] state, next_state;
    logic [8:0] partial_code;
  
  typedef enum logic [3:0] {write, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13} digit_state;

    // Flip Flops to syncronize, detect edge, and keep keycode
    always_ff @(posedge clk, negedge nrst) begin
        if(nrst == 0) begin
            keypad_async <= 2'b0;
            keypad_sync  <= 2'b0;
            keypad_i     <= 2'b0;
            state        <= write;
            keycode      <= 9'b0;
        end
        else begin
            keypad_async <= keypad;
            keypad_sync  <= keypad_async;
            keypad_i     <= keypad_sync;
            state        <= next_state;
            keycode      <= partial_code;
    end
    end

    // Edge detection for the write
    sync_edge_detector s_e_detect_w
    (
        .clk(clk),
        .nrst(nrst),
        .signal(w_en),
        .p_edge(p_w_en)
    );

    // Edge detection for the read
    sync_edge_detector s_e_detect_r
    (
        .clk(clk),
        .nrst(nrst),
        .signal(r_en),
        .p_edge(p_r_en)
    );

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
          write: begin
                if (p_w_en) 
                 next_state = s0;
                 else 
                 next_state = write;
                end
            s0: begin
                if(strobe) 
                    next_state = s1;
                else
                    next_state = s0;
            end
            s1: begin
                if(strobe)
                    next_state = s2;
                else
                    next_state = s1;
            end
            s2: begin
                if(strobe)
                    next_state = s3;
                else
                    next_state = s2;
            end
            s3: begin
                if(strobe)
                    next_state = s4;
                else 
                    next_state = s3;
            end
            s4: begin
                if(strobe)
                    next_state = s5;
                else 
                    next_state = s4;
            end
            s5: begin
                if(strobe)
                    next_state = s6;
                else
                    next_state = s5;
            end
            s6: begin
                if(strobe)
                    next_state = s7;
                else 
                    next_state = s6;
            end
            s7: begin
                if(strobe)
                    next_state = s8;
                else
                    next_state = s7;
            end
            s8: begin
                if(strobe)
                    next_state = s9;
                else
                    next_state = s8;
            end
            s9: next_state = s10;
            s10: begin
              if(is_enter) // if true, this means that a register button has been enabled
                next_state = s11;
              else if(is_op && is_result) 
                next_state = s12;
              else
                next_state = s10;
            end
            s11: next_state = s13; // num_enter state
            s12: next_state = s13; // result_ready state 
            s13: begin // checking if we are done registering numbers 
              if (r_en)
                next_state = write; // moves back to the protective write state
              else if (strobe) // continues tp register more values
                next_state = s1;
              else // waiting for decision
                next_state = s13;
            end
        endcase
    end 

    always_comb begin
        if(state == s9) begin
            store_dig = 1;
            enter = 0;
            write_en = 0;

            // result_ready = 0;
        end
        else if (state == s11) begin
            store_dig = 0;
            enter = 1;
            write_en = 1;

            // result_ready = 0;
        end
        else if (state == s12) begin
           store_dig = 0;
           enter = 0;
           write_en = 0;
        //    result_ready = 1;
        end
        else if (state == s10) begin
            store_dig = 0;
            enter = 0;
            write_en = 0;
        end
        else begin
            store_dig = 0;
            enter = 0;
            write_en = 0;
            // result_ready = 0;
        end
    end

    //Shift register logic. It shifts each input to create the code
    always_comb begin
        partial_code = keycode;
        if(use_code && strobe && (state != s10 || state != s11 || state != s12)) begin
            partial_code = {keycode[7:0], code_choice};
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