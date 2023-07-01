// File name:   tb_calculator.v
// Author:      Vishnu Lagudu
// Description: Complete verification of the final calculator design (Non-synthesizable)

module tb_calculator ();

    // clk period for 10 MHz clk
    localparam CLK_PERIOD         = 100;
    localparam RESET_OUTPUT_VALUE = 0;

    // Declare Test Case Signals
    integer       tb_test_num;
    reg [1023:0]  tb_test_case;
    reg [1023:0]  tb_stream_check_tag;
    integer       tb_bit_num;
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
    reg [13:0] tb_expected_ss;
    reg        tb_expected_blue;
    reg        tb_expected_red;

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
        input reg [1023:0] check_tag;
    begin
        tb_mismatch = 1'b0;
        tb_check    = 1'b1;
        if(tb_expected_ouput == tb_P) begin // Check passed
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

    // Task to give button input the DUT
    task send_pb;
        input reg pb_val;
    begin
        // Send the bits at the negedge of the clk
        @(negedge tb_clk);
        tb_pb[pb_val] = 1'b1; 
       
        // Set the bits back to zero after a clk cycle
        @(negedge tb_clk);
        tb_pb[pb_val] = 1'b0;
    end
    endtask

    // Task to send in a series of pb inputs to the simulate the 
    //  number input to the DUT
    task send_stream;
        input reg [8:0] pb_stream;
    begin
        for (tb_bit_num = 8; tb_bit_num >= 0; tb_bit_num = tb_bit_num + 1)
            send_stream(pb_stream[tb_bit_num]);
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
        .clk(tb_clk), .nrst(tb_n_rst),
        .pb(tb_pb), .ss(tb_ss),
        .red(tb_red), .blue(tb_blue)
    );
    `else
    calculator DUT
    (
        .clk(tb_clk), .nrst(tb_n_rst),
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
        tb_pb               = 1'b1; // Initialize to inactive value
        tb_mode_i           = '0;   // Initialize to be inactive
        tb_par_i            = '0;
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
        // Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
        // Wait some time before applying test case stimulus
        #(0.1);
        // Apply test case initial stimulus
        tb_D    = 1'b0;
        tb_nrst = 1'b0;

        // Wait for a bit before checking for correct functionality
        #(CLK_PERIOD * 0.5);

        // Check that internal state was correctly reset
        tb_expected_ouput = RESET_OUTPUT_VALUE;
        check_output("after reset applied");

        // Check that the reset value is maintained during a clock cycle
        #(CLK_PERIOD);
        check_output("after clock cycle while in reset");
        
        // Release the reset away from a clock edge
        @(negedge tb_clk);
        tb_nrst  = 1'b1;   // Deactivate the chip reset
        // Check that internal state was correctly keep after reset release
        #(PROPAGATION_DELAY);
        check_output("after reset was released");
        #(CLK_PERIOD * 3);
        $stop;
    end


endmodule
