//////////////////////////////////////////////////////////////////////////////////////////////
// FILE: fp_adder.v
// Description: Floating Point Adder designed as a part of Mini-Project 1 of EE278(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 01954770)
//////////////////////////////////////////////////////////////////////////////////////////////

module fp_adder(
  input wire [31:0] inp1_x70,
  input wire [31:0] inp2_x70,
  input wire [0:0] clk_x70,
  output reg [31:0] sum_x70
);

reg [7:0] exponent_1, exponent_2;
reg [23:0] mantissa_1, mantissa_2;
reg [7:0] new_exponent;
reg [7:0] exponent_final;
reg [22:0] mantissa_final;
reg signed [23:0] mantissa_sum;
reg [23:0] shifted_mantissa_1,shifted_mantissa_2;
reg [24:0] add_mantissa_sum;
reg sign_1, sign_2, res_sign;
reg [7:0] diff;

always @(posedge clk_x70)
begin
  // get exponent and mantissa
  exponent_1=inp1_x70[30:23];
  exponent_2=inp2_x70[30:23];
  mantissa_1={1'b1,inp1_x70[22:0]};
  mantissa_2={1'b1,inp2_x70[22:0]};
  sign_1 = inp1_x70[31];
  sign_2 = inp2_x70[31];

  // adjust the mantissa and align the exponent
  if(exponent_1 == exponent_2)
  begin
    shifted_mantissa_1=mantissa_1;
    shifted_mantissa_2=mantissa_2;
    new_exponent=exponent_1;
  end
  else if(exponent_1>exponent_2)
  begin
    diff=exponent_1-exponent_2;
    shifted_mantissa_1=mantissa_1;
    shifted_mantissa_2=(mantissa_2>>>diff);
    new_exponent=exponent_1;
  end
  else if(exponent_2>exponent_1)
  begin
    diff=exponent_2-exponent_1;
    shifted_mantissa_2=mantissa_2;
    shifted_mantissa_1=(mantissa_1>>>diff);
    new_exponent=exponent_2;
  end


  //Compare the two aligned mantissas and determine which is the
  //smaller of the two. Take 2’s complement of the smaller mantissa
  //if the signs of the two numbers are different.
  res_sign = sign_1;
  if(sign_1 ^ sign_2) begin // different signs
    if(shifted_mantissa_1 < shifted_mantissa_2) begin
      res_sign = sign_2;
      shifted_mantissa_1 = (shifted_mantissa_1 ^ 24'hFF_FFFF) + 1;
    end
    else begin
      res_sign = sign_1;
      shifted_mantissa_2 = (shifted_mantissa_2 ^ 24'hFF_FFFF) + 1;
    end
  end


  //Add the two mantissa. Then, determine the amount of shifts
  //required and the corresponding direction to normalize the result.
  exponent_final=new_exponent;
  add_mantissa_sum = shifted_mantissa_1 + shifted_mantissa_2;
  //mantissa_final=add_mantissa_sum[22:0];
  if(sign_1 ^ sign_2 == 0) begin
    if(add_mantissa_sum[24] == 1) begin //carry
      exponent_final += 1;
      add_mantissa_sum = add_mantissa_sum >> 1;
    end
  end

  //Stage 5: Shift the mantissa to the required direction by the required amount. Adjust the exponent 
  //accordingly and check for any exceptional condition (normalization-2). 
  repeat(23) begin
    if(add_mantissa_sum[23]==0)
    begin
      add_mantissa_sum =(add_mantissa_sum <<1'b1);
      exponent_final=exponent_final-1'b1;
    end
    else begin
      break;
    end
  end
  mantissa_final = add_mantissa_sum[22:0]; 

end

assign sum_x70 = {res_sign, exponent_final, mantissa_final};

endmodule

