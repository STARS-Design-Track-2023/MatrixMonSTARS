// File name:   tb_calculator.v
// Author:      Vishnu Lagudu
// Description: Complete verification of the final calculator design (Non-synthesizable)

`timescale 1ns/10ps

module tb_calculator ();

    // clk period for 10 MHz clk
    localparam CLK_PERIOD         = 100;
    localparam RESET_OUTPUT_VALUE = 4'h0;

    // Declare Test Case Signals
    integer       tb_test_num;
    reg [1023:0]  tb_test_case;
    reg [1023:0]  tb_stream_check_tag;
    integer       tb_iter_val;
    reg           tb_mismatch;
    reg           tb_check;

    // DUT portmap signals
    reg         tb_clk; 
    reg         tb_nrst;
    reg  [9:0]  tb_pb;
    wire [13:0] tb_ss;
    wire        tb_red;
    wire        tb_blue;

    // Declare the Test Bench Signals for Expected Results
    reg [3:0] tb_expected_dig1;
    reg [3:0] tb_expected_dig2;
    reg       tb_expected_blue;
    reg       tb_expected_red;

    // Values for testing the seven segment displays
    // These values here are verified through an FPGA test
    wire [6:0] SEG7 [9:0];
    assign SEG7[4'h0] = 7'b0111111;
    assign SEG7[4'h1] = 7'b0000110;
    assign SEG7[4'h2] = 7'b1011011;
    assign SEG7[4'h3] = 7'b1001111;
    assign SEG7[4'h4] = 7'b1100110;
    assign SEG7[4'h5] = 7'b1101101;
    assign SEG7[4'h6] = 7'b1111101;
    assign SEG7[4'h7] = 7'b0000111;
    assign SEG7[4'h8] = 7'b1111111;
    assign SEG7[4'h9] = 7'b1100111;

    // Task for standard DUT reset procedure
    task reset_dut;
    begin
        // Activate the reset
        tb_nrst = 1'b0;

        // Maintain the reset for more than one cycle
        @(posedge tb_clk);
        @(posedge tb_clk);

        // Wait until safely away from rising edge of the clock before releasing
        @(negedge tb_clk);
        tb_nrst = 1'b1;

        // Leave out of reset for a couple cycles before allowing other stimulus
        // Wait for negative clock edges, 
        // since inputs to DUT should normally be applied away from rising clock edges
        @(negedge tb_clk);
        @(negedge tb_clk);
    end
    endtask

    // Task to cleanly and consistently check DUT output values
    task check_output;
    begin
        tb_mismatch = 1'b0;
        tb_check    = 1'b1;
        if(tb_ss == {SEG7[tb_expected_dig1], SEG7[tb_expected_dig2]}) begin // Check passed
            $display("Correct ss output during %d test case", tb_test_num);
        end else begin // Check failed
            tb_mismatch = 1'b1;
            $error("Incorrect ss output during %d test case", tb_test_num);
        end
        if(tb_blue == tb_expected_blue) begin // Check passed
            $display("Correct blue output %d test case", tb_test_num);
        end else begin // Check failed
            tb_mismatch = 1'b1;
            $error("Incorrect blue output during %d test case", tb_test_num);
        end
        if(tb_red == tb_expected_red) begin // Check passed
            $display("Correct red output during %d test case", tb_test_num);
        end else begin // Check failed
            tb_mismatch = 1'b1;
            $error("Incorrect red output during %d test case", tb_test_num);
        end

        // Wait some small amount of time so check pulse timing is visible on waves
        #(0.1);
        tb_check =1'b0;
    end
    endtask

    // Task to give button input the DUT
    task send_pb;
        input integer pb_val;
    begin
        // Send the bits at the negedge of the clk
        @(negedge tb_clk);
        tb_pb[pb_val] = 1'b1;
       
        // Set the bits back to zero after a short time
        @(negedge tb_clk);
        tb_pb[pb_val] = 1'b0;

        // wait for a clk cycle before exiting stimulus
        @(negedge tb_clk);
    end
    endtask

    // 10 MHz Clock
    always begin
        // Start with clock low to avoid false rising edge events at t=0
        tb_clk = 1'b0;
        // Wait half of the clock period before toggling clock value 
        // (maintain 50% duty cycle)
        #(CLK_PERIOD/2.0);
        tb_clk = 1'b1;
        // Wait half of the clock period before toggling clock value via 
        //rerunning the block (maintain 50% duty cycle)
        #(CLK_PERIOD/2.0);
    end


    // Port Maps protected by include gaurds to select between the 
    // gate level timing simulation and rtl simulation. 
    `ifdef USE_POWER_PINS
    calculator DUT
    (
        .VPWR(1), .VGND(0),
        .clk(tb_clk), .nrst(tb_nrst),
        .pb(tb_pb), .ss(tb_ss),
        .red(tb_red), .blue(tb_blue)
    );
    `else
    calculator DUT
    (
        .clk(tb_clk), .nrst(tb_nrst),
        .pb(tb_pb), .ss(tb_ss),
        .red(tb_red), .blue(tb_blue)
    );
    `endif


    // Open a dump for the calculator
    initial begin
        $dumpfile ("calculator_dump.vcd");
        $dumpvars(0, tb_calculator);
    end

    // sdf annotation is protected by inlculde guards so that it is only
    // enabled when the include guard is defined
    `ifdef ENABLE_SDF
    initial begin
        $sdf_annotate("mapped/synth.sdf", DUT,,);
    end
    `endif

    // Begin the simulation of the all the test cases
    initial begin
        // Initialize all of the test inputs
        tb_nrst             = 1'b1; // Initialize to be inactive
        tb_pb               = 0;    // Initialize to inactive value
        tb_test_num         = 0;    // Initialize test case counter
        tb_test_case        = "Test bench initializaton";
        tb_stream_check_tag = "N/A";
        tb_iter_val         = -1;   // Initialize to invalid number
        tb_mismatch         = 1'b0;
        tb_check            = 1'b0;
        // Wait some time before starting first test case
        #(0.1);


        // ************************************************************************
        // Test Case 1: Power-on Reset of the DUT
        // ************************************************************************
        tb_test_num  = tb_test_num + 1;
        tb_test_case = "Power on Reset";
        // Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
        // Wait some time before applying test case stimulus
        #(0.1);
        // Apply test case initial stimulus
        tb_nrst = 1'b0;

        // Wait for a bit before checking for correct functionality
        #(CLK_PERIOD * 0.5);

        // Check that internal state was correctly reset
        tb_expected_dig1 = RESET_OUTPUT_VALUE;
        tb_expected_dig2 = RESET_OUTPUT_VALUE;
        tb_expected_blue = RESET_OUTPUT_VALUE;
        tb_expected_red  = RESET_OUTPUT_VALUE;
        
        check_output();

        // Check that the reset value is maintained during a clock cycle
        #(CLK_PERIOD);

        check_output();
        
        // Release the reset away from a clock edge
        @(negedge tb_clk);
        tb_nrst  = 1'b1;   // Deactivate the chip reset
        // Check that internal state was correctly keep after reset release
        @(posedge tb_clk);
        @(negedge tb_clk);
    
        check_output();

        // Give some visual spacing between check and next test case start
        #(CLK_PERIOD * 3);


        // ************************************************************************
        // Test Case 2: Simple Addition
        // ************************************************************************
        tb_test_num  = tb_test_num + 1;
        tb_test_case = "Simple Addition";
        
        // Deactive any lingering inputs from previous test case
        tb_pb = 'b0;

        // reset the DUT
        reset_dut();

        // wait sometime before giving the stimulus
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        // select write mode
        send_pb (2);

        // Apply test case initial stimulus
        // send in the first number
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);

        // Assign the expected values
        tb_expected_dig1 = RESET_OUTPUT_VALUE;
        tb_expected_dig2 = 4'h1;
        tb_expected_blue = RESET_OUTPUT_VALUE;
        tb_expected_red  = RESET_OUTPUT_VALUE;

        // Check output after sending in the first number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (6);

         // Assign the expected values
        tb_expected_dig2 = RESET_OUTPUT_VALUE;

        // Check output after storing in the first number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Apply test case initial stimulus
        // send in the second number
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (0);

        // Assign the expected values
        tb_expected_dig2 = 4'h2;

        // Check output after sending in the second number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (7);

         // Assign the expected values
        tb_expected_dig2 = RESET_OUTPUT_VALUE;

        // Check output after storing in the second number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // select right mode
        send_pb (3);

        // select the register we want to read from
        send_pb (6);
        send_pb (7);

        // select the opcode
        send_pb (4);

        // Assign the expected values
        tb_expected_dig2 = 4'h3;

        // Check output after sending in the opcode
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Give some visual spacing between check and next test case start
        #(CLK_PERIOD * 3);


        // ************************************************************************
        // Test Case 3: Double Digit Addition
        // ************************************************************************
        tb_test_num  = tb_test_num + 1;
        tb_test_case = "Double Digit Addition";
        
        // Deactive any lingering inputs from previous test case
        tb_pb = 'b0;

        // reset the DUT
        reset_dut();

        // wait sometime before giving the stimulus
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        // select write mode
        send_pb (2);

        // Apply test case initial stimulus
        // send in the first number
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (1);
        send_pb (0);
        send_pb (1);
        send_pb (0);
        send_pb (0);

        // Assign the expected values
        tb_expected_dig1 = 4'h3;
        tb_expected_dig2 = 4'h4;
        tb_expected_blue = RESET_OUTPUT_VALUE;
        tb_expected_red  = RESET_OUTPUT_VALUE;

        // Check output after sending in the first number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (6);

         // Assign the expected values
        tb_expected_dig1 = RESET_OUTPUT_VALUE;
        tb_expected_dig2 = RESET_OUTPUT_VALUE;

        // Check output after storing in the first number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Apply test case initial stimulus
        // send in the second number
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (0);
        send_pb (1);
        send_pb (0);
        send_pb (0);
        send_pb (0);

        // Assign the expected values
        tb_expected_dig1 = 4'h2;
        tb_expected_dig2 = 4'h8;

        // Check output after sending in the second number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (7);

         // Assign the expected values
        tb_expected_dig1 = RESET_OUTPUT_VALUE;
        tb_expected_dig2 = RESET_OUTPUT_VALUE;

        // Check output after storing in the second number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // select right mode
        send_pb (3);

        // select the register we want to read from
        send_pb (6);
        send_pb (7);

        // select the opcode
        send_pb (4);

        // Assign the expected values
        tb_expected_dig1 = 4'h6;
        tb_expected_dig2 = 4'h2;

        // Check output after sending in the opcode
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Give some visual spacing between check and next test case start
        #(CLK_PERIOD * 3);


        // ************************************************************************
        // Test Case 4: Simple Subraction
        // ************************************************************************
        tb_test_num  = tb_test_num + 1;
        tb_test_case = "Simple Subraction";
        
        // Deactive any lingering inputs from previous test case
        tb_pb = 'b0;

        // reset the DUT
        reset_dut();

        // wait sometime before giving the stimulus
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        // select write mode
        send_pb (2);

        // Apply test case initial stimulus
        // send in the first number
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (0);
        send_pb (0);

        // Assign the expected values
        tb_expected_dig1 = RESET_OUTPUT_VALUE;
        tb_expected_dig2 = 4'h4;
        tb_expected_blue = RESET_OUTPUT_VALUE;
        tb_expected_red  = RESET_OUTPUT_VALUE;

        // Check output after sending in the first number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (6);

         // Assign the expected values
        tb_expected_dig2 = RESET_OUTPUT_VALUE;

        // Check output after storing in the first number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Apply test case initial stimulus
        // send in the second number
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);

        // Assign the expected values
        tb_expected_dig2 = 4'h1;

        // Check output after sending in the second number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (7);

         // Assign the expected values
        tb_expected_dig2 = RESET_OUTPUT_VALUE;

        // Check output after storing in the second number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // select right mode
        send_pb (3);

        // select the register we want to read from
        send_pb (6);
        send_pb (7);

        // select the opcode
        send_pb (5);

        // Assign the expected values
        tb_expected_dig2 = 4'h3;

        // Check output after sending in the opcode
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Give some visual spacing between check and next test case start
        #(CLK_PERIOD * 3);


        // ************************************************************************
        // Test Case 5: Double Digit Subtraction
        // ************************************************************************
        tb_test_num  = tb_test_num + 1;
        tb_test_case = "Double Digit Subtraction";
        
        // Deactive any lingering inputs from previous test case
        tb_pb = 'b0;

        // reset the DUT
        reset_dut();

        // wait sometime before giving the stimulus
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        // select write mode
        send_pb (2);

        // Apply test case initial stimulus
        // send in the first number
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (1);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (1);

        // Assign the expected values
        tb_expected_dig1 = 4'h6;
        tb_expected_dig2 = 4'h3;
        tb_expected_blue = RESET_OUTPUT_VALUE;
        tb_expected_red  = RESET_OUTPUT_VALUE;

        // Check output after sending in the first number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (8);

        // Assign the expected values
        tb_expected_dig1 = RESET_OUTPUT_VALUE;
        tb_expected_dig2 = RESET_OUTPUT_VALUE;

        // Check output after storing in the first number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Apply test case initial stimulus
        // send in the second number
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (0);
        send_pb (1);
        send_pb (0);
        send_pb (1);

        // Assign the expected values
        tb_expected_dig1 = 4'h1;
        tb_expected_dig2 = 4'h5;

        // Check output after sending in the second number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (9);

        // Assign the expected values
        tb_expected_dig1 = RESET_OUTPUT_VALUE;
        tb_expected_dig2 = RESET_OUTPUT_VALUE;

        // Check output after storing in the second number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // select right mode
        send_pb (3);

        // select the register we want to read from
        send_pb (8);
        send_pb (9);

        // select the opcode
        send_pb (5);

        // Assign the expected values
        tb_expected_dig1 = 4'h4;
        tb_expected_dig2 = 4'h8;

        // Check output after sending in the opcode
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Give some visual spacing between check and next test case start
        #(CLK_PERIOD * 3);


        // ************************************************************************
        // Test Case 6: Negative Output Subtraction
        // ************************************************************************
        tb_test_num  = tb_test_num + 1;
        tb_test_case = "Negative Output Subtraction";
        
        // Deactive any lingering inputs from previous test case
        tb_pb = 'b0;

        // reset the DUT
        reset_dut();

        // wait sometime before giving the stimulus
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        // select write mode
        send_pb (2);

        // Apply test case initial stimulus
        // send in the first number
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (1);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (1);

        // Assign the expected values
        tb_expected_dig1 = 4'h6;
        tb_expected_dig2 = 4'h3;
        tb_expected_blue = RESET_OUTPUT_VALUE;
        tb_expected_red  = RESET_OUTPUT_VALUE;

        // Check output after sending in the first number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (8);

        // Assign the expected values
        tb_expected_dig1 = RESET_OUTPUT_VALUE;
        tb_expected_dig2 = RESET_OUTPUT_VALUE;

        // Check output after storing in the first number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Apply test case initial stimulus
        // send in the second number
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (0);
        send_pb (1);
        send_pb (0);
        send_pb (1);

        // Assign the expected values
        tb_expected_dig1 = 4'h1;
        tb_expected_dig2 = 4'h5;

        // Check output after sending in the second number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (9);

        // Assign the expected values
        tb_expected_dig1 = RESET_OUTPUT_VALUE;
        tb_expected_dig2 = RESET_OUTPUT_VALUE;

        // Check output after storing in the second number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // select right mode
        send_pb (3);

        // select the register we want to read from
        send_pb (9);
        send_pb (8);

        // select the opcode
        send_pb (5);

        // Assign the expected values
        tb_expected_dig1 = 4'h4;
        tb_expected_dig2 = 4'h8;
        tb_expected_blue = 1'd1;

        // Check output after sending in the opcode
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Give some visual spacing between check and next test case start
        #(CLK_PERIOD * 3);


        // ************************************************************************
        // Test Case 7: Negative Input Addition
        // ************************************************************************
        tb_test_num  = tb_test_num + 1;
        tb_test_case = "Negative Input Addition";
        
        // Deactive any lingering inputs from previous test case
        tb_pb = 'b0;

        // reset the DUT
        reset_dut();

        // wait sometime before giving the stimulus
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        // select write mode
        send_pb (2);

        // Apply test case initial stimulus
        // send in the first number
        send_pb (1);
        send_pb (0);
        send_pb (1);
        send_pb (1);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (1);

        // Assign the expected values
        tb_expected_dig1 = 4'h6;
        tb_expected_dig2 = 4'h3;
        tb_expected_blue = 1'b1;
        tb_expected_red  = RESET_OUTPUT_VALUE;

        // Check output after sending in the first number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (8);

        // Assign the expected values
        tb_expected_dig1 = RESET_OUTPUT_VALUE;
        tb_expected_dig2 = RESET_OUTPUT_VALUE;
        tb_expected_blue = RESET_OUTPUT_VALUE;

        // Check output after storing in the first number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Apply test case initial stimulus
        // send in the second number
        send_pb (1);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (0);
        send_pb (1);
        send_pb (0);
        send_pb (1);

        // Assign the expected values
        tb_expected_dig1 = 4'h1;
        tb_expected_dig2 = 4'h5;
        tb_expected_blue = 1'b1;

        // Check output after sending in the second number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (9);

        // Assign the expected values
        tb_expected_dig1 = RESET_OUTPUT_VALUE;
        tb_expected_dig2 = RESET_OUTPUT_VALUE;
        tb_expected_blue = RESET_OUTPUT_VALUE;

        // Check output after storing in the second number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // select right mode
        send_pb (3);

        // select the register we want to read from
        send_pb (9);
        send_pb (8);

        // select the opcode
        send_pb (4);

        // Assign the expected values
        tb_expected_dig1 = 4'h7;
        tb_expected_dig2 = 4'h8;
        tb_expected_blue = 1'd1;

        // Check output after sending in the opcode
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Give some visual spacing between check and next test case start
        #(CLK_PERIOD * 3);


        // ************************************************************************
        // Test Case 8: Negative Input Subtraction
        // ************************************************************************
        tb_test_num  = tb_test_num + 1;
        tb_test_case = "Negative Input Subtraction";
        
        // Deactive any lingering inputs from previous test case
        tb_pb = 'b0;

        // reset the DUT
        reset_dut();

        // wait sometime before giving the stimulus
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        // select write mode
        send_pb (2);

        // Apply test case initial stimulus
        // send in the first number
        send_pb (1);
        send_pb (0);
        send_pb (1);
        send_pb (1);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (1);

        // Assign the expected values
        tb_expected_dig1 = 4'h6;
        tb_expected_dig2 = 4'h3;
        tb_expected_blue = 1'b1;
        tb_expected_red  = RESET_OUTPUT_VALUE;

        // Check output after sending in the first number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (8);

        // Assign the expected values
        tb_expected_dig1 = RESET_OUTPUT_VALUE;
        tb_expected_dig2 = RESET_OUTPUT_VALUE;
        tb_expected_blue = RESET_OUTPUT_VALUE;

        // Check output after storing in the first number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Apply test case initial stimulus
        // send in the second number
        send_pb (1);
        send_pb (0);
        send_pb (0);
        send_pb (0);
        send_pb (1);
        send_pb (0);
        send_pb (1);
        send_pb (0);
        send_pb (1);

        // Assign the expected values
        tb_expected_dig1 = 4'h1;
        tb_expected_dig2 = 4'h5;
        tb_expected_blue = 1'b1;

        // Check output after sending in the second number
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // store the value in a register
        send_pb (9);

        // Assign the expected values
        tb_expected_dig1 = RESET_OUTPUT_VALUE;
        tb_expected_dig2 = RESET_OUTPUT_VALUE;
        tb_expected_blue = RESET_OUTPUT_VALUE;

        // Check output after storing in the second number to a register
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // select right mode
        send_pb (3);

        // select the register we want to read from
        send_pb (8);
        send_pb (9);

        // select the opcode
        send_pb (5);

        // Assign the expected values
        tb_expected_dig1 = 4'h4;
        tb_expected_dig2 = 4'h8;
        tb_expected_blue = 1'd1;

        // Check output after sending in the opcode
        // Wait for sometime before checking
        repeat (2) @(posedge tb_clk);
        @(negedge tb_clk);

        check_output();

        // Give some visual spacing between check and next test case start
        #(CLK_PERIOD * 3);

        $finish;
    end
endmodule
