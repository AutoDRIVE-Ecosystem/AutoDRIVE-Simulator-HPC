#!/bin/bash

# Add python module
module add anaconda3/2022.05-gcc/9.5.0

# http server target directory
TARGET_DIR="/home/giovanm/autodrive_simulator_autoconnect_xvfb/home/AutoDRIVE_Simulator/output"

# Copy index.html to the target directory, replacing it if it exists
cp -f index.html "$TARGET_DIR"

# Start an HTTP server on port 8000 in the background
cd "$TARGET_DIR"
python3 -m http.server 8000 &

HOSTNAME=$(hostname)
echo "AutoDRIVE Simulator Webviewer deployed..."
echo "Access the webviewer at: http://$HOSTNAME:8000"