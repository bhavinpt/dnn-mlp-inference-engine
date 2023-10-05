//////////////////////////////////////////////////////////////////////////////////////////////
// FILE: top.v
// Description: Top level unit of Neural Network designed as a part of Mini-Project 2 of EE278(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 01954770)
//////////////////////////////////////////////////////////////////////////////////////////////


`include "mac.v"
`include "hidden_layer.v"
`include "output_layer.v"


// 6 input, 4 neurons, 4 output
module Neural_network(
  input wire clk_x70,
  input wire start_x70,
  output reg done_x70,
  input [31:0] x1_x70,
  input [31:0] x2_x70,
  input [31:0] x3_x70,
  input [31:0] x4_x70,
  input [31:0] x5_x70,
  input [31:0] x6_x70,
  output [31:0] y1_x70,
  output [31:0] y2_x70,
  output [31:0] y3_x70
);

wire [31:0] hy1;
wire [31:0] hy2;
wire [31:0] hy3;
wire [31:0] hy4;

wire inp_layer_done;
reg out_layer_reset;
reg in_layer_reset;

initial begin
  out_layer_reset = 1;
  in_layer_reset = 1;
end

// hidden layer
Layer6to4 inp_layer(
  .clk_x70(clk_x70),
  .reset_x70(in_layer_reset),
  .x1_x70(x1_x70),
  .x2_x70(x2_x70),
  .x3_x70(x3_x70),
  .x4_x70(x4_x70),
  .x5_x70(x5_x70),
  .x6_x70(x6_x70),
  .y1_x70(hy1),
  .y2_x70(hy2),
  .y3_x70(hy3),
  .y4_x70(hy4),
  .done_x70(inp_layer_done)
);

// output layer
Layer4to3 out_layer(
  .clk_x70(clk_x70),
  .reset_x70(out_layer_reset),
  .x1_x70(hy1),
  .x2_x70(hy2),
  .x3_x70(hy3),
  .x4_x70(hy4),
  .y1_x70(y1_x70),
  .y2_x70(y2_x70),
  .y3_x70(y3_x70),
  .done_x70(done_x70)
);

always@(posedge start_x70) begin

  $display("\n\n###########################\n");

  // step 1: restart input layer, and put output layer on hold
  $display(" ##### started hidden layer @t=%0t\n", $time);
  out_layer_reset = 1;
  in_layer_reset = 1;
  @(posedge clk_x70);
  in_layer_reset = 0;

  // step 2: let input layer finish
  @(posedge inp_layer_done);
  $display("\n ##### hidden layer done_x70, started output layer @t=%0t\n", $time);

  // step 3: restart output layer, and put input layer on hold
  in_layer_reset = 1;
  out_layer_reset = 1;
  @(posedge clk_x70);
  out_layer_reset = 0;

  // step 4: let output layer finish, and put both layer on hold
  @(posedge done_x70);
  in_layer_reset = 1;
  out_layer_reset = 1;
  $display("\n ##### output layer done_x70 @t=%0t", $time);
  $display("\n---------------------------\n\n");

end

endmodule


