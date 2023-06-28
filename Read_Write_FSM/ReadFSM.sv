module ReadFSM(
    input logic isreg, regvalue, clk, rst,
    output logic regout
);

logic [2:0] state, next_state;
typedef enum logic [2:0] {idle1, reg1, idle2, reg2} state_t;

always_ff @(posedge clk, posedge rst) begin : flipflop
if (rst == 0)
    state <= next_state;
else 
    state <= idle1;
    
end

always_comb begin : FSMLogicBlock
    case(state)
    idle1: next_state = isreg? reg1:idle1;
    reg1: next_state = idle2;
    idle2: next_state = isreg? reg2:idle2;
    reg2: next_state = idle1;
    endcase
end

always_comb
begin
    if (state == reg1) //|| (state == reg2))
    begin
    regout = regvalue;
    end
    else
    begin
    regout = 3'b000;
    end
end
endmodule