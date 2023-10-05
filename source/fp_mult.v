//////////////////////////////////////////////////////////////////////////////////////////////
// FILE: fp_mult.v
// Description: Floating Point Multiplier designed as a part of Mini-Project 1 of EE278(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 01954770)
//////////////////////////////////////////////////////////////////////////////////////////////

module sign_bit(
  output wire sign_x70,
  input wire [31:0] in1_x70,
  input wire [31:0] in2_x70
);
  xor (sign_x70, in1_x70 [31], in2_x70 [31]); 
endmodule


// simply truncates multiplication of two mantissa into 240bits 
module normalize(
  output wire[22:0] adj_mantissa_x70,
  output wire norm_flag_x70,
  input wire[47:0] prdt_x70
);
  
  and(norm_flag_x70, prdt_x70[47], 1'b1);
  // if leading 1 is at pos 47 then needs normalization, otherwise not
  
  wire [1:0][22:0] result;
  assign result[0] = prdt_x70[45:23];
  assign result[1] = prdt_x70[46:24];
  assign adj_mantissa_x70 = {result[norm_flag_x70 + 0]};
endmodule
                      
//8 bit Ripple-carry adder
module ripple_8(
output wire[7:0] sum_x70,
output wire cout_x70,
input wire[7:0] in1_x70,
input wire[7:0] in2_x70,
input wire cin_x70
);
wire c1_x70,c2_x70,c3_x70,c4_x70,c5_x70,c6_x70,c7_x70;
full_adder FA1(sum_x70[0],c1_x70,in1_x70[0],in2_x70[0],cin_x70);
full_adder FA2(sum_x70[1],c2_x70,in1_x70[1],in2_x70[1],c1_x70);
full_adder FA3(sum_x70[2],c3_x70,in1_x70[2],in2_x70[2],c2_x70);
full_adder FA4(sum_x70[3],c4_x70,in1_x70[3],in2_x70[3],c3_x70);
full_adder FA5(sum_x70[4],c5_x70,in1_x70[4],in2_x70[4],c4_x70);
full_adder FA6(sum_x70[5],c6_x70,in1_x70[5],in2_x70[5],c5_x70);
full_adder FA7(sum_x70[6],c7_x70,in1_x70[6],in2_x70[6],c6_x70);
full_adder FA8(sum_x70[7],cout_x70,in1_x70[7],in2_x70[7],c7_x70);
endmodule

//1 bit Full Adder
module full_adder(
  output wire sum_x70,
  output wire cout_x70,
  input wire in1_x70,
  input wire in2_x70,
  input wire cin_x70
);
wire temp1_x70;
wire temp2_x70;
wire temp3_x70;
xor(sum_x70,in1_x70,in2_x70,cin_x70);
and(temp1_x70,in1_x70,in2_x70);
and(temp2_x70,in1_x70,cin_x70);
and(temp3_x70,in2_x70,cin_x70);
or(cout_x70,temp1_x70,temp2_x70,temp3_x70);
endmodule

//1 bit subtractor with subtrahend = 1
module full_subtractor_sub1(
  output wire diff_x70, //diff_x70erence
  output wire bout_x70,//borrow out
  input wire min_x70,//min_x70uend
  input wire bin_x70//borrow in
);
  
  //Here, the subtrahend is always 1. We can implement it
  xnor (diff_x70,min_x70, bin_x70);
  or (bout_x70, ~min_x70, bin_x70);
endmodule
  
    
//1 bit subtractor with subtrahend = 0
module full_subtractor_sub0(
  output wire diff_x70, //diff_x70erence
  output wire bout_x70, //borrow out
  input wire min_x70, //min_x70uend 
  input wire bin_x70 //borrow in
);
  //Here, the subtrahend is always 0.We can implement it
  xor (diff_x70,min_x70, bin_x70);
  and (bout_x70, ~min_x70, bin_x70); 
endmodule
       
module subtractor_9( 
  output wire [8:0] diff_x70,
  output wire bout_x70,
  input wire [8:0] min_x70,
  input wire bin_x70
); 
  
  wire b1, b2,b3,b4, b5, b6,b7,b8;
  full_subtractor_sub1 sub1 (diff_x70 [0], b1,min_x70 [0], bin_x70);
  full_subtractor_sub1 sub2 (diff_x70 [1], b2,min_x70 [1],b1);
  full_subtractor_sub1 sub3 (diff_x70 [2], b3,min_x70 [2], b2);
  full_subtractor_sub1 sub4 (diff_x70 [3], b4,min_x70 [3],b3); 
  full_subtractor_sub1 sub5 (diff_x70 [4], b5,min_x70 [4], b4);
  full_subtractor_sub1 sub6 (diff_x70 [5], b6,min_x70 [5], b5);
  full_subtractor_sub1 sub7 (diff_x70 [6], b7,min_x70 [6],b6);
  full_subtractor_sub0 sub8 (diff_x70 [7], b8,min_x70 [7],b7); 
  full_subtractor_sub0 sub9 (diff_x70 [8], bout_x70,min_x70[8], b8);

endmodule

module block(
  output wire ppo_x70, //output partial product term
  output wire cout_x70, //output carry out
  output wire mout_x70, //output multiplicand term 

  input wire min_x70, //input multiplicand term
  input wire ppi_x70, //input partial product term
  input wire q_x70, //input multiplier term
  input wire cin //input carry in
);
wire temp; 
and (temp,min_x70,q_x70);
full_adder FA_x70(ppo_x70, cout_x70,ppi_x70, temp, cin); // connected to : a, b, cin, sum, cout_x70
or (mout_x70,min_x70, 1'b0);
endmodule


module row(
  output wire [23:0] ppo_x70,
  output wire [23:0] mout_x70,
  output wire sum, 
  input wire [23:0] min_x70,
  input wire [23:0] ppi_x70,
  input wire q_x70
);

wire c1, c2, c3, c4, c5, c6, c7,c8, c9, c10;
wire c11, c12, c13, c14, c15, c16, c17, c18, c19, c20; 
wire c21, c22, c23;

block b1 (sum,c1,mout_x70 [0],min_x70[0],ppi_x70[0],q_x70,1'b0);
block b2 (ppo_x70[0], c2, mout_x70 [1], min_x70 [1], ppi_x70[1], q_x70, c1);
block b3 (ppo_x70[1], c3, mout_x70 [2], min_x70 [2], ppi_x70 [2], q_x70, c2); 
block b4 (ppo_x70[2], c4, mout_x70 [3], min_x70 [3], ppi_x70 [3], q_x70, c3);
block b5 (ppo_x70[3], c5, mout_x70 [4], min_x70 [4], ppi_x70 [4], q_x70, c4); 
block b6 (ppo_x70[4], c6, mout_x70 [5], min_x70 [5], ppi_x70 [5], q_x70, c5);
block b7 (ppo_x70[5], c7, mout_x70 [6], min_x70 [6], ppi_x70 [6], q_x70, c6); 
block b8 (ppo_x70[6], c8, mout_x70 [7], min_x70 [7], ppi_x70[7], q_x70, c7);
block b9 (ppo_x70[7], c9, mout_x70 [8], min_x70 [8], ppi_x70 [8], q_x70, c8);
block b10(ppo_x70[8], c10, mout_x70 [9], min_x70[9], ppi_x70 [9], q_x70, c9);
block b11(ppo_x70[9], c11, mout_x70 [10], min_x70 [10], ppi_x70 [10], q_x70, c10);
block b12(ppo_x70[10], c12, mout_x70 [11], min_x70 [11], ppi_x70 [11], q_x70, c11); 
block b13(ppo_x70[11], c13, mout_x70 [12], min_x70 [12], ppi_x70 [12], q_x70, c12); 
block b14(ppo_x70[12], c14, mout_x70 [13], min_x70 [13], ppi_x70 [13], q_x70, c13);
block b15(ppo_x70[13], c15, mout_x70 [14], min_x70 [14], ppi_x70 [14], q_x70, c14); 
block b16(ppo_x70[14], c16, mout_x70 [15], min_x70 [15], ppi_x70 [15], q_x70, c15);
block b17(ppo_x70[15], c17, mout_x70 [16], min_x70 [16], ppi_x70 [16], q_x70, c16); 
block b18(ppo_x70[16], c18, mout_x70 [17], min_x70 [17], ppi_x70 [17], q_x70, c17); 
block b19(ppo_x70[17], c19, mout_x70 [18], min_x70 [18], ppi_x70 [18], q_x70, c18);
block b20(ppo_x70[18], c20, mout_x70 [19], min_x70 [19], ppi_x70 [19], q_x70, c19); 
block b21(ppo_x70[19], c21, mout_x70 [20], min_x70 [20], ppi_x70 [20], q_x70, c20);
block b22(ppo_x70[20], c22, mout_x70 [21], min_x70 [21], ppi_x70 [21], q_x70, c21);
block b23(ppo_x70[21], c23, mout_x70 [22], min_x70 [22], ppi_x70 [22], q_x70, c22); 
block b24(ppo_x70[22], ppo_x70 [23], mout_x70 [23], min_x70[23], ppi_x70 [23], q_x70, c23);
endmodule


module product(
  output wire [47:0] sum,
  input wire [23:0] min_x70,
  input wire [23:0]q_x70
);
wire [23:0] temp1,temp2, temp3,temp4, temp5,temp6, temp7, temp8, temp9,temp10; 
wire [23:0] temp11,temp12, temp13,temp14,temp15,temp16, temp17,temp18, temp19, temp20; 
wire [23:0] temp21,temp22,temp23,temp24;

wire [23:0] ptemp1, ptemp2, ptemp3,ptemp4, ptemp5, ptemp6,ptemp7,ptemp8,ptemp9,ptemp10;
wire [23:0] ptemp11,ptemp12,ptemp13,ptemp14,ptemp15,ptemp16,ptemp17,ptemp18,ptemp19,ptemp20;
wire [23:0] ptemp21, ptemp22,ptemp23; 

row r1 (ptemp1, temp1, sum[0], min_x70, 24'h000000, q_x70[0]);
row r2 (ptemp2, temp2, sum[1], temp1, ptemp1, q_x70[1]);
row r3 (ptemp3, temp3, sum[2], temp2, ptemp2, q_x70[2]); 
row r4 (ptemp4, temp4, sum[3], temp3, ptemp3, q_x70[3]);
row r5 (ptemp5, temp5, sum[4], temp4, ptemp4, q_x70[4]);
row r6 (ptemp6, temp6, sum[5], temp5, ptemp5, q_x70[5]);
row r7 (ptemp7, temp7, sum[6], temp6, ptemp6, q_x70[6]); 
row r8 (ptemp8, temp8, sum[7], temp7, ptemp7, q_x70[7]);
row r9 (ptemp9, temp9, sum[8], temp8, ptemp8, q_x70[8]); 
row r10(ptemp10, temp10, sum [9], temp9, ptemp9, q_x70[9]);
row r11(ptemp11, temp11, sum [10], temp10, ptemp10, q_x70[10]); 
row r12(ptemp12, temp12, sum[11], temp11, ptemp11, q_x70[11]);
row r13(ptemp13, temp13, sum [12], temp12, ptemp12, q_x70[12]);
row r14(ptemp14, temp14, sum [13], temp13, ptemp13, q_x70[13]);
row r15(ptemp15, temp15, sum [14], temp14, ptemp14, q_x70[14]);
row r16(ptemp16, temp16, sum[15], temp15, ptemp15, q_x70[15]);
row r17(ptemp17, temp17, sum[16], temp16, ptemp16, q_x70[16]); 
row r18 (ptemp18, temp18, sum [17], temp17, ptemp17, q_x70[17]); 
row r19 (ptemp19, temp19, sum [18], temp18, ptemp18, q_x70[18]);
row r20 (ptemp20, temp20, sum [19], temp19, ptemp19, q_x70[19]); 
row r21 (ptemp21, temp21, sum [20], temp20, ptemp20, q_x70[20]);
row r22(ptemp22, temp22, sum [21], temp21, ptemp21, q_x70[21]);
row r23(ptemp23, temp23, sum [22], temp22, ptemp22, q_x70[22]); 
row r24(sum[47:24], temp24, sum [23], temp23, ptemp23, q_x70[23]);
endmodule

//Control module to drive and regulate required modules in order
module fp_mul_unpipe(
  input wire [31:0] inp1_x70, 
  input wire [31:0] inp2_x70,
  output wire [31:0] out_x70,
  output wire underflow_x70,
  output wire overflow_x70
);
  wire sign;
  wire [7:0] exp1;
  wire [7:0] exp2;
  wire [7:0] exp_out_x70;
  wire [7:0] test_exp;
  wire [22:0] manti;
  wire [22:0] mant2;
  wire [22:0] mant_out_x70;
  wire [31:0] tmp_out_x70;
  
  sign_bit sign_bit1_x70 (sign, inp1_x70, inp2_x70);
        
  wire [7:0] temp1;
  wire dummy; //to connect unused cout_x70 ports of adder 
  wire carry;
  wire [8:0] add_out;
  wire [8:0] sub_temp;
  wire [7:0] sub_temp_low;
  wire [7:0] sub_temp_high;
  reg zero = 0;
  reg one = 1;


  assign exp1 = inp1_x70[30:23];
  assign exp2 = inp2_x70[30:23];
  assign sub_temp_low = sub_temp[7:0];
  assign sub_temp_high = sub_temp[8];
  assign add_out = {carry, temp1};
        
  ripple_8 rip1_x70 (temp1, carry, exp1, exp2, zero);
  subtractor_9 sub1_x70 (sub_temp, underflow_x70, add_out, zero);
  
  //if there is a carry out_x70 => underflow_x70
  and (overflow_x70, sub_temp_high, one); //if the exponent has more than 8
  
  //taking product of mantissa:
  wire [47:0] prdt;
  wire [23:0] p_in1;
  wire [23:0] p_in2;
  assign p_in1 = {1'b1, inp1_x70[22:0]};
  assign p_in2 = {1'b1, inp2_x70[22:0]};
  product pi_x70(prdt, p_in1, p_in2);
  
  // normalizing mantissa
  wire norm_flag;
  wire [22:0] adj_mantissa;
  normalize normi (adj_mantissa,norm_flag,prdt); 
  wire [7:0] norm_in2;
  assign norm_in2 = {7'b0, norm_flag};
  ripple_8 ripple_norm_x70(test_exp, dummy, sub_temp_low, norm_in2, zero);
  
  assign tmp_out_x70 [31] = sign;
  assign tmp_out_x70 [30:23] = test_exp;
  assign tmp_out_x70 [22:0] = adj_mantissa;
  assign out_x70 = (inp1_x70[30:0] == 0 || inp2_x70[30:0] == 0) ? 'b0 : tmp_out_x70;
                                
endmodule
