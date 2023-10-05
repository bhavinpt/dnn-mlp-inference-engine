//////////////////////////////////////////////////////////////////////////////////////////////
// FILE: testbench.v
// Description: Testbench of Neural Network designed as a part of Mini-Project 2 of EE278(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 01954770)
//////////////////////////////////////////////////////////////////////////////////////////////

`include "top.v"

module testbench;

  reg clk_x70;
  reg start_x70;
  wire done_x70;
  reg [31:0] x1_x70;
  reg [31:0] x2_x70;
  reg [31:0] x3_x70;
  reg [31:0] x4_x70;
  reg [31:0] x5_x70;
  reg [31:0] x6_x70;
  wire [31:0] y1_x70;
  wire [31:0] y2_x70;
  wire [31:0] y3_x70;

  int clkcount;
  shortreal outputs [][];

  // Inputs from Mini-Project 2 document
  shortreal inputs [][] = '{
    '{0, 0,     0.0010,    -0.0076,    -0.0419,    -0.0413}, 
    '{0, 0,     0.0006,    -0.0189,     0.1693,     0.8295}, 
    '{0, 0,     0.0007,    -0.0049,    -0.0324,     0.0219}, 
    '{0, 0,          0,          0,          0,          0}, 
    '{0, 0,          0,          0,          0,          0}, 
    '{0, 0,          0,     0.0000,     0.0000,    -0.0000}, 
    '{0, 0,          0,          0,          0,          0}, 
    '{0, 0,          0,          0,          0,          0}, 
    '{0, 0,          0,     0.0000,    -0.0025,     0.0186}, 
    '{0, 0,          0,    -0.0004,    -0.0091,     0.1157}, 
    '{0, 0,    -0.0006,    -0.0176,     0.4083,     0.3129}, 
    '{0, 0,          0,          0,          0,          0}, 
    '{0, 0,          0,          0,          0,          0}, 
    '{0, 0,          0,    -0.0013,    -0.0164,     0.4042}, 
    '{0, 0,     0.0005,    -0.0144,     0.1278,     0.5787}, 
    '{0, 0,          0,          0,          0,          0}, 
    '{0, 0,          0,          0,     0.0002,    -0.0003}, 
    '{0, 0,          0,     0.0002,    -0.0017,    -0.0279}, 
    '{0, 0,          0,     0.0000,     0.0004,    -0.0014}, 
    '{0, 0,     0.0001,    -0.0022,     0.0081,     0.1616}, 
    '{0, 0,          0,     0.0000,    -0.0000,     0.0008}, 
    '{0, 0,     0.0000,    -0.0197,     0.2867,     0.9391}, 
    '{0, 0,     0.0000,     0.0004,    -0.0054,    -0.0314}, 
    '{0, 0,          0,          0,     0.0000,     0.0000}, 
    '{0, 0,          0,     0.0000,     0.0001,    -0.0002}, 
    '{0, 0,          0,    -0.0055,     0.0514,     0.5949}
  };
  

  // neural network design
  Neural_network nw(.*);

  // clock driver and counter
  always begin
    clkcount += 1;
    #5 clk_x70 = ~clk_x70;
  end
  always @(negedge start_x70) clkcount = 0;

  // main testbench code
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars;
    outputs = new[inputs.size()];

    clk_x70 = 0;
    start_x70 = 0;
    #100;

    for(int i = 0; i < inputs.size(); i++) begin

      // give inputs to the designed Neural Network 
      x1_x70 = $shortrealtobits(inputs[i][0]);
      x2_x70 = $shortrealtobits(inputs[i][1]);
      x3_x70 = $shortrealtobits(inputs[i][2]);
      x4_x70 = $shortrealtobits(inputs[i][3]);
      x5_x70 = $shortrealtobits(inputs[i][4]);
      x6_x70 = $shortrealtobits(inputs[i][5]);

      // apply start 
      @(posedge(clk_x70));
      start_x70 = 1;
      @(posedge(clk_x70));
      start_x70 = 0;

      // wait for done
      @(posedge(done_x70));

      // output displays
      $display("\n ##### Final NN output => y1_x70:%f, y2_x70:%f, y3_x70:%f (took %0d clocks to execute)", $bitstoshortreal(y1_x70), $bitstoshortreal(y2_x70), $bitstoshortreal(y3_x70), clkcount);
      outputs[i] = '{$bitstoshortreal(y1_x70), $bitstoshortreal(y2_x70), $bitstoshortreal(y3_x70)};

    end

    // Show final outputs at the end
    #1000;
    $display("-----------------------");
    $display("Final Outputs");
    $display("-----------------------");
    $display("\n");
    foreach(outputs[i]) begin
      $display("%10f, %10f, %10f", outputs[i][0], outputs[i][1], outputs[i][2]);
    end
    
    $display("\n\n");
    $finish;
  end

endmodule



