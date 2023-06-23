`timescale 1ns/10ps

module tb_key_encoder();
    localparam CLK_PERIOD = 100;
    localparam RESET_EXPECTED_STROBE = 0;
    localparam RESET_EXPECTED_CODE = 4'b0;
    //Declare Test Case Signals
    integer tb_test_num;
    string tb_test_case;
    string tb_stream_check_tag;
    int tb_bit_num;
    logic tb_mismatch;
    logic tb_check;

    // Declare DUT Connection Signals
    logic tb_clk;
    logic tb_nrst;
    logic [12:0] tb_keypad;
    logic [3:0] tb_keycode;
    logic tb_keystrobe;

    //Declare the Test Bench Signals for Expected Results
    logic [3:0] tb_key_code_expected;
    logic tb_expected_keystrobe;

    // Task for standard DUT reset procedure
    task reset_dut;
    begin
        //Activate the reset
        tb_nrst = 1'b0;

        // Maintain the reset for more than one cycle
        @(posedge tb_clk);
        @(posedge tb_clk);

        // Wait until safely away from rising edge of the clk
        @(negedge tb_clk);
        tb_nrst = 1'b1;

        // Leave out of reset for a couple cycles before allowing other stimulus
        // Wait for negative clock edges,
        // since inputs to DUT should normally be applied away from rising clk edges
        @(negedge tb_clk);
        @(negedge tb_clk);
    end
    endtask

    task check_output_keycode;
        input string check_tag;
    begin
        tb_check = 1'b1;
        tb_mismatch = 1'b0;
        if(tb_key_code_expected == tb_keycode) begin
            $display("Correct output %s when tested. This case is called %s", tb_check, check_tag);
        end
        else begin
            $error("Incorrect output %s when tested. This case is called %s", tb_mismatch, check_tag);
        end
    end
    endtask

    task check_output_strobe;
        input string check_tag;
        begin
            tb_check = 1'b1;
            tb_mismatch = 1'b0;
        if(tb_expected_keystrobe == tb_keystrobe) begin
            $display("Correct Strobe ouput %s when tested. This case is called %s",tb_check, check_tag);
        end
        else begin
            $error("Incorrect Strobe output %s when tested. This case is called %s", tb_mismatch, check_tag);
        end
        end
    endtask
    task inactivate_signals;
    begin
        tb_keypad = 13'b0;
        tb_expected_keystrobe = 0;
        tb_key_code_expected = 4'b0;
    end
    endtask

    always begin
        tb_clk = 1'b0;
        #(CLK_PERIOD/2.0);
        tb_clk = 1'b1;
        #(CLK_PERIOD/2.0);
    end

    key_encoder DUT
    (
        .clk(tb_clk),
        .nrst(tb_nrst),
        .keypad(tb_keypad),
        .keycode(tb_keycode),
        .keystrobe(tb_keystrobe)
    );

    initial begin
       $dumpfile ("dump.vcd");
       $dumpvars;
    end

    initial begin
    tb_nrst = 1'b1;
    tb_keypad = 13'b0000000000000;
    tb_test_num = -1;
    #(0.1);

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Power on RESET";
    reset_dut;
    #(CLK_PERIOD * 0.5);
    tb_expected_keystrobe = RESET_EXPECTED_STROBE;
    tb_key_code_expected = RESET_EXPECTED_CODE;
    check_output_keycode("after reset applied");
    check_output_strobe("after reset applied");
    #(CLK_PERIOD);
    check_output_keycode("after clock cycle while in reset");
    check_output_strobe("after clock cycle while in reset");


    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing input 0.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b0000000000001;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b0000;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it 0 case.");
    check_output_strobe("is it 0 case.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing input 1.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b0000000000010;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b0001;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it 1 case.");
    check_output_strobe("is it 1 case.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing input 2.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b0000000000100;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b0010;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it 2 case.");
    check_output_strobe("is it 2 case.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing input 3.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b0000000001000;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b0011;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it 3 case.");
    check_output_strobe("is it 3 case.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing input 4.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b0000000010000;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b0100;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it 4 case.");
    check_output_strobe("is it 4 case.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing input 5.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b0000000100000;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b0101;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it 5 case.");
    check_output_strobe("is it 5 case.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing input 6.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b0000001000000;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b0110;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it 6 case.");
    check_output_strobe("is it 6 case.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing input 7.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b0000010000000;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b0111;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it 7 case.");
    check_output_strobe("is it 7 case.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing input 8.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b0000100000000;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b1000;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it 8 case.");
    check_output_strobe("is it 8 case.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing input 9.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b0001000000000;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b1001;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it 9 case.");
    check_output_strobe("is it 9 case.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing addition.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b0010000000000;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b1010;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it addition case.");
    check_output_strobe("is it addition case.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing input subtraction.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b0100000000000;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b1011;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it subtraction case.");
    check_output_strobe("is it subtraction case.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing enter.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b1000000000000;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b1100;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it enter.");
    check_output_strobe("is it enter.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing more than 2 buttons press.";
    inactivate_signals();
    reset_dut();
    tb_keypad = 13'b0000000000011;
    tb_expected_keystrobe = 1;
    tb_key_code_expected = 4'b1111;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it two press.");
    check_output_strobe("is it two press.");

    tb_test_num = tb_test_num + 1;
    tb_test_case = "Testing button press with reset press.";
    inactivate_signals();
    reset_dut();
    tb_nrst = 0;
    tb_keypad = 13'b0000000000010;
    tb_expected_keystrobe = 0;
    tb_key_code_expected = 4'b0000;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    check_output_keycode("is it reset press.");
    check_output_strobe("is it reset press.");
    $finish; 
    $finish; 
    end
endmodule
