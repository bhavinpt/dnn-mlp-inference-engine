# DNN/MLP Inference Engine
RTL of a scalable custom FP MAC unit array to achieve higher throughput of a two layer MLP Inference


An artificial neural network algorithm primarily consists of MAC operations. So,
implementing them directly in hardware can allow large gains when scaling the network
sizes. In this work, a neural network is designed with the pipelined MAC units.

![image](https://github.com/bhavinpt/dnn-mlp-inference-engine/assets/117598876/83acd92b-b7f6-40ad-a1e0-c53a939ba43d)

With five 6-bit input patterns, 4 hidden nodes, and
3x 32-bit outputs, the implemented hardware neural network makes decisions on a set
of input patterns in 58 clock cycles. The project helps understand the computational
requirements of a neural network operation and also how parallel MACs can
significantly reduce the overall latency of the network as compared to the CPU which
does the operations sequentially.

## Design Architecture

![image](https://github.com/bhavinpt/dnn-mlp-inference-engine/assets/117598876/f912733d-b015-4d5e-bb9f-ebe5f182d9ef)

The hidden layer and output layers are executed sequentially to get the final output of the given network
## Input Layer

![image](https://github.com/bhavinpt/dnn-mlp-inference-engine/assets/117598876/275b1932-0cbf-492d-8392-1d494940b8b4)

Input layer does the below operations for the 1st MAC unit on each clock number.

1st => X1 * W11

2nd => X2 * W21 + X1 * W11

3rd => X3 * W31 + X2 * W21 + X1 * W11

4th => X4 * W41 + X3 * W31 + X2 * W21 + X11 * W11

5th => X5 * W51 + X4 * W41 + X3 * W31 + X2 * W21 + X11 * W11

6th => X6 * W61 + X5 * W51 + X4 * W41 + X3 * W31 + X2 * W21 + X11 * W11

Remaining MAC units will also perform similar operation simultaneously.

## Output Layer

![image](https://github.com/bhavinpt/dnn-mlp-inference-engine/assets/117598876/1e53dc55-5ad1-467e-8bbb-33469fe68e78)

Output layer does the below operations for the 1st MAC unit on each clock number.


1st => Hy1 * W11

2nd => Hy2 * W21 + Hy1 * W11

3rd => Hy3 * W31 + Hy2 * W21 + Hy1 * W11

4th => Hy4 * W41 + Hy3 * W31 + Hy2 * W21 + Hy11 * W11

Remaining MAC units will also perform similar operation simultaneously.


## Resource Requirements

Overall Resource Requirement for the given Neural Network

7x 32-bit MAC

2x 4 to 1 Mux

3x 8 to 1 Mux

1x 144-Byte memory to store all the weights

1x 2-bit counter

1x 3-bit counter

1x T-Flip Flop

Please find the RTL design, simulation results, and the waveforms in this repo.

The given design is flexible to include any number of neurons/layer for multiple layers
