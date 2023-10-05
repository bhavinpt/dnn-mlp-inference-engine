//////////////////////////////////////////////////////////////////////////////////////////////
// FILE: output_layer.v
// Description: Hidden Layer of Neural Network designed as a part of Mini-Project 2 of EE278(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 01954770)
//////////////////////////////////////////////////////////////////////////////////////////////


// 4 input, 3 neurons, 3 output
module Layer4to3(
  input wire clk_x70,
  input wire reset_x70,
  output reg done_x70,
  input [31:0] x1_x70,
  input [31:0] x2_x70,
  input [31:0] x3_x70,
  input [31:0] x4_x70,
  output reg [31:0] y1_x70,
  output reg [31:0] y2_x70,
  output reg [31:0] y3_x70
);

  wire [31:0] y1_out, y2_out, y3_out;
  reg [31:0] mux_x_out, mux_w1_out, mux_w2_out, mux_w3_out;
  reg [3:0] inp_neuron_sel;
  reg [1:0] mac_stage;
  wire clkout;
  
  
  // Instances of MAC units
  Mac m1(clkout, reset_x70, mux_x_out, mux_w1_out, y1_out);
  Mac m2(clkout, reset_x70, mux_x_out, mux_w2_out, y2_out);
  Mac m3(clkout, reset_x70, mux_x_out, mux_w3_out, y3_out);

  
  // Weights from Mini-Project 2 document
  // -0.8861   -0.3545    1.3471 
  // -1.8118    0.6085    3.5054 
  // -1.5205    1.9607   -2.1386 
  //  2.7008    1.1139   -1.0623 
  // -1.0033   -0.8877   -0.8463
  
  // axon weights[i][j] i=input side neuron j=output side neuron
  reg [31:0] weights[3][4] = '{
    '{$shortrealtobits(-0.8861), $shortrealtobits(-1.8118), $shortrealtobits(-1.5205), $shortrealtobits(2.7008)}, // weights to j1 from i[1-4]
    '{$shortrealtobits(-0.3545), $shortrealtobits(0.6085), $shortrealtobits(1.9607), $shortrealtobits(1.1139)}, // weights to j2 from i[1-4]
    '{$shortrealtobits(1.3471), $shortrealtobits(3.5054), $shortrealtobits(-2.1386), $shortrealtobits(-1.0623)}  // weights to j3 from i[1-4]
  };

  
  // clock for MACs
  assign clkout = clk_x70;
  

  // initialize
  initial begin
    inp_neuron_sel = 0;
    mac_stage = 0;
    done_x70 = 0;
  end
  
  // main
  always @(posedge clk_x70) begin
  
    if(reset_x70) begin
      inp_neuron_sel = 0;
      mac_stage = 0;
      done_x70 = 0;
    end
  
    else begin
  
      // give X1 to X4 one-by-one
      if(mac_stage == 0) begin
        case(inp_neuron_sel)
  	0: begin mux_x_out = x1_x70; mux_w1_out = weights[0][0]; mux_w2_out = weights[1][0]; mux_w3_out = weights[2][0]; end 
  	1: begin mux_x_out = x2_x70; mux_w1_out = weights[0][1]; mux_w2_out = weights[1][1]; mux_w3_out = weights[2][1]; end
  	2: begin mux_x_out = x3_x70; mux_w1_out = weights[0][2]; mux_w2_out = weights[1][2]; mux_w3_out = weights[2][2]; end
  	3: begin mux_x_out = x4_x70; mux_w1_out = weights[0][3]; mux_w2_out = weights[1][3]; mux_w3_out = weights[2][3]; end
        endcase
        $display("\tx%0d=%10f * w%0d1=%10f w%0d2=%10f w%0d3=%10f", 
  	(inp_neuron_sel + 1), $bitstoshortreal(mux_x_out), 
  	(inp_neuron_sel + 1), $bitstoshortreal(mux_w1_out),
  	(inp_neuron_sel + 1), $bitstoshortreal(mux_w2_out),
  	(inp_neuron_sel + 1), $bitstoshortreal(mux_w3_out)
        );
  
      end
      mac_stage += 1;
  
      // 1 MAC operation takes 3 clocks, set the output when all X1 to X4 are MAC'ed
      if(mac_stage == 3) begin
        inp_neuron_sel += 1;
        mac_stage = 0;
        $display("\t                y1_x70 =%10f  y2_x70=%10f  y3_x70=%10f", $bitstoshortreal(y1_out), $bitstoshortreal(y2_out), $bitstoshortreal(y3_out));
        if(inp_neuron_sel == 4) begin
  
  	// ReLU activation function
  	y1_x70 = (y1_out[31] == 1) ? 'b0 : y1_out;
  	y2_x70 = (y2_out[31] == 1) ? 'b0 : y2_out;
  	y3_x70 = (y3_out[31] == 1) ? 'b0 : y3_out;
  
  	inp_neuron_sel = 0;
  	done_x70 = 1;
  	$display("\n\tAfter ReLU      y1_x70=%10f y2_x70=%10f y3_x70=%10f", $bitstoshortreal(y1_x70), $bitstoshortreal(y2_x70), $bitstoshortreal(y3_x70));
        end
      end
    end
  
  end

endmodule


