//////////////////////////////////////////////////////////////////////////////////////////////
// FILE: hidden_layer.v
// Description: Output Layer of Neural Network designed as a part of Mini-Project 2 of EE278(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 01954770)
//////////////////////////////////////////////////////////////////////////////////////////////

// 6 input, 4 neurons, 4 output
module Layer6to4(
  input wire clk_x70,
  input wire reset_x70,
  output reg done_x70,
  input [31:0] x1_x70,
  input [31:0] x2_x70,
  input [31:0] x3_x70,
  input [31:0] x4_x70,
  input [31:0] x5_x70,
  input [31:0] x6_x70,
  output reg [31:0] y1_x70,
  output reg [31:0] y2_x70,
  output reg [31:0] y3_x70,
  output reg [31:0] y4_x70
);

  wire [31:0] y1_out, y2_out, y3_out, y4_out;
  reg [31:0] mux_x_out, mux_w1_out, mux_w2_out, mux_w3_out, mux_w4_out;
  reg [3:0] inp_neuron_sel;
  reg [1:0] mac_stage;
  wire clkout;
  
  
  // Instances of MAC units
  Mac m1(clkout, reset_x70, mux_x_out, mux_w1_out, y1_out);
  Mac m2(clkout, reset_x70, mux_x_out, mux_w2_out, y2_out);
  Mac m3(clkout, reset_x70, mux_x_out, mux_w3_out, y3_out);
  Mac m4(clkout, reset_x70, mux_x_out, mux_w4_out, y4_out);
  
  // Weights from Mini-Project 2 document
  //  0.2890   -0.1427    0.1375   -0.0402 
  //  0.0077   -0.0016    0.0247    0.0127 
  // -0.0003   -0.0055    0.0009   -0.0009 
  // -0.0843    0.0455    0.0487    0.1000 
  // -0.3052   -0.0680   -0.0472    0.3983 
  // -0.3977   -0.4722   -0.3125   -0.0184 
  // -0.2209   -0.2556   -0.1011   -0.2383 
  
  // axon weights[i][j] i=input side neuron j=output side neuron
  reg [31:0] weights[4][6] = '{
    '{$shortrealtobits(0.2890), $shortrealtobits(0.0077), $shortrealtobits(-0.0003), $shortrealtobits(-0.843), $shortrealtobits(-0.3052), $shortrealtobits(-0.3977)}, // weights to j1 from i[1-6]
    '{$shortrealtobits(-0.1427), $shortrealtobits(-0.0016), $shortrealtobits(-0.0055), $shortrealtobits(0.0455), $shortrealtobits(0.0680), $shortrealtobits(0.4722)}, // weights to j2 from i[1-6]
    '{$shortrealtobits(0.1357), $shortrealtobits(0.0247), $shortrealtobits(0.0009), $shortrealtobits(0.0487), $shortrealtobits(-0.0472), $shortrealtobits(-0.3125)}, // weights to j3 from i[1-6]
    '{$shortrealtobits(-0.0402), $shortrealtobits(0.0127), $shortrealtobits(-0.0009), $shortrealtobits(0.1000), $shortrealtobits(0.3983), $shortrealtobits(-0.0184)}  // weights to j4 from i[1-6]
  };
  

  // clock for MACs
  assign clkout = clk_x70;
  

  // initialize 
  initial begin
    inp_neuron_sel = 0;
    mac_stage = 0;
    done_x70 = 0;
  end
  

  always @(posedge clk_x70) begin
  
    if(reset_x70) begin
      inp_neuron_sel = 0;
      mac_stage = 0;
      done_x70 = 0;
    end
  
    else begin
  
      // give X1 to X6 one-by-one
      if(mac_stage == 0) begin
        case(inp_neuron_sel)
  	0: begin mux_x_out = x1_x70; mux_w1_out = weights[0][0]; mux_w2_out = weights[1][0]; mux_w3_out = weights[2][0]; mux_w4_out = weights[3][0]; end 
  	1: begin mux_x_out = x2_x70; mux_w1_out = weights[0][1]; mux_w2_out = weights[1][1]; mux_w3_out = weights[2][1]; mux_w4_out = weights[3][1]; end
  	2: begin mux_x_out = x3_x70; mux_w1_out = weights[0][2]; mux_w2_out = weights[1][2]; mux_w3_out = weights[2][2]; mux_w4_out = weights[3][2]; end
  	3: begin mux_x_out = x4_x70; mux_w1_out = weights[0][3]; mux_w2_out = weights[1][3]; mux_w3_out = weights[2][3]; mux_w4_out = weights[3][3]; end
  	4: begin mux_x_out = x5_x70; mux_w1_out = weights[0][4]; mux_w2_out = weights[1][4]; mux_w3_out = weights[2][4]; mux_w4_out = weights[3][4]; end
  	5: begin mux_x_out = x6_x70; mux_w1_out = weights[0][5]; mux_w2_out = weights[1][5]; mux_w3_out = weights[2][5]; mux_w4_out = weights[3][5]; end
        endcase
        $display("\tx%0d=%10f * w%0d1=%10f w%0d2=%10f w%0d3=%10f w%0d4=%10f", 
  	(inp_neuron_sel + 1), $bitstoshortreal(mux_x_out), 
  	(inp_neuron_sel + 1), $bitstoshortreal(mux_w1_out),
  	(inp_neuron_sel + 1), $bitstoshortreal(mux_w2_out),
  	(inp_neuron_sel + 1), $bitstoshortreal(mux_w3_out),
  	(inp_neuron_sel + 1), $bitstoshortreal(mux_w4_out)
        );
  
      end
      mac_stage += 1;
      
      // 1 MAC operation takes 3 clocks, set the output when all X1 to X6 are MAC'ed
      if(mac_stage == 3) begin
        inp_neuron_sel += 1;
        mac_stage = 0;
        $display("\t                hy1=%10f hy2=%10f hy3=%10f hy4=%10f", $bitstoshortreal(y1_out), $bitstoshortreal(y2_out), $bitstoshortreal(y3_out), $bitstoshortreal(y4_out));
        if(inp_neuron_sel == 6) begin
  
  	// ReLU activation function
  	y1_x70 = (y1_out[31] == 1) ? 'b0 : y1_out;
  	y2_x70 = (y2_out[31] == 1) ? 'b0 : y2_out;
  	y3_x70 = (y3_out[31] == 1) ? 'b0 : y3_out;
  	y4_x70 = (y3_out[31] == 1) ? 'b0 : y4_out;
  
  	inp_neuron_sel = 0;
  	done_x70 = 1;
  	$display("\n\tAfter ReLU      hy1=%10f hy2=%10f hy3=%10f hy4=%10f", $bitstoshortreal(y1_x70), $bitstoshortreal(y2_x70), $bitstoshortreal(y3_x70), $bitstoshortreal(y4_x70));
        end
      end
    end
  
  end

endmodule

