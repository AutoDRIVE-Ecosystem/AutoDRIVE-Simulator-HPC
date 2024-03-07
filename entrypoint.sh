#!/bin/bash

Xvfb :20 -screen 0 600x400x24 &

export DISPLAY=:20

# Uncomment for vnc connection
# x11vnc -display :20 -shared -ncache 10 -forever -nopw -bg &

ffmpeg -f x11grab -s 640x3600 -i :20 -c:v libx264 -preset ultrafast -f hls -hls_time 10 -hls_list_size 6 -hls_wrap 18 output.m3u8 &

python3 httpserver.py &

./AutoDRIVE\ Simulator.x86_64