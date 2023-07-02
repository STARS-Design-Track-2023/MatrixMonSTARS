`timescale 1ns/10ps

module tb_new_operand_buffer();

  localparam CLK_PERIOD  = 100;
  localparam  RESET_OUTPUT_VALUE = 9'b0;


  // Declare Test Case Signals
  integer tb_test_num;
  string  tb_test_case;
  string  tb_stream_check_tag;
  int     tb_bit_num;
  logic   tb_mismatch;
  logic   tb_check;

  // Declare DUT Connection Signals
  logic                tb_clk;
  logic                tb_nrst;
  logic[8:0]           tb_result;
  logic                tb_store_digit;
  logic                tb_enter;
  logic                tb_result_ready;
  logic[3:0]           tb_digit;
  logic                tb_sign;
  logic[8:0]           tb_op1;
  logic[7:0]           tb_ssdec;

  
  // Declare the Test Bench Signals for Expected Results
  logic [8:0] tb_expected_op1;
  logic tb_expected_sign;
  
  
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
    input string check_tag;
  begin
    tb_mismatch = 1'b0;
    tb_check    = 1'b1;
    assert(tb_expected_op1 == tb_op1) begin // Check passed
      $display("Correct parallel output %s during %s test case", check_tag, tb_test_case);
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect parallel output %s during %s test case", check_tag, tb_test_case);
    end

    // Wait some small amount of time so check pulse timing is visible on waves
    #(0.1);
    tb_check =1'b0;
  end
  endtask

  
 
  // Set input signals to zero before starting with new testcases
  task inactivate_signals;
  begin
    tb_result      = '0;
    tb_store_digit = '0;
    tb_enter = '0;
    tb_result_ready = '0;
    tb_digit  = '0;
  end
  endtask

  // Clock generation block
  always begin
    // Start with clock low to avoid false rising edg    @(posedge tb_clk);e events at t=0
    tb_clk = 1'b0;
    // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1;
    // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
    #(CLK_PERIOD / 2.0);
  end


  
  // DUT Portmap
  new_operand_buffer DUT 
  (    
    .clk(tb_clk), 
    .nrst(tb_nrst), 
    .result(tb_result), 
    .store_digit(tb_store_digit), 
    .enter(tb_enter),
    .result_ready(tb_result_ready),
    .digit(tb_digit),
    .op1(tb_op1),
    .sign(tb_sign),
    .ssdec(tb_ssdec)
  );

   // Signal Dump
    initial begin
      $dumpfile ("dump.vcd");
      $dumpvars;
    end
  
  // Test Cases
  initial begin
    // Initialize all of the test inputs
    tb_nrst             = 1'b1; // Initialize to be inactive
    tb_result           = 9'b0;
    tb_store_digit      = '0; 
    tb_enter            = '0;
    tb_result_ready     = '0;
    tb_digit            = 4'b0;
    tb_test_num         = 0;    // Initialize test case counter
    tb_test_case        = "Test bench initializaton";
    tb_stream_check_tag = "N/A";
    tb_bit_num          = -1;   // Initialize to invalid number
    tb_mismatch         = 1'b0;
    tb_check            = 1'b0;
    // Wait some time before starting first test case
    #(0.1);

    // ************************************************************************
    // Test Case 1: Power-on Reset of the DUT
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Power on Reset";
    #(0.1);
    // Apply test case initial stimulus
    
    reset_dut;
    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.5);

    // Check that internal state was correctly reset
    tb_expected_op1 = RESET_OUTPUT_VALUE;
    check_output("after reset applied");
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); 

    // ************************************************************************
    // Test Case 2: Putting in the result
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Putting in the result";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    inactivate_signals();
    reset_dut();

    // Set mode
    tb_result_ready  = 1'b1;

    // Define the test data stream for this test case
    tb_result = 9'b100110010;

    // Define the expected result
    tb_expected_op1 = 9'b100110010;

    
    // Wait for some time before checking the outputs
    @(posedge tb_clk);
    @(negedge tb_clk);
    // Check the result of the full stream
    check_output("after trying to display result");
    #(CLK_PERIOD * 3);


    // ************************************************************************
    // Test Case 3: Checking Enter
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Checking Enter";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    inactivate_signals();
    reset_dut();

    // Set mode
    tb_enter   = 1'b1;
    

    // Define the expected result
    tb_expected_op1 = '0;

    

    // Wait for some time before checking the outputs
    @(posedge tb_clk);
    @(negedge tb_clk);
    // Check the result of the full stream
    check_output("Checking Enter");
    #(CLK_PERIOD * 3);
  

    // ************************************************************************
    // Test Case 4: Checking when action of store digit is given
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Checking when action of store digit is given";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    inactivate_signals();
    reset_dut();

    tb_digit = 4'b0001;
    tb_store_digit = 1'b1;

    // Define the expected result
    tb_expected_op1 = 9'b000000001;
    
    @(posedge tb_clk);
    @(negedge tb_clk);

    // Check the result of the full stream
    check_output("when no action is given");
    #(CLK_PERIOD * 3);


    

    // ************************************************************************
    // Test Case 5: Checking for storing two values
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Checking for storing two values";


    tb_digit = 4'b0001;
    tb_store_digit = 1'b1;

    // Define the expected result
    tb_expected_op1 = 9'b000010001;
    
    @(posedge tb_clk);
    @(negedge tb_clk);

    // Check the result of the full stream
    check_output("checking for storing two values");
    #(CLK_PERIOD * 3);



    // ************************************************************************
    // Test Case 6: Checking initial value of output
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Checking initial value of output";
    // Start out with inactive value and reset the DUT to isolate from prior tests
    inactivate_signals();
    reset_dut();

    tb_expected_op1 = 9'b0;

    @(posedge tb_clk);
    @(negedge tb_clk);

    // Check the result of the full stream
    check_output("for initial value of output");
    #(CLK_PERIOD * 3);



    $finish;
  end
    

endmodule