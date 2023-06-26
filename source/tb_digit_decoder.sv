`timescale 1ns/10ps

module tb_key_encoder();
    localparam CLK_PERIOD =100;
    // Declare Test Case Signals
    integer tb_test_num;
    string tb_test_case;
    logic tb_mismatch;
    logic tb_check;

    // Declare DUT Connection Signals
    logic tb_clk;
    logic tb_nrst;
    logic tb_keystrobe;
    logic [3:0] tb_keycode;
    logic tb_isdig;
    logic [3:0] tb_digitCode;

    // Declare the Test Bench Signals for Expected Results
    logic tb_isdig_expected;
    logic [3:0] tb_digitCode_expected;

    task reset_dut;
    begin
        //Activate the reset
        tb_nrst = 1'b0;
        @(posedge tb_clk);
        @(posedge tb_clk);

        //Wait until safely away from rising edge of the clk
        @(negedge tb_clk);
        tb_nrst = 1'b1;

        // Leave out of reset for a couple cycles before allowing other
        // Wait for negative clock edges,
        // since inputs to DUT should normally be applied away from rising edge
        @(negedge tb_clk);
        @(negedge tb_clk);
    end
    endtask
    task check_output_keycode;
        input string check_tag;
    begin
        tb_check = 1'b1;
        tb_mismatch = 1'b0;
        if(tb_digitCode_expected == tb_digitCode) begin
            $display("Correct code output %swhen tested. This case is called %s", tb_check, check_tag);
        end
        else begin
            $error("Incorrect code output %swhen tested. This case is called %s", tb_mismatch, check_tag);
        end
    end
    endtask

    task check_output_isdig;
        input string check_tag;
    begin
        tb_check = 1'b1;
        tb_mismatch = 1'b0;
        if(tb_isdig_expected == tb_isdig) begin
            $display("Correct strobe utput %s when tested. This case is called %s", tb_check, check_tag);
        end
        else begin
            $error("Incorrect strobe output %s when tested. Thus case is called %s", tb_mismatch, check_tag);
        end
    end
    endtask

    task inactivate_signals;
    begin
        tb_keycode = 4'b0;
        tb_isdig_expected = 0;
        tb_digitCode_expected = 4'b0;
    end
    endtask

always begin
    tb_clk = 1'b0;
    #(CLK_PERIOD/2.0);
    tb_clk = 1'b1;
    #(CLK_PERIOD/2.0);
end
    digit_decoder DUT
    (
        .clk(tb_clk),
        .nrst(tb_nrst),
        .keystrobe(tb_keystrobe),
        .keycode(tb_keycode),
        .isdig(tb_isdig),
        .digitCode(tb_digitCode)
    );

    initial begin
        $dumpfile ("dump.vcd");
        $dumpvars;
    end

    initial begin
        #(0.1);
        reset_dut();
        inactivate_signals();
        tb_test_num = tb_test_num + 1;
        tb_nrst = 0;
        tb_keystrobe = 1;
        tb_keycode = 4'b1001;
        tb_digitCode_expected = 4'b0000;
        tb_isdig_expected = 0;
        @(posedge tb_clk);
        @(negedge tb_clk);
        check_output_keycode("power on RESET.");
        check_output_isdig("power on RESET.");

        #(0.1);
        reset_dut();
        inactivate_signals();
        tb_test_num = tb_test_num + 1;
        tb_keystrobe = 0;
        tb_keycode = 4'b1010;
        tb_digitCode_expected = 4'b0000;
        tb_isdig_expected = 0;
        @(posedge tb_clk);
        @(negedge tb_clk);
        check_output_keycode("strobe 0 and keyinput 10.");
        check_output_isdig("strobe 0 and keyinput 10.");

        #(0.1);
        reset_dut();
        inactivate_signals();
        tb_test_num = tb_test_num + 1;
        tb_keystrobe = 0;
        tb_keycode = 4'b0011;
        tb_digitCode_expected = 4'b0000;
        tb_isdig_expected = 0;
        @(posedge tb_clk);
        @(negedge tb_clk);
        check_output_keycode("strobe 0 and keyinput 3.");
        check_output_isdig("strobe 0 and keyinput 3.");

        #(0.1);
        reset_dut();
        inactivate_signals();
        tb_test_num = tb_test_num + 1;
        tb_keystrobe = 0;
        tb_keycode = 4'b1001;
        tb_digitCode_expected = 4'b0000;
        tb_isdig_expected = 0;
        @(posedge tb_clk);
        @(negedge tb_clk);
        check_output_keycode("strobe 0 and keyinput 9.");
        check_output_isdig("strobe 0 and keyinput 9.");

        #(0.1);
        reset_dut();
        inactivate_signals();
        tb_test_num = tb_test_num + 1;
        tb_keystrobe = 0;
        tb_keycode = 4'b0111;
        tb_digitCode_expected = 4'b0000;
        tb_isdig_expected = 0;
        @(posedge tb_clk);
        @(negedge tb_clk);
        check_output_keycode("strobe 0 and keyinput 7.");
        check_output_isdig("strobe 0 and keyinput 7.");

        #(0.1);
        reset_dut();
        inactivate_signals();
        tb_test_num = tb_test_num + 1;
        tb_keystrobe = 0;
        tb_keycode = 4'b1011;
        tb_digitCode_expected = 4'b0000;
        tb_isdig_expected = 0;
        @(posedge tb_clk);
        @(negedge tb_clk);
        check_output_keycode("strobe 0 and keyinput 11.");
        check_output_isdig("strobe 0 and keyinput 11.");

        #(0.1);
        reset_dut();
        inactivate_signals();
        tb_test_num = tb_test_num + 1;
        tb_keystrobe = 1;
        tb_keycode = 4'b1001;
        tb_digitCode_expected = 4'b1001;
        tb_isdig_expected = 1;
        @(posedge tb_clk);
        @(negedge tb_clk);
        check_output_keycode("strobe 1 and keyinput 9.");
        check_output_isdig("strobe 1 and keyinput 9.");

        #(0.1);
        reset_dut();
        inactivate_signals();
        tb_test_num = tb_test_num + 1;
        tb_keystrobe = 1;
        tb_keycode = 4'b1010;
        tb_digitCode_expected = 4'b0000;
        tb_isdig_expected = 0;
        @(posedge tb_clk);
        @(negedge tb_clk);
        check_output_keycode("strobe 1 and keyinput 10.");
        check_output_isdig("strobe 1 and keyinput 10.");

        #(0.1);
        reset_dut();
        inactivate_signals();
        tb_test_num = tb_test_num + 1;
        tb_keystrobe = 1;
        tb_keycode = 4'b1100;
        tb_digitCode_expected = 4'b0000;
        tb_isdig_expected = 0;
        @(posedge tb_clk);
        @(negedge tb_clk);
        check_output_keycode("strobe 1 and keyinput 12.");
        check_output_isdig("strobe 1 and keyinput 12.");

        #(0.1);
        reset_dut();
        inactivate_signals();
        tb_test_num = tb_test_num + 1;
        tb_keystrobe = 1;
        tb_keycode = 4'b0001;
        tb_digitCode_expected = 4'b0001;
        tb_isdig_expected = 1;
        @(posedge tb_clk);
        @(negedge tb_clk);
        check_output_keycode("strobe 1 and keyinput 1.");
        check_output_isdig("strobe 1 and keyinput 1.");

        #(0.1);
        reset_dut();
        inactivate_signals();
        tb_test_num = tb_test_num + 1;
        tb_keystrobe = 1;
        tb_keycode = 4'b0010;
        tb_digitCode_expected = 4'b0010;
        tb_isdig_expected = 1;
        @(posedge tb_clk);
        @(negedge tb_clk);
        check_output_keycode("strobe 1 and keyinput 2.");
        check_output_isdig("strobe 1 and keyinput 2.");

        #(0.1);
        reset_dut();
        inactivate_signals();
        tb_test_num = tb_test_num + 1;
        tb_keystrobe = 1;
        tb_keycode = 4'b1000;
        tb_digitCode_expected = 4'b1000;
        tb_isdig_expected = 1;
        @(posedge tb_clk);
        @(negedge tb_clk);
        check_output_keycode("strobe 1 and keyinput 8.");
        check_output_isdig("strobe 1 and keyinput 8.");

    $finish;
    end
endmodule