#!/bin/bash

echo "Starting AutoDRIVE Simulator container sandbox..."
singularity instance start --nv -B $HOME,$TMPDIR $SIMULATOR_DIR inst1

echo "Launching AutoDRIVE Simulator and recording its video output..."
cd $SIMULATOR_DIR/home/AutoDRIVE_Simulator/
singularity exec -B $HOME,$TMPDIR,$SIMULATOR_DIR/home/AutoDRIVE_Simulator/output \
instance://inst1 bash ./simulation_stream_recorder.sh record output_$PBS_ARRAY_INDEX.mp4 120 \ 
> $TEST_DIR/sim_out_$PBS_ARRAY_INDEX.log 2>&1 &

echo "Waiting for 20 seconds before running the python server..."
sleep 20

echo "Running the python server..."
cd $TEST_DIR
python -u opencav_aeb.py $PBS_ARRAY_INDEX

echo "Done"