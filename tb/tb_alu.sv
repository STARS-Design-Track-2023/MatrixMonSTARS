`timescale 1ns/10ps

module tb_alu ();
  localparam CLK_PERIOD           = 100;
  localparam  ALU_SIZE_BITS       = 9;
  localparam  ALU_MAX_BIT         = ALU_SIZE_BITS - 1;
  localparam  RESET_OUTPUT_VALUE  = 8'b0;

  // Declare Test Case Signals
  integer tb_test_num;
  string  tb_test_case;
  logic   tb_mismatch;
  logic   tb_check;

  // Declare DUT Connection Signals

  logic                             tb_clk;
  logic                             tb_nrst;

  logic [ALU_MAX_BIT:0]             tb_op1;
  logic [ALU_MAX_BIT:0]             tb_op2;
  logic [2:0] tb_opcode;

  logic [ALU_MAX_BIT:0]             tb_result;
  logic [ALU_MAX_BIT-4:0]           tb_result_lsd;
  logic [ALU_MAX_BIT:ALU_MAX_BIT-3] tb_result_msd;
  logic                             tb_c_out;

  // Declare the Test Bench Signals for Expected Results
  logic [ALU_MAX_BIT:0] tb_expected_result;
  logic tb_expected_c_out;

   always begin
    // Start with clock low to avoid false rising edge events at t=0
    tb_clk = 1'b0;
    // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
    tb_clk = 1'b1;
    // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
  end

  // Task to cleanly and consistently check DUT output values
  task check_output;
  begin
    tb_mismatch = 1'b0;
    tb_check    = 1'b1;

    if((tb_expected_result[3:0] == tb_result[3:0])) begin // Check passed
      $display("Correct LSD result value during %s test case", tb_test_case);
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect LSD result value during %s test case", tb_test_case);
    end

    if((tb_expected_result[7:4] == tb_result[7:4])) begin // Check passed
      $display("Correct MSD result value during %s test case", tb_test_case);
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect MSD result value during %s test case", tb_test_case);
    end

    if((tb_expected_result[8] == tb_result[8])) begin // Check passed
      $display("Correct carry_out value during %s test case", tb_test_case);
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect carry_out value during %s test case", tb_test_case);
    end
  end
  endtask

  // DUT Portmap
  alu DUT 
  ( 
    .op1(tb_op1), 
    .op2(tb_op2),
    .opcode(tb_opcode), 
    .result(tb_result)
  );

  // Signal Dump
  initial begin
    $dumpfile ("dump.vcd");
    $dumpvars;
  end
  
  // Test Cases
  initial begin
    // Initialize all of the test inputs
    tb_op1              = 9'b0; 
    tb_op2              = 9'b0;
    tb_opcode           = 3'b0;
    tb_test_num         = 0;    // Initialize test case counter
    tb_test_case        = "Test bench initializaton";
    tb_mismatch         = 1'b0;
    tb_check            = 1'b0;
    // Wait some time before starting first test case
    #(0.1);

    // ************************************************************************
    // Test Case 1: Simple Addition (37+12)
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "(37+12)";

    // Apply test case initial stimulus
    tb_op1    = 9'b000110111;
    tb_op2    = 9'b000010010;
    tb_opcode = 2'b01;

    tb_expected_result = 9'b001001001;

    repeat(5) begin
      @(posedge tb_clk);
    end
    
    // Check output
    check_output();

    // ************************************************************************
    // Test Case 2: LSD Carry (15+05)
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "(15+05)";

    // Apply test case initial stimulus
    tb_op1    = 9'b000010101;
    tb_op2    = 9'b000000101;
    tb_opcode = 2'b01;

    tb_expected_result = 9'b000100000;

    repeat(5) begin
      @(posedge tb_clk);
    end

    // Check output
    check_output();

    // ************************************************************************
    // Test Case 3: MSD carry out and MSD internal carry (81+81)
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "(81+81)";

    // Apply test case initial stimulus
    tb_op1    = 9'b010000001;
    tb_op2    = 9'b010000001;
    tb_opcode = 2'b01;

    tb_expected_result = 9'b01100010;

    repeat(5) begin
      @(posedge tb_clk);
    end

    // Check output
    check_output();

    // ************************************************************************
    // Test Case 4: Simple subtraction (86-55)
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "(86-55)";

    // Apply test case initial stimulus
    tb_op1    = 9'b010000110;
    tb_op2    = 9'b001010101;
    tb_opcode = 3'b10;

    tb_expected_result = 9'b000110001;

    repeat(5) begin
      @(posedge tb_clk);
    end

    // Check output
    check_output();

    // ************************************************************************
    // Test Case 4: Simple subtraction (21-33)
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "(21-33)";

    // Apply test case initial stimulus
    tb_op1    = 9'b000100001;
    tb_op2    = 9'b000110011;
    tb_opcode = 3'b010;

    tb_expected_result = 9'b110001000;

    repeat(5) begin
      @(posedge tb_clk);
    end

    // Check output
    check_output();
    $finish;

  end

endmodule
