module read_fsm(
    input logic clk, nrst, r_en
    input logic [2:0] reg_num, opcode;
    output logic [2:0] reg_sel, 
    output logic alu_en
);

    typedef enum logic [1:0] { IDLE, EN, REG1, IDLE2, REG2, IDLE3, RESULT } state_t;
    state_t state, next_state;
    logic next_alu_en;
    logic [2:0] next_reg_sel;

    always_ff @(posedge clk, negedge n_rst) begin
        if (~nrst) begin
            state <= 'b0;
            reg_sel <= 'b0;
            alu_en <= 'b0;
        end else begin
            state <= next_state;
            reg_sel <= next_reg_sel;
            alu_en <= next_alu_en;
        end
    end

    // Next State Logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE:  if (en) next_state = EN;
            EN:    if (reg_num) next_state = REG1;
            REG1:  next_state = IDLE2;
            IDLE2: if (reg_num) next_state = REG2;
            REG2:  next_state = IDLE3
            IDLE3: if (opcode) next_state = RESULT;
            RESULT: next_state = IDLE;
        endcase
    end

    // Output Logic
    always_comb begin
        next_alu_en = 1'b0;
        next_reg_sel =reg_sel;
        case (next_state)
            REG1: next_reg_sel = reg_num;
            REG2: next_reg_sel = reg_num;
            RESULT : next_alu_en = 1'b1;
        endcase
    end

endmodule