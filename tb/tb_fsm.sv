// File name:   tb_fsm.sv
// Author:      Vishnu Lagudu
// Description: Complete verification of the finite state machine in the
//              given calculator assignement. Non-systhesizable

`timescale 1ns/10ps

module tb_fsm ();
	
	// 100 MHZ system clock
	localparam CLK_PERIOD         = 100;
	localparam RESET_OUTPUT_VALUE = 'b0;

	// Declare Test Case Signals
	integer tb_test_num;
	string  tb_test_case;
	string  tb_stream_check_tag;
	logic   tb_mismatch;
	logic   tb_check;

	// Declare DUT Connection Signals
	logic	tb_clk;
	logic	tb_nrst;
	logic	tb_keystrobe;
	logic	tb_is_op;
	logic	tb_is_dig;
	logic	tb_is_result;
	logic	tb_is_enter;
	logic	tb_store_digit;
	logic	tb_enter;
	logic	tb_result_ready;

	// Expected Outputs Signals
	logic tb_expected_store_digit;
	logic tb_expected_enter;
	logic tb_expected_result_ready;

	// Task for standaed DUT reset procedure
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
		input string check_tag;
	begin
		tb_mismatch = 1'b0;
		tb_check    = 1'b1;
		if (tb_expected_store_digit == tb_store_digit) begin // Check Passes
			$display("Correct store digit output %s during %s test case", check_tag, tb_test_case);
		end else begin // Check failed
			tb_mismatch = 1'b1;
			$error("Incorrect store digit output %s during %s test case", check_tag, tb_test_case);
		end if (tb_expected_enter == tb_enter) begin // Check passed
			$display("Correct enter output %s during %s test case", check_tag, tb_test_case);
		end else begin // Check failed
			$error("Incorrect enter output %s during %s test case", check_tag, tb_test_case);
		end if (tb_expected_result_ready == tb_result_ready) begin // Check Passed
				$display("Correct result ready output %s during %s test case", check_tag, tb_test_case);
		end else begin // Check failed
				$error("Incorrect result ready output %s during %s test case", check_tag, tb_test_case);
		end
		
		// Wait for some small amount of time so check pulse timing in visible
		#(0.1);
		tb_check = 1'b0;
	end
	endtask

	/* ---------- DUT TEST CASES ------------ */

	// Inactivate all the inputs
	task inactivate_signals;
	begin
		tb_keystrobe = 'b0;
		tb_is_op     = 'b0;
		tb_is_dig    = 'b0;
		tb_is_result = 'b0;
		tb_is_enter  = 'b0;
	end
	endtask

	// Give the signal inputs to all the signals
	task assign_inputs;
		input logic tb_key_strobe_val;
		input logic tb_is_op_val;
		input logic tb_is_dig_val;
		input logic tb_is_result_val;
		input logic tb_is_enter_val;
	begin
		tb_keystrobe = tb_key_strobe_val;
		tb_is_op     = tb_is_op_val;
		tb_is_dig    = tb_is_dig_val;
		tb_is_result = tb_is_result_val;
		tb_is_enter  = tb_is_enter_val;
	end
	endtask

	// Clock generation block
  	always begin
    	// Start with clock low to avoid false rising edge events at t=0
    	tb_clk = 1'b0;
    	// Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
    	#(CLK_PERIOD/2.0);
    	tb_clk = 1'b1;
    	// Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
    	#(CLK_PERIOD/2.0);
  	end

	// DUT Portmap
	fsm DUT
	(
		.clk(tb_clk),
		.nrst(tb_nrst),
		.key_strobe(tb_keystrobe),
		.is_op(tb_is_op),
		.is_dig(tb_is_dig),
		.is_result(tb_is_result),
		.is_enter(tb_is_enter),
		.store_dig(tb_store_digit),
		.enter(tb_enter),
		.result_ready(tb_result_ready)
	);


	// Signal Dump to view the waveforms
	initial begin
		$dumpfile ("dump.vcd");
		$dumpvars;
	end

	// Test Case
	initial begin
		// Initialize all the test inputs
		tb_nrst      				= 1'b1;
		tb_keystrobe 				= 1'b0;
		tb_is_op					= 1'b0;
		tb_is_dig					= 1'b0;
		tb_is_result				= '0;
		tb_is_enter					= '0;
		tb_test_num					= 0;
		tb_test_case				= "Test bench initialization";
		tb_stream_check_tag         = "N/A";
		tb_mismatch					= 1'b0;
		tb_check				    = 1'b0;
		// Wait for some time before starting first test case
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
		inactivate_signals();
		tb_nrst = 1'b0;

		// Wait for a bit before checking for correct functionality
		#(CLK_PERIOD * 0.5);

		// Check that internal state was correctly reset
		tb_expected_store_digit  = RESET_OUTPUT_VALUE;
		tb_expected_enter        = RESET_OUTPUT_VALUE;
		tb_expected_result_ready = RESET_OUTPUT_VALUE;
		check_output("after reset applied");

		// Check that the reset value is maintained during a clock cycle
		#(CLK_PERIOD);
		check_output("after clock cycle while in reset");
		
		// Release the reset away from a clock edge
		@(negedge tb_clk);
		tb_nrst  = 1'b1;   // Deactivate the chip reset
		// Check that internal state was correctly keep after reset release
		check_output("after reset was released");
		#(CLK_PERIOD * 3);

		// ************************************************************************
		// Test Case 2: Cycle throught the entire tree
		// ************************************************************************
		tb_test_num  = tb_test_num + 1;
		tb_test_case = "Cycle throught the entire tree";

		// Wait some time before applying test case stimulus
		#(0.1);

		// Apply test case initial stimulus
		reset_dut();
		inactivate_signals();

		// Check that internal state was correctly reset
		tb_expected_store_digit  = RESET_OUTPUT_VALUE;
		tb_expected_enter        = RESET_OUTPUT_VALUE;
		tb_expected_result_ready = RESET_OUTPUT_VALUE;

		// Check that the reset value
		@(posedge tb_clk);
		@(negedge tb_clk);
		check_output("after reset applied");

		// Escape the idle case
		assign_inputs (1'b1, 1'b0, 1'b1, 1'b0, 1'b0);
		tb_expected_store_digit  = 1'b1;
		tb_expected_enter        = RESET_OUTPUT_VALUE;
		tb_expected_result_ready = RESET_OUTPUT_VALUE;

		// Enter dig1 state. In the next clk cycle move to idle2
		@(posedge tb_clk);
		@(negedge tb_clk);
		check_output("when receiving the first digit from user");

		inactivate_signals();
		// Expected outputs for the next idle state
		tb_expected_store_digit  = RESET_OUTPUT_VALUE;
		tb_expected_enter        = RESET_OUTPUT_VALUE;
		tb_expected_result_ready = RESET_OUTPUT_VALUE;

		// In the next clk we should move to another idle state
		@(posedge tb_clk);
		@(negedge tb_clk);
		check_output("after receiving the first digit from the user");

		// Enter dig2 state. 
		assign_inputs (1'b1, 1'b0, 1'b1, 1'b0, 1'b0);
		tb_expected_store_digit  = 1'b1;
		tb_expected_enter        = RESET_OUTPUT_VALUE;
		tb_expected_result_ready = RESET_OUTPUT_VALUE;

		// Enter dig2 state. 
		@(posedge tb_clk);
		@(negedge tb_clk);
		check_output("when receiving the second digit from user");

		inactivate_signals();
		// Expected outputs for the next idle state
		tb_expected_store_digit  = RESET_OUTPUT_VALUE;
		tb_expected_enter        = RESET_OUTPUT_VALUE;
		tb_expected_result_ready = RESET_OUTPUT_VALUE;

		// In the next clk we should move to another idle state
		@(posedge tb_clk);
		@(negedge tb_clk);
		check_output("after receiving the second digit from the user");

		// User Presses enter 
		assign_inputs (1'b1, 1'b1, 1'b0, 1'b0, 1'b1);
		tb_expected_store_digit  = RESET_OUTPUT_VALUE;
		tb_expected_enter        = 1'b1;
		tb_expected_result_ready = RESET_OUTPUT_VALUE;

		// When we receive an enter from the user
		@(posedge tb_clk);
		@(negedge tb_clk);
		check_output("when the user preses enter");

		inactivate_signals();
		// Expected outputs for the next idle state
		tb_expected_store_digit  = RESET_OUTPUT_VALUE;
		tb_expected_enter        = RESET_OUTPUT_VALUE;
		tb_expected_result_ready = RESET_OUTPUT_VALUE;

		// When we receive an enter from the user
		@(posedge tb_clk);
		@(negedge tb_clk);
		check_output("after user presses enter");

		/* ----------- FIRST CYCLE ENDS ---------- */

		// Escape the idle case
		assign_inputs (1'b1, 1'b0, 1'b1, 1'b0, 1'b0);
		tb_expected_store_digit  = 1'b1;
		tb_expected_enter        = RESET_OUTPUT_VALUE;
		tb_expected_result_ready = RESET_OUTPUT_VALUE;

		// Enter dig1 state. In the next clk cycle move to idle2
		@(posedge tb_clk);
		@(negedge tb_clk);
		check_output("when receiving the first digit from user during second cycle");

		inactivate_signals();
		// Expected outputs for the next idle state
		tb_expected_store_digit  = RESET_OUTPUT_VALUE;
		tb_expected_enter        = RESET_OUTPUT_VALUE;
		tb_expected_result_ready = RESET_OUTPUT_VALUE;

		// In the next clk we should move to another idle state
		@(posedge tb_clk);
		@(negedge tb_clk);
		check_output("after receiving the first digit from the user during second cycle");

		// Enter dig2 state. 
		assign_inputs (1'b1, 1'b0, 1'b1, 1'b0, 1'b0);
		tb_expected_store_digit  = 1'b1;
		tb_expected_enter        = RESET_OUTPUT_VALUE;
		tb_expected_result_ready = RESET_OUTPUT_VALUE;

		// Enter dig2 state. 
		@(posedge tb_clk);
		@(negedge tb_clk);
		check_output("when receiving the second digit from user during second cycle");

		inactivate_signals();
		// Expected outputs for the next idle state
		tb_expected_store_digit  = RESET_OUTPUT_VALUE;
		tb_expected_enter        = RESET_OUTPUT_VALUE;
		tb_expected_result_ready = RESET_OUTPUT_VALUE;

		// In the next clk we should move to another idle state
		@(posedge tb_clk);
		@(negedge tb_clk);
		check_output("after receiving the second digit from the user during second cycle");

		assign_inputs (1'b1, 1'b1, 1'b0, 1'b1, 1'b0);
		tb_expected_store_digit  = RESET_OUTPUT_VALUE;
		tb_expected_enter        = RESET_OUTPUT_VALUE;
		tb_expected_result_ready = 1'b1;

		// User we should recieve result ready signal
		@(posedge tb_clk);
		@(negedge tb_clk);
		check_output("after receiving is_result from user");

		inactivate_signals();
		// Expected outputs for the next idle state
		tb_expected_store_digit  = RESET_OUTPUT_VALUE;
		tb_expected_enter        = RESET_OUTPUT_VALUE;
		tb_expected_result_ready = RESET_OUTPUT_VALUE;

		// In the next clk we should move to another idle state
		@(posedge tb_clk);
		@(negedge tb_clk);
		check_output("after an entire use of the dig inputs");

		$display ("SIM COMPLETE");
		$stop();
	end

endmodule