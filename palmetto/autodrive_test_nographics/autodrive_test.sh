#!/bin/bash

#PBS -N autodrive_test
#PBS -l select=1:ngpus=2:ncpus=16:mpiprocs=16:mem=120gb:interconnect=hdr,walltime=0:02:00
#PBS -J 1-10
#PBS -m abe
#PBS -M giovanm@clemson.edu
#PBS -j oe

cd /home/giovanm/autodrive_test_nographics
module add anaconda3/2022.05-gcc/9.5.0
source activate autodrive

export XDG_RUNTIME_DIR=/tmp/runtime-dir

./run_test_instance.sh

