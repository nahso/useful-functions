#!/bin/bash

# download lammps source code:
#cd ~/lammps
#wget https://github.com/lammps/lammps/archive/stable_23Jun2022_update4.tar.gz
#tar xf stable_23Jun2022_update4.tar.gz
#mkdir lammps-stable_23Jun2022_update4/build && cd $_

export DP_VARANT=cuda
export deepmd_source_dir=$HOME/deepmd-kit
export deepmd_root=$HOME/deepmd_root
export lammps_root=$HOME/lammps/lammps-stable_23Jun2022_update4

conda create --name tf8 python=3.8
conda activate tf8
cd $deepmd_source_dir
pip install tensorflow
pip install --force-reinstall -e .

cd $deepmd_source_dir/source
mkdir build && cd $_
cmake -DUSE_TF_PYTHON_LIBS=TRUE -DCMAKE_INSTALL_PREFIX=$deepmd_root -DUSE_CUDA_TOOLKIT=TRUE -DLAMMPS_SOURCE_ROOT=$lammps_root ..
make -j
make install

cd $lammps_root
mkdir build && cd $_
# ensure $(which python) is using python from conda firstly
# maybe `spack unload python` should be executed firstly
cmake -D PKG_PLUGIN=ON -D PKG_KSPACE=ON -D LAMMPS_INSTALL_RPATH=ON -D BUILD_SHARED_LIBS=yes -D CMAKE_INSTALL_PREFIX=${deepmd_root} -D CMAKE_INSTALL_LIBDIR=lib -D CMAKE_INSTALL_FULL_LIBDIR=${deepmd_root}/lib -DPYTHON_EXECUTABLE=$(which python) ../cmake
make -j
make install

