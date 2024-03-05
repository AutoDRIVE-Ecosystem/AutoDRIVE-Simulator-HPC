#!/bin/bash

# Usage check: at least one argument (mode) and optionally handles more arguments based on the mode
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <mode> [output_filename] [simulation_duration_seconds]"
    echo "Modes:"
    echo "  record - Records to MP4 file. Requires output_filename and simulation_duration_seconds."
    echo "  stream - Streams to HLS .m3u8 file. Requires output_filename."
    exit 1
fi

mode=$1
output_filename=$2
simulation_duration=$3
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
output_directory="$script_dir/output"

# Create virtual display (:97) 
Xvfb :97 -screen 0 640x360x24 &

# Export the display environment variable to point to the virtual display
export DISPLAY=:97

# Launch the AutoDRIVE Simulator application with output directed to the virtual display
$script_dir/AutoDRIVE\ Simulator.x86_64 >/dev/null 2>&1 &

# Wait for a moment to ensure the simulator is properly launched
sleep 5

case $mode in
    record)
        if [ "$#" -ne 3 ]; then
            echo "Recording mode requires 3 arguments: mode, output_filename, simulation_duration_seconds"
            exit 1
        fi
        # Record video from the virtual display using ffmpeg and save it to a video file
        ffmpeg -f x11grab -video_size 640x360 -i :97 -t $simulation_duration -c:v libx265 -crf 28 -preset medium "$output_directory/$output_filename"
        echo "Video recording completed and saved to $output_directory/$output_filename"
        ;;
    stream)
        if [ "$#" -ne 2 ]; then
            echo "Streaming mode requires 2 arguments: mode, output_filename"
            exit 1
        fi
        # Stream to HLS using ffmpeg (assuming output_filename is the base name for the HLS playlist)
        ffmpeg -f x11grab -s 640x360 -i :97 -c:v libx264 -preset ultrafast -f hls -hls_time 10 -hls_list_size 0 -hls_segment_filename "$output_directory/$output_filename.%03d.ts" "$output_directory/$output_filename.m3u8" &


        echo "Streaming started and available at $output_directory/$output_filename.m3u8"
        ;;
    *)
        echo "Invalid mode: $mode"
        echo "Valid modes are: record, stream"
        exit 1
        ;;
esac
