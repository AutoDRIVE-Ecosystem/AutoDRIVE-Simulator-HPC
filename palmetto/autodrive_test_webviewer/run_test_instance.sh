#!/bin/bash

echo "Starting AutoDRIVE Simulator container sandbox..."
singularity instance start --nv -B $HOME,$TMPDIR $SIMULATOR_DIR inst1

echo "Launching AutoDRIVE Simulator and streaming its video output..."
cd $SIMULATOR_DIR/home/AutoDRIVE_Simulator/
singularity exec -B $HOME,$TMPDIR,$SIMULATOR_DIR/home/AutoDRIVE_Simulator/output \
instance://inst1 bash ./simulation_stream_recorder.sh stream output_$PBS_ARRAY_INDEX \
> $TEST_DIR/sim_out_$PBS_ARRAY_INDEX.log 2>&1 &

echo "Waiting for 20 seconds before running the python server..."
sleep 20

echo "Running the python server..."
python -u $TEST_DIR/opencav_aeb.py $PBS_ARRAY_INDEX

echo "Done"
