#!/bin/bash

https://github.com/rusty1s/pytorch_sparse.git
cd pytorch_sparse/conda/pytorch-sparse

module load cuda/11.8
export FORCE_CUDA=1
export TORCH_CUDA_ARCH_LIST='5.2 6.0 6.1 7.0 7.5 8.0 8.6+PTX'
export NVCC_FLAGS=-L/usr/lib64 # => libmetis.so when yum install metis64-devel metis64

./build_conda.sh 3.10 2.1.0 cu118
