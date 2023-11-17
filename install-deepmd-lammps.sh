#!/bin/bash

# !! 注意
# redhat devtool 中的gcc/g++在编译deepmd-kit c++接口时会报错，devtool在编译tensorflow时
# 也会报错，因此推荐不要用 devtool ，直接用spack安一个gcc
# 
# centos7中可能也需要手动编译一遍tensorflow

# download lammps source code:
#cd ~/lammps
#wget https://github.com/lammps/lammps/archive/stable_23Jun2022_update4.tar.gz
#tar xf stable_23Jun2022_update4.tar.gz
# set lammps_root
#cd lammps-stable_23Jun2022_update4
#export lammps_root=$(pwd)

# 关于 OP_CXX_ABI:
# centos7 的 devtool 无法自动检测到 gcc 的 ABI 版本，需要手动设置，
# 但是更推荐的办法是用spack自己装一个gcc
export DP_VARANT=cuda
export CMAKE_ARGS="-DCMAKE_CXX_COMPILER=$(which g++) -DCMAKE_C_COMPILER=$(which gcc)"
export deepmd_source_dir=$HOME/deepmd-kit
export deepmd_root=$HOME/deepmd_root
export lammps_root=$HOME/lammps/lammps-stable_23Jun2022_update4

conda create --name tf8 python=3.8
conda activate tf8
cd $deepmd_source_dir
pip install tensorflow
pip install .

cd $deepmd_source_dir/source
mkdir build && cd $_
cmake -DUSE_TF_PYTHON_LIBS=TRUE -DCMAKE_INSTALL_PREFIX=$deepmd_root -DUSE_CUDA_TOOLKIT=TRUE -DLAMMPS_SOURCE_ROOT=$lammps_root ..
make -j
make install

cd $lammps_root
mkdir build && cd $_
# ensure $(which python) is using python from conda firstly
# maybe `spack unload python` should be executed firstly

# build with options
# cmake -D PKG_PLUGIN=ON -D PKG_KSPACE=ON -D LAMMPS_INSTALL_RPATH=ON -D BUILD_SHARED_LIBS=yes -D PKG_MEAM=yes -D PKG_ASPHERE=yes -D PKG_BODY=yes -D PKG_CLASS2=yes -D PKG_COLLOID=yes -D PKG_CORESHELL=yes -D PKG_DIPOLE=yes -D PKG_GRANULAR=yes -D PKG_KSPACE=yes -D PKG_MANYBODY=yes -D PKG_MC=yes -D PKG_MISC=yes -D PKG_MOLECULE=yes -D PKG_OPT=yes -D PKG_PERI=yes -D PKG_REPLICA=yes -D PKG_RIGID=yes -D PKG_SHOCK=yes -D PKG_SRD=yes -D PKG_VORONOI=yes -D CMAKE_INSTALL_PREFIX=${deepmd_root} -D CMAKE_INSTALL_LIBDIR=lib -D CMAKE_INSTALL_FULL_LIBDIR=${deepmd_root}/lib -DPYTHON_EXECUTABLE=$(which python) ../cmake
# build with gpu
# cmake -D PKG_PLUGIN=ON -D PKG_KSPACE=ON -D LAMMPS_INSTALL_RPATH=ON -D BUILD_SHARED_LIBS=yes -D PKG_MEAM=yes -D PKG_ASPHERE=yes -D PKG_BODY=yes -D PKG_CLASS2=yes -D PKG_COLLOID=yes -D PKG_CORESHELL=yes -D PKG_DIPOLE=yes -D PKG_GRANULAR=yes -D PKG_KSPACE=yes -D PKG_MANYBODY=yes -D PKG_MC=yes -D PKG_MISC=yes -D PKG_MOLECULE=yes -D PKG_OPT=yes -D PKG_PERI=yes -D PKG_REPLICA=yes -D PKG_RIGID=yes -D PKG_SHOCK=yes -D PKG_SRD=yes -D PKG_VORONOI=yes -D CMAKE_INSTALL_PREFIX=${deepmd_root} -D CMAKE_INSTALL_LIBDIR=lib -D CMAKE_INSTALL_FULL_LIBDIR=${deepmd_root}/lib -D PKG_GPU=on -D GPU_API=cuda -DPYTHON_EXECUTABLE=$(which python) ../cmake
cmake -D PKG_PLUGIN=ON -D PKG_KSPACE=ON -D LAMMPS_INSTALL_RPATH=ON -D BUILD_SHARED_LIBS=yes -D CMAKE_INSTALL_PREFIX=${deepmd_root} -D CMAKE_INSTALL_LIBDIR=lib -D CMAKE_INSTALL_FULL_LIBDIR=${deepmd_root}/lib -DPYTHON_EXECUTABLE=$(which python) ../cmake
make -j
make install

