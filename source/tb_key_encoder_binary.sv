`timescale 1ns/10ps

module tb_key_encoder_binary();
    localparam CLK_PERIOD = 100;
    // Declare Test Case Signals
    integer tb_test_num;
    string tb_test_case;
    logic tb_mismatch;
    logic tb_check;

    // Declare DUT Connection Signals
    logic tb_clk;
    logic tb_nrst;
    logic [1:0] tb_keypad;
    logic tb_move_on;
    logic [3:0] tb_keycode;

    // Declare the Test Bench Signals for Expected Results
    logic tb_isdig_expected;
    logic [3:0] tb_keycode_expected;
    logic tb_move_on_expected;

    task reset_dut();
    begin
        tb_nrst = 1'b0;
        @(posedge tb_clk);
        @(posedge tb_clk);

        // Wait until safely away from rising edge of clk
        @(negedge tb_clk);
        tb_nrst = 1'b1;
        @(negedge tb_clk);
        @(negedge tb_clk);
    end
    endtask

    task check_output_keycode;
        input string check_tag;
    begin
        tb_check = 1'b1;
        tb_mismatch = 1'b0;
        if(tb_keycode_expected == tb_keycode) begin
            $display("Correct code output %swhen tested. Ths case is called %s", tb_check, check_tag);
        end
        else begin
            $error("Incorrect code output %swhen tested. This case is called %s", tb_mismatch, check_tag);
        end
    end
    endtask

    task check_output_move_on;
        input string check_tag;
    begin
        tb_check = 1'b1;
        tb_mismatch = 1'b0;
        if(tb_move_on_expected == tb_move_on) begin
            $display("Correct strobe output %swhen tested. This case is called %s", tb_check, check_tag);
        end
        else begin
            $error("Incorrect strobe output %swhen tested. This case is called %s", tb_mismatch, check_tag);
        end
    end
    endtask

    task inactivate_signals;
    begin
        tb_keypad = 2'b0;

        tb_move_on_expected = 0;
        tb_keycode_expected = 4'b0;
    end
    endtask

    always begin
        tb_clk = 1'b0;
        #(CLK_PERIOD/2.0);
        tb_clk = 1'b1;
        #(CLK_PERIOD/2.0);
    end

    key_encoder_binary DUT
    (
        .clk(tb_clk),
        .nrst(tb_nrst),
        .keypad(tb_keypad),
        .keycode(tb_keycode),
        .move_on(tb_move_on)
    );

    initial begin
        $dumpfile ("dump.vcd");
        $dumpvars;
    end

    initial begin
        #(0.1)
        tb_nrst = 1;
        tb_keypad = 2'b00;
        #(0.1)
        reset_dut();
        inactivate_signals();
        tb_test_num = tb_test_num + 1;
        tb_nrst = 1;
        tb_keypad = 2'b10;
        tb_keycode_expected = 4'b0001;
        tb_move_on_expected = 0;
        @(posedge tb_clk);
        @(posedge tb_clk);
        @(posedge tb_clk);
        @(negedge tb_clk);

        // tb_keypad = 2'b01;
        // tb_keycode_expected = 4'b0010;
        // tb_move_on_expected = 0;
        // @(posedge tb_clk);
        // @(posedge tb_clk);
        // @(negedge tb_clk);
        check_output_keycode("state 1");
        check_output_move_on("state 1");

        $finish;
    end
endmodule