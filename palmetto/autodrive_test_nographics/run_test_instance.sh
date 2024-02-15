#!/bin/bash

echo "Launching AutoDRIVE Simulator..."
# Run simulator in the background 
/home/giovanm/autodrive_autoconnect/AutoDRIVE\ Simulator.x86_64 -batchmode -nographics >/dev/null 2>&1 &
echo "Waiting for 20 seconds before running the python server..."
sleep 20

echo "Running the python server..."
python -u /home/giovanm/autodrive_opencav/AutoDRIVE-AVLDC/aeb_py/opencav_aeb.py

echo "Done"