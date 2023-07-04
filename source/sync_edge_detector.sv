module sync_edge_detector
(
    input  logic clk, nrst, signal,
    output logic p_edge 
);

    // Intermediate signals
    logic i_signal, s_signal, p_signal;

    always_ff @(posedge clk, negedge nrst) begin
        if (nrst == 0) begin
            i_signal <= 'b0;
            s_signal <= 'b0;
            p_signal <= 'b0;
        end else begin
            i_signal <= signal;
            s_signal <= i_signal;
            p_signal <= s_signal;
        end
    end

    // Combinational logic to detect rising edge
    assign p_edge = s_signal & ~p_signal;

endmodule