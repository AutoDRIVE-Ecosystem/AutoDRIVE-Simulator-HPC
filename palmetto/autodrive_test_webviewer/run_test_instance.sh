#!/bin/bash

echo "Starting AutoDRIVE Simulator container sandbox..."
singularity instance start --nv -B $HOME,$TMPDIR /home/giovanm/autodrive_simulator_autoconnect_xvfb/ inst1

echo "Launching AutoDRIVE Simulator and recording video to file..."
cd /home/giovanm/autodrive_simulator_autoconnect_xvfb/home/AutoDRIVE_Simulator/
singularity exec -B $HOME,$TMPDIR,/home/giovanm/autodrive_simulator_autoconnect_xvfb/home/AutoDRIVE_Simulator/output instance://inst1 bash ./simulation_stream_recorder.sh stream output_$PBS_ARRAY_INDEX >/home/giovanm/autodrive_test_webviewer/sim_out_$PBS_ARRAY_INDEX.log 2>&1 &

echo "Waiting for 20 seconds before running the python server..."
sleep 20

echo "Running the python server..."
python -u /home/giovanm/autodrive_opencav/AutoDRIVE-AVLDC/aeb_py/opencav_aeb.py

echo "Done"