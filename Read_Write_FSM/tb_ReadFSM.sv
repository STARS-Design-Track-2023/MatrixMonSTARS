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
logic tb_isreg;
logic tb_regvalue;
logic tb_regout;

// Test bench signals for expected results

logic tb_expected_regout;
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
    if(tb_expected_regout == tb_regout) begin // Check passed
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
    tb_isreg = '0;
    tb_regvalue = 3'b000;
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

  ReadFSM DUT (
    .clk(tb_clk),
    .rst(tb_rst),
    .isreg(tb_isreg),
    .regvalue(tb_regvalue),
    .regout(tb_regout) 
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
    tb_isreg = 1'b1;
    tb_regvalue = 3'b000;
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
// Test Case1A: Remain in Idle State 1
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Remain in Idle State 1";

  tb_isreg = 1'b0;
  tb_rst = 2'b00;
  tb_regvalue = 3'b000;

  #(CLK_PERIOD * 0.5);

  tb_expected_regout = tb_regvalue;
  check_output("IDLE1");

// ************************************************************************
// Test Case1B: Move to Reg1
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Move to Reg1";

  tb_isreg = 1'b1;
  tb_rst = 2'b00;
  tb_regvalue = 3'b000;

  #(CLK_PERIOD * 0.5);

  tb_expected_regout = tb_regvalue;
  check_output("IDLE1 -> REG 2");

// ************************************************************************
// Test Case1C: Move to Reg2
// ************************************************************************
  tb_test_num  = tb_test_num + 1;
  tb_test_case = "Move to Reg2";

  tb_isreg = 1'b1;
  tb_rst = 2'b00;
  tb_regvalue = 3'b000;

  #(CLK_PERIOD * 0.5);

  tb_expected_regout = tb_regvalue;
  check_output("IDLE2 -> REG 2");

$display("Simulation complete");
$finish;
end
endmodule



