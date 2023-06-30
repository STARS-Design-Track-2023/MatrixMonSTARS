module reg_file
(
    input  logic  clk , nrst, write,
    input  logic [2:0] reg_num, reg_sel,
    input  logic [8:0] op,
    output logic [8:0] reg_val
);    // reg files
    logic [8:0] reg1, reg2, reg3, reg4;    // Intermediate Signals
    logic [8:0] next_reg1, next_reg2, next_reg_val, next_reg3, next_reg4;    // Write to the register file
    always_ff @(posedge clk, negedge nrst) begin
        if (~nrst) begin
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
        next_reg_val = reg_val;      // Write to reg file
        if(write) begin
            case (reg_num)
                3'd1: next_reg1 = op;
                3'd2: next_reg2 = op;
                3'd3: next_reg3 = op;
                3'd4: next_reg4 = op;
            endcase        // read from the reg file
        end
        case (reg_sel)
            3'd1: next_reg_val = reg1;
            3'd2: next_reg_val = reg2;
            3'd3: next_reg_val = reg3;
            3'd4: next_reg_val = reg4;
        endcase
    end
    endmodule