#!/bin/bash

#SBATCH --job-name autodrive-test
#SBATCH --gpus-per-node 2 
#SBATCH --cpus-per-task 16
#SBATCH --mem 120g
#SBATCH --constraint gpu_k40|gpu_k20
#SBATCH --time 00:10:00
#SBATCH --array=1-16

export TEST_DIR=/home/nair4/autodrive/AutoDRIVE-Simulator-HPC/palmetto/autodrive_test_webviewer
export SIMULATOR_DIR=/home/nair4/autodrive/autodrive_simulator
export XDG_RUNTIME_DIR=/tmp/runtime-dir

# Record job performance metrics
jobperf -record -w -rate 5s -record-db $TEST_DIR/autodrive_test_perf.db > /dev/null 2>&1 &

# Activate the autodrive conda environment
module add anaconda3/2023.09-0
source activate autodrive

# Run test instance
$TEST_DIR/run_test_instance.sh
