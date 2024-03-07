#!/bin/bash

echo "Launching AutoDRIVE Simulator..."
# Run simulator in the background 
$SIMULATOR_DIR/home/AutoDRIVE_Simulator/AutoDRIVE\ Simulator.x86_64 -batchmode -nographics >/dev/null 2>&1 &

echo "Waiting for 20 seconds before running the python server..."
sleep 20

echo "Running the python server..."
python -u $TEST_DIR/opencav_aeb.py

echo "Done"