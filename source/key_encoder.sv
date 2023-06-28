module key_encoder(
    input logic clk,nrst,
    input logic [12:0] keypad,
    output logic [3:0] keycode,
    output logic keystrobe
);
    logic [12:0] key_pad_async_13, key_pad_sync_13, key_pad_i_13;
    always_ff @(posedge clk, negedge nrst) begin
        if(0 == nrst) begin
            key_pad_async_13 <= 0;
            key_pad_sync_13 <= 0;
            key_pad_i_13 <= 0;
        end
        else begin
            key_pad_async_13 <= keypad;
            key_pad_sync_13 <= key_pad_async_13;
            key_pad_i_13 <= key_pad_sync_13;
        end
    end

    always_comb begin
        if((|key_pad_sync_13) && ~(|key_pad_i_13)) begin
            keystrobe = 1;
        end
        else begin
            keystrobe = 0;
        end
    end

    always_comb begin
        if(keystrobe) begin
            case(key_pad_sync_13)
                13'b0000000000001: keycode = 4'b0000;
                13'b0000000000010: keycode = 4'b0001;
                13'b0000000000100: keycode = 4'b0010;
                13'b0000000001000: keycode = 4'b0011;
                13'b0000000010000: keycode = 4'b0100;
                13'b0000000100000: keycode = 4'b0101;
                13'b0000001000000: keycode = 4'b0110;
                13'b0000010000000: keycode = 4'b0111;
                13'b0000100000000: keycode = 4'b1000;
                13'b0001000000000: keycode = 4'b1001;
                13'b0010000000000: keycode = 4'b1010;
                13'b0100000000000: keycode = 4'b1011;
                13'b1000000000000: keycode = 4'b1100;
                default: keycode = 4'b1111;
            endcase
        end
        else begin
            keycode = 4'b0000;
        end
    end
endmodule