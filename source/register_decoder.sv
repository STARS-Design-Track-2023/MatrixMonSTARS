module register_decoder(
    input logic clk, nrst,
    input logic [3:0] register_button,
    output logic is_reg,
    output logic [2:0] reg_num
);

logic [3:0] reg_async, reg_sync, reg_i;
logic [2:0] next_reg_num;
always_ff @(posedge clk, negedge nrst) begin
    if(nrst == 0) begin
        reg_async <= 0;
        reg_sync  <= 0;
        reg_i     <= 0;
        reg_num   <= 0;
    end
    else begin
        reg_async <= register_button;
        reg_sync  <= reg_async;
        reg_i     <= reg_sync;
        reg_num   <= next_reg_num;
    end
end

always_comb begin
    if((|reg_sync) && ~(|reg_i)) begin
        is_reg = 1;
    end
    else begin
        is_reg = 0;
    end
end

always_comb begin
    if(is_reg) begin
        case(reg_sync)
            4'b0001: begin
                next_reg_num = 3'b001;
            end
            4'b0010: begin 
                next_reg_num = 3'b010;
            end
            4'b0100: begin
                next_reg_num = 3'b011;
            end
            4'b1000: begin 
                next_reg_num = 3'b100;
            end
            default: begin 
                next_reg_num = 3'd0;
            end
        endcase
    end
    else begin
        next_reg_num = 3'd0;
    end
end
endmodule