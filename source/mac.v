//////////////////////////////////////////////////////////////////////////////////////////////
// FILE: mac.v
// Description: MAC unit designed as a part of Mini-Project 1 of EE278(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 01954770)
//////////////////////////////////////////////////////////////////////////////////////////////

`include "fp_adder.v"
`include "fp_mult.v"

module Mac(
  input wire clk_x70,
  input wire reset_x70,
  input wire [31:0] inp1_x70, 
  input wire [31:0] inp2_x70,
  output wire [31:0] out_x70
);

wire [31:0] mul_out_x70;
wire [31:0] sum_out_x70;
reg [31:0] sum_buff = 0;

assign out_x70 = sum_out_x70;
wire underflow_x70;
wire overflow_x70;

reg mul_clk_x70, add_clk_x70, buf_clk_x70;
integer clk_x70num = 0;

always @(posedge reset_x70) begin
  sum_buff = 0;
end

//always @(mul_out_x70)begin
//end

always@(posedge clk_x70) begin
  if(reset_x70) begin
    sum_buff = 0;
    clk_x70num = 0;
  end
  else begin
    case(clk_x70num) 
      0: begin 
	mul_clk_x70 = 1; add_clk_x70 = 0; buf_clk_x70 = 0; 
      end
      1: begin 
	//$display("mul_out: %f, inp1:%f, inp2:%f", $bitstoshortreal(mul_out_x70), $bitstoshortreal(inp1_x70), $bitstoshortreal(inp2_x70));
	mul_clk_x70 = 0; add_clk_x70 = 1; buf_clk_x70 = 0; 
      end
      2: begin 
	mul_clk_x70 = 0; add_clk_x70 = 0; buf_clk_x70 = 1; 
	sum_buff = sum_out_x70;
      end
    endcase

    clk_x70num++;
    if(clk_x70num > 2)
      clk_x70num = 0;
  end
end

fp_adder add1(.clk_x70(add_clk_x70), .inp1_x70(mul_out_x70), .inp2_x70(sum_buff), .sum_x70(sum_out_x70));
fp_mul_unpipe mult( .inp1_x70(inp1_x70), .inp2_x70(inp2_x70), .out_x70(mul_out_x70), .underflow_x70(underflow_x70),.overflow_x70(overflow_x70));
endmodule

