# Image-convolutional-circuit-design

### Overview
Using `verilog` to implement convolutional circuit

`CONV.v` is main file 

`testfixture` is testbench file

another file is data file

The convolution including **zero padding**, **convolutional operation**, **ReLU**, **max-pooling** and **flatten**

Those operation is seperated into 3 layer ( layer0, layer1 and layer2 )

### Layer0
#### zero padding
  padding zero around to original matrix(64\*64), new matrix becomes 66\*66 matrix
  
#### convolutional operation
  data format is 4,16 fix point number(4 bits for integer, others for floating point)
  
#### ReLU
  > if x < 0 => x = 0 
  >
  > else x = x
  
### Layer1
#### max pooling
  condense 64\*64 matrix into 32\*32
  
### Layer2
#### flatten
  merge two 32\*32 matrix into one 64\*64 matrix