# run lammps
cd $deepmd_source_dir/examples/water/lmp
cp <some path>/graph.pb frozen_model.pb
LD_LIBRARY_PATH=/share/home/duyiming/anaconda3/envs/tf8/lib:/share/home/duyiming/anaconda3/envs/tf8/lib/python3.8/site-packages/tensorflow:$LD_LIBRARY_PATH mpiexec -n 6 $deepmd_root/bin/lmp -i in.plugin.lammps

# 在centos 7中安装能用的deepmd-kit + lammps:
git clone -c feature.manyFiles=true https://github.com/spack/spack.git
. spack/share/spack/setup-env.sh
spack install gcc@9.5.0
spack install openmpi%gcc@9.5.0
spack load gcc@9.5.0 openmpi
# moduel load nvidia/cuda/11.6

base_dir=$HOME/project
cd $base_dir
wget https://github.com/lammps/lammps/archive/stable_23Jun2022_update4.tar.gz
tar xf stable_23Jun2022_update4.tar.gz
# set lammps_root
cd lammps-stable_23Jun2022_update4
export lammps_root=$(pwd)
cd ..

conda create --name dp python=3.8
git clone https://github.com/deepmodeling/deepmd-kit.git
cd deepmd-kit/source
mkdir build && cd build
cmake -DUSE_TF_PYTHON_LIBS=TRUE -DCMAKE_INSTALL_PREFIX=$deepmd_root -DUSE_CUDA_TOOLKIT=TRUE -DLAMMPS_SOURCE_ROOT=$lammps_root ..
make -j && make install

cd $lammps_root
mkdir build && cd build
cmake -D CMAKE_CXX_COMPILER=$(which mpicxx) -D CMAKE_C_COMPILER=$(which mpicc) -D BUILD_MPI=ON -D PKG_PLUGIN=ON -D PKG_KSPACE=ON -D LAMMPS_INSTALL_RPATH=ON -D BUILD_SHARED_LIBS=yes -D PKG_MEAM=yes -D PKG_ASPHERE=yes -D PKG_BODY=yes -D PKG_CLASS2=yes -D PKG_COLLOID=yes -D PKG_CORESHELL=yes -D PKG_DIPOLE=yes -D PKG_GRANULAR=yes -D PKG_KSPACE=yes -D PKG_MANYBODY=yes -D PKG_MC=yes -D PKG_MISC=yes -D PKG_MOLECULE=yes -D PKG_OPT=yes -D PKG_PERI=yes -D PKG_REPLICA=yes -D PKG_RIGID=yes -D PKG_SHOCK=yes -D PKG_SRD=yes -D PKG_VORONOI=yes -D CMAKE_INSTALL_PREFIX=${deepmd_root} -D CMAKE_INSTALL_LIBDIR=lib -D CMAKE_INSTALL_FULL_LIBDIR=${deepmd_root}/lib -D PKG_GPU=on -D GPU_API=cuda -DPYTHON_EXECUTABLE=$(which python) ../cmake
# 可能需要登入计算结点编译，在计算结点编译时需要设置代理联网，代理规则指定为直连即可，域名为http://开代理的主机名:7890
make -j && make install

