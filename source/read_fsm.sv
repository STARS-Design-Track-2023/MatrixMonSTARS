module read_fsm
(
    input logic clk, nrst, r_en,
    input logic [2:0] reg_num, opcode,
    output logic [2:0] reg_sel, 
    output logic alu_en,
    output logic assign_op1, assign_op2,
    output logic result_ready
);

    // State Machine
    typedef enum logic [2:0] {IDLE, EN, REG1, IDLE2, REG2, IDLE3, RESULT } state_t;

    // Intermediate Signals
    state_t state, next_state;
    logic   p_r_en;

    
    // Edge detection for the read
    sync_edge_detector s_e_detect
    (
        .clk(clk),
        .nrst(nrst),
        .signal(r_en),
        .p_edge(p_r_en)
    );

    always_ff @(posedge clk, negedge nrst) begin
        if (~nrst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next State Logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE:  if (p_r_en) next_state = EN;
            EN:    if (|reg_num) next_state = REG1;
            REG1:  next_state = IDLE2;
            IDLE2: if (|reg_num) next_state = REG2;
            REG2:  next_state = IDLE3;
            IDLE3: if (|opcode) next_state = RESULT;
            RESULT: next_state = IDLE;
        endcase
    end

    // Output Logic
    always_comb begin
        alu_en = 1'b0;
        assign_op1 = 1'b0;
        assign_op2 = 1'b0;
        result_ready = 1'b0;
        case (state)
            REG1: begin
                  assign_op1 = 1'b1;
                  end
            REG2: begin
                  assign_op2 = 1'b1;
                  end

            RESULT : begin
                     alu_en = 1'b1;
                     result_ready = 1'b1;
                     end
        endcase
    end

    always_comb begin
        reg_sel = 3'b0;
        case (next_state)
            REG1: reg_sel = reg_num;
            REG2: reg_sel = reg_num;
        endcase
    end

endmodule