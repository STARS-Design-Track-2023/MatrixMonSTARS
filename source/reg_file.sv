module reg_file
(
    input  logic  clk , n_rst,
    input  logic [2:0] reg_num, reg_sel,
    input  logic [8:0] op1,
    output logic [8:0] reg_val
);    // reg files
    logic [8:0] reg1, reg2, reg3, reg4;    // Intermediate Signals
    logic [8:0] next_reg1, next_reg2, next_reg3, next_reg4, next_reg_val;    // Write to the register file
    always_ff @(posedge clk, negedge n_rst) begin
        if (~n_rst) begin
            reg1    <= 'b0;
            reg2    <= 'b0;
            reg3    <= 'b0;
            reg4    <= 'b0;
            reg_val <= 'b0;
        end else begin
            reg1    <= next_reg1;
            reg2    <= next_reg2;
            reg3    <= next_reg3;
            reg4    <= next_reg4;
            reg_val <= next_reg_val;
        end
    end    always_comb begin
        // Default Case
        next_reg1    = reg1;
        next_reg2    = reg2;
        next_reg3    = reg3;
        next_reg4    = reg4;
        next_reg_val = reg_val;        // Write to reg file
        case (reg_num)
            1: next_reg1 = op1;
            2: next_reg2 = op1;
            3: next_reg3 = op1;
            4: next_reg4 = op1;
        endcase        // read from the reg file
        case (reg_sel)
            1: next_reg_val = reg1;
            2: next_reg_val = reg2;
            3: next_reg_val = reg3;
            4: next_reg_val = reg4;
        endcase
    end
    endmodule


