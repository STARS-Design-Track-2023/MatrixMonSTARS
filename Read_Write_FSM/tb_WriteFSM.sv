// this is the testbench for the fsm 
`timescale 1ns/10ps

module testbench();

localparam CLK_PERIOD = 100;
localparam PROP_DEL = 0;

// localparam SR_SIZE_BITS = 8;
// localparam  SR_MAX_BIT = SR_SIZE_BITS - 1;
localparam  RESET_OUTPUT_VALUE = 8'b0;

//Test Case Signals
integer tb_test_num;
string  tb_test_case;
string  tb_stream_check_tag;
int     tb_bit_num;
logic   tb_mismatch;
logic   tb_check;

// DUT connection signals 

logic tb_clk;
logic tb_rst;
logic tb_keystrobe;
logic tb_isop;
logic tb_isdig;
logic tb_isreg;
logic tb_storedigit;
logic tb_regnum;
logic tb_resultready;

// Test bench signals for expected results

logic tb_expected_storedigit;
logic tb_expected_regnum;
logic tb_expected_result;
logic tb_p_test_data;
logic tb_test_data [];
logic [1:0] tb_mode;

  // Task for standard DUT reset procedure
  task reset_dut;
  begin
    // Activate the reset
    @(negedge tb_clk)
    tb_rst = 1'b1;

    // Maintain the reset for more than one cycle
    @(posedge tb_clk);
    @(posedge tb_clk);

    // Wait until safely away from rising edge of the clock before releasing
    @(negedge tb_clk);
    tb_rst = 1'b0;

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
    if(tb_expected_storedigit == tb_storedigit) begin // Check passed
      $display("Correct output '%s' during %s test case", check_tag, tb_test_case);
    end
    else if(tb_expected_regnum == tb_regnum) begin // Check passed
      $display("Correct output '%s' during %s test case", check_tag, tb_test_case);
    end
    else if(tb_expected_result == tb_resultready) begin // Check passed
      $display("Correct output '%s' during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect output '%s' during %s test case", check_tag, tb_test_case);
    end

    // Wait some small amount of time so check pulse timing is visible on waves
    #(0.1);
    tb_check =1'b0;
  end
  endtask
/**
below is unecessary fpor the FSM test module because we are not sending any values bit by bit
**/
// task send_bit;
//     input logic bit_to_send;
//   begin
//     // Synchronize to the negative edge of clock to prevent timing errors
//     @(negedge tb_clk);
    
//     // Set the value of the bit
//     tb_D = bit_to_send;
//     // Activate the shift enable
//     tb_mode_i = tb_mode;

//     // Wait for the value to have been shifted in on the rising clock edge
//     @(negedge tb_clk);
//     #(PROPAGATION_DELAY);

//     // Turn off the Shift enable
//     tb_mode_i = 2'b0;
//   end
//   endtask

// no send stream 

//resetting input signals to zero prior to every new testcase
  task inactivate_signals;
  begin
    tb_isop = '0;
    tb_isdig = '0;
    tb_isreg = '0;
    tb_keystrobe = 1'b1;
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

  WriteFSM DUT (
    .clk(tb_clk),
    .rst(tb_rst),
    .isop(tb_isop),
    .isdig(tb_isdig),
    .isreg(tb_isreg),
    .key_strobe(tb_keystrobe),
    .store_dig(tb_storedigit),
    .reg_num(tb_regnum),
    .result_ready(tb_resultready)   
  );


  // Signal Dump
  initial begin
    $dumpfile ("dump.vcd");
    $dumpvars;
  end

  // Test Cases
  initial begin
    // Initialize all of the test inputs
    tb_rst             = 1'b1; // Initialize to be inactive
    tb_isop                = 1'b1; // Initialize to inactive value
    tb_isdig         = 1'b1;   // Initialize to be inactive
    tb_isreg = 1'b1;
    tb_keystrobe          = 1'b1;
    tb_test_num         = 0;    // Initialize test case counter
    tb_test_case = "Test bench initialization";
    tb_stream_check_tag = "N/A";
    tb_bit_num          = -1; 
    tb_mismatch         = 1'b0;
    tb_check            = 1'b0;
    // Wait some time before starting first test case
    #(0.1);
  
//TEST CASE A: ALL CORRECT VALUES HAVE BEEN INPUT SEQUENTIALLY!)
$display("TESTCASE #1");

// ************************************************************************
// Test Case A1: Checking the mode when is_op && is_dig == 0 when in the first idle state 
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Remain in Idle State 1";

  tb_isop = 2'b00;
  tb_isdig = 2'b00;
  tb_isreg = 2'b00;
  tb_rst = 2'b00;

  #(CLK_PERIOD * 0.5);

  tb_expected_storedigit = 0;
  tb_expected_regnum = 0;
  tb_expected_result = 0;
  check_output("IDLE1");


//************************************************************************
// Test Case A2: Checking the mode when is_dig = 1 and is_op = 0, moving from S0 to S1 
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Move from Idle1 to Num1Dig1 (then Idle2)";

  tb_isop = 1'b0;
  tb_isdig = 1'b1;
  tb_isreg = 1'b0;
  tb_rst = 2'b00;

  #(CLK_PERIOD * 0.5);

  tb_expected_storedigit = 1;
  tb_expected_regnum = 0;
  tb_expected_result = 0;
  check_output("IDLE1 -> DIG1");

//automatic move from S1 TO S2

//************************************************************************
// Test Case A3: Checking the mode when is_dig =1  and is_op = 0, moving from S2 
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Move from Idle2 to Num1Dig2 (then Idle3)";

  tb_isop = 1'b0;
  tb_isdig = 1'b1;
  tb_isreg = 1'b0;
  tb_rst = 2'b00;

  #(CLK_PERIOD * 0.5);

  tb_expected_storedigit = 1;
  tb_expected_regnum = 0;
  tb_expected_result = 0;
  check_output("IDLE2 -> DIG2");

//************************************************************************
// Test Case A4: Checking the mode when is_op = 1 && is_dig = 1
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Move from Idle3 to regnum";

  tb_isop = 1'b0;
  tb_isdig = 1'b0;
  tb_isreg = 1'b1;
  tb_rst = 2'b00;

  #(CLK_PERIOD * 0.5);

  tb_expected_storedigit = 0;
  tb_expected_regnum = 1;
  tb_expected_result = 0;
  check_output("IDLE3 -> regnum ");

// ************************************************************************
// Test Case A5: Checking the mode when is_op && is_dig == 0 when in the first idle state 
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Remain in Idle State 1";

  tb_isop = 2'b00;
  tb_isdig = 2'b00;
  tb_isreg = 2'b00;
  tb_rst = 2'b00;

  #(CLK_PERIOD * 0.5);

  tb_expected_storedigit = 0;
  tb_expected_regnum = 0;
  tb_expected_result = 0;
  check_output("IDLE1");


//************************************************************************
// Test Case A6: Checking the mode when is_dig = 1 and is_op = 0, moving from S0 to S1 
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Move from Idle1 to Num2Dig1 (then Idle2)";

  tb_isop = 1'b0;
  tb_isdig = 1'b1;
  tb_isreg = 2'b00;
  tb_rst = 2'b00;

  #(CLK_PERIOD * 0.5);

  tb_expected_storedigit = 1;
  tb_expected_regnum = 0;
  tb_expected_result = 0;
  check_output("IDLE1 -> DIG1");

//automatic move from S1 TO S2

//************************************************************************
// Test Case A7: Checking the mode when is_dig =1  and is_op = 0, moving from S2 
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Move from Idle2 to Num2Dig2 (then Idle3)";

  tb_isop = 1'b0;
  tb_isdig = 1'b1;
  tb_isreg = 2'b00;
  tb_rst = 2'b00;

  #(CLK_PERIOD * 0.5);

  tb_expected_storedigit = 1;
  tb_expected_regnum = 0;
  tb_expected_result = 0;
  check_output("IDLE2 -> DIG2");

//************************************************************************
// Test Case A8: Checking the mode when is_op = 1 && is_dig = 1
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Move from Idle3 to Result";

  tb_isop = 1'b1;
  tb_isdig = 1'b0;
  tb_isreg = 2'b00;
  tb_rst = 2'b00;

  #(CLK_PERIOD * 0.5);

  tb_expected_storedigit = 0;
  tb_expected_regnum = 0;
  tb_expected_result = 1;
  check_output("IDLE3 -> RESULT");

//ESTABLISHING A RESET
reset_dut();

$display("TEST CASE #2");

// ************************************************************************
// Test Case B1: Checking the mode when is_op && is_dig == 0 when in the first idle state 
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Remain in Idle State 1";

  tb_isop = 2'b00;
  tb_isdig = 2'b00;
  tb_isreg = 2'b00;
  tb_rst = 2'b00;

  #(CLK_PERIOD * 0.5);

  tb_expected_storedigit = 0;
  tb_expected_regnum = 0;
  tb_expected_result = 0;
  check_output("IDLE1");


//************************************************************************
// Test Case B2: Checking the mode when is_dig = 1 and is_op = 0, moving from S0 to S1 
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Move from Idle1 to Num1Dig1 (then Idle2)";

  tb_isop = 1'b0;
  tb_isdig = 1'b1;
  tb_isreg = 2'b00;
  tb_rst = 2'b00;

  #(CLK_PERIOD * 0.5);

  tb_expected_storedigit = 1;
  tb_expected_regnum = 0;
  tb_expected_result = 0;
  check_output("IDLE1 -> DIG1");

//automatic move from S1 TO S2

//************************************************************************
// Test Case B3: Checking the mode when is_dig =1  and is_op = 0, moving from S2 
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Remain in Idle2";

  tb_isop = 1'b0;
  tb_isdig = 1'b0;
  tb_isreg = 2'b00;
  tb_rst = 2'b00;

  #(CLK_PERIOD * 0.5);

  tb_expected_storedigit = 0;
  tb_expected_regnum = 0;
  tb_expected_result = 0;
  check_output("IDLE2");

//************************************************************************
// Test Case B4: Checking the mode when is_op = 1 && is_dig = 1
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Move from Idle2 to Dig2";

  tb_isop = 1'b0;
  tb_isdig = 1'b1;
    tb_isreg = 2'b00;
  tb_rst = 2'b00;

  #(CLK_PERIOD * 0.5);

  tb_expected_storedigit = 1;
  tb_expected_regnum = 0;
  tb_expected_result = 0;
  check_output("IDLE2 -> DIG2");

// ************************************************************************
// Test Case B5: Checking the mode when is_op && is_dig == 0 when in the first idle state 
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Remain in Idle3";

  tb_isop = 2'b00;
  tb_isdig = 2'b01;
   tb_isreg = 2'b00;
  tb_rst = 2'b00;

  #(CLK_PERIOD * 0.5);

  tb_expected_storedigit = 0;
  tb_expected_regnum = 0;
  tb_expected_result = 0;
  check_output("IDLE3");

$display("Simulation complete");
$finish;
end
endmodule
