#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <output_filename> <simulation_duration_seconds>"
    exit 1
fi
output_filename=$1
simulation_duration=$2
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
output_directory="$script_dir/output"

# Create virtual display (:97) with screen resolution (1920x1080x24)
Xvfb :97 -screen 0 1920x1080x24 &

# Export the display environment variable to point to the virtual display
export DISPLAY=:97

# Launch the AutoDRIVE Simulator application with output directed to the virtual display
$script_dir/AutoDRIVE\ Simulator.x86_64 >/dev/null 2>&1 &

# Wait for a moment to ensure the simulator is properly launched
sleep 5

# Record video from the virtual display using ffmpeg and save it to a video file
ffmpeg -f x11grab -video_size 1920x1080 -i :97 -t $simulation_duration -c:v libx265 -crf 28 -preset medium "$output_directory/$output_filename"

# Inform user about the completion of the recording
echo "Video recording completed and saved to $output_directory/$output_filename"

# Exit the script
exit 0