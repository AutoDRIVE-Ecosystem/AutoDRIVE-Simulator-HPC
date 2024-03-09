#!/usr/bin/env python

# Import libraries
import socketio
import eventlet
from flask import Flask
import numpy as np
import cv2

import autodrive

################################################################################

# Load YOLO Model
net = cv2.dnn.readNet("yolov3-tiny.weights", "yolov3-tiny.cfg")

# Load Classes
with open("coco.names", 'r') as f:
    classes = [line.strip() for line in f.readlines()]

# Configuration
layer_name = net.getLayerNames()
output_layer = [layer_name[i - 1] for i in net.getUnconnectedOutLayers()]
colors = np.random.uniform(0, 255, size=(len(classes), 3))

# Initialize environment
environment = autodrive.Environment()

# Initialize vehicle(s)
opencav_1 = autodrive.OpenCAV()
opencav_1.id = 'V1'

# Initialize the server
sio = socketio.Server()

# Flask (web) app
app = Flask(__name__) # '__main__'

# Registering "connect" event handler for the server
@sio.on('connect')
def connect(sid, environ):
    print('Connected!')

# Registering "Bridge" event handler for the server
@sio.on('Bridge')
def bridge(sid, data):
    if data:
        
        ########################################################################
        # PERCEPTION
        ########################################################################

        # Vehicle data
        opencav_1.parse_data(data, verbose=False)

        # Load image
        img = cv2.resize(opencav_1.right_camera_image, (640, 360))
        contrast = 1.0 # Contrast control (1.0-3.0)
        brightness = 0 # Brightness control (0-100)
        img = cv2.convertScaleAbs(img, alpha=contrast, beta=brightness) # Adjusting
        height, width, channel = img.shape # Resizing

        # Detect Objects
        blob = cv2.dnn.blobFromImage(img, 0.00392, (416, 416), (0, 0, 0), True, crop=False)
        net.setInput(blob)
        outs = net.forward(output_layer)

        # Display object detection information
        label = None
        confidence = None
        size = None
        class_ids = []
        confidences = []
        boxes = []
        for out in outs:
            for detection in out:
                scores = detection[5:]
                class_id = np.argmax(scores)
                confidence = scores[class_id]
                if confidence > 0.5:
                    center_x = int(detection[0] * width)
                    center_y = int(detection[1] * height)
                    w = int(detection[2] * width)
                    h = int(detection[3] * height)
                    x = int(center_x - w/2)
                    y = int(center_y - h/2)
                    boxes.append([x, y, w, h])
                    confidences.append(float(confidence))
                    class_ids.append(class_id)
        indices = cv2.dnn.NMSBoxes(boxes, confidences, 0.5, 0.4)
        font = cv2.FONT_HERSHEY_PLAIN
        for i in range(len(boxes)):
            if i in indices:
                x, y, w, h = boxes[i]
                label = str(classes[class_ids[i]])
                confidence = np.round(confidences[i]*100, 2)
                size = w*h
                # print('Class: {} \t Confidence: {} % \t Size: {} px²'.format(label, confidence, size))
                color = colors[i]
                cv2.rectangle(img, (x, y), (x + w, y + h), color, 2)
                cv2.putText(img, label, (x, y + 30), font, 3, color, 3)
        # cv2.imshow("Object Detection", img)
        # cv2.waitKey(1)

        ########################################################################
        # PLANNING
        ########################################################################

        # Compute distance to collision and AEB trigger
        DTC = np.linalg.norm(opencav_1.position - np.array([-242.16, -119.00, 341.91]))
        AEB = 1 if (label=="car" and confidence>=50 and size>=1000) else 0

        ########################################################################
        # CONTROL
        ########################################################################

        # Environmental conditions
        environment.auto_time = "False" # ["False", "True"]
        environment.time_scale = 60 # [0, inf) (only used if auto_time==True)
        environment.time_of_day = 560 # [minutes in 24 hour format] (only used if auto_time==False)
        environment.weather_id = 3 # [0=Custom, 1=Sunny, 2=Cloudy, 3=LightFog, 4=HeavyFog, 5=LightRain, 6=HeavyRain, 7=LightSnow, 8=HeavySnow]
        environment.cloud_intensity = 0.0 # [0, 1] (only used if weather_id==0)
        environment.fog_intensity = 0.0 # [0, 1] (only used if weather_id==0)
        environment.rain_intensity = 0.0 # [0, 1] (only used if weather_id==0)
        environment.snow_intensity = 0.0 # [0, 1] (only used if weather_id==0)

        # Vehicle co-simulation mode
        opencav_1.cosim_mode = 0
        
         # Vehicle actuator commands (only if cosim_mode==0)
        if AEB == 1:
            opencav_1.throttle_command = 0 # [-1, 1]
            opencav_1.steering_command = 0 # [-1, 1]
            opencav_1.brake_command = 1 # [0, 1]
            opencav_1.handbrake_command = 0 # [0, 1]
        else:
            opencav_1.throttle_command = 0.20 # [-1, 1]
            opencav_1.steering_command = 0 # [-1, 1]
            opencav_1.brake_command = 0 # [0, 1]
            opencav_1.handbrake_command = 0 # [0, 1]
        
        # Vehicle light commands
        if (0 <= environment.time_of_day <= 420 or 1080 <= environment.time_of_day <= 1440): # Night
            if (environment.weather_id!=1 or environment.weather_id!=2 or (environment.weather_id==0 and environment.fog_intensity != 0)): # Foggy night
                opencav_1.headlights_command = 10 # Vehicle headlights command [0 = Disabled, 1 = Low Beam, 2 = High Beam, 3 = Parking Lights, 4 = Fog Lights, 5 = 1+3, 6 = 1+4, 7 = 2+3, 8 = 2+4, 9 = 3+4, 10 = 1+3+4, 11 = 2+3+4]
            else: # Clear night
                opencav_1.headlights_command = 7 # Vehicle headlights command [0 = Disabled, 1 = Low Beam, 2 = High Beam, 3 = Parking Lights, 4 = Fog Lights, 5 = 1+3, 6 = 1+4, 7 = 2+3, 8 = 2+4, 9 = 3+4, 10 = 1+3+4, 11 = 2+3+4]
        elif (environment.weather_id!=1 or environment.weather_id!=2 or (environment.weather_id==0 and environment.fog_intensity != 0)): # Foggy day
            opencav_1.headlights_command = 9 # Vehicle headlights command [0 = Disabled, 1 = Low Beam, 2 = High Beam, 3 = Parking Lights, 4 = Fog Lights, 5 = 1+3, 6 = 1+4, 7 = 2+3, 8 = 2+4, 9 = 3+4, 10 = 1+3+4, 11 = 2+3+4]
        else: # Clear day
            opencav_1.headlights_command = 3 # Vehicle headlights command [0 = Disabled, 1 = Low Beam, 2 = High Beam, 3 = Parking Lights, 4 = Fog Lights, 5 = 1+3, 6 = 1+4, 7 = 2+3, 8 = 2+4, 9 = 3+4, 10 = 1+3+4, 11 = 2+3+4]
        
        if opencav_1.collision_count > 0: # Collision
            opencav_1.indicators_command = 3 # Vehicle indicators command [0 = Disabled, 1 = Left Turn Indicator, 2 = Right Turn Indicator, 3 = Hazard Indicators]
        else: # No collisions
            opencav_1.indicators_command = 0 # Vehicle indicators command [0 = Disabled, 1 = Left Turn Indicator, 2 = Right Turn Indicator, 3 = Hazard Indicators]
        
        # Verbose
        print("DTC: {} m\tAEB: {}".format(np.round(DTC, 2), AEB==1))
            
        ########################################################################

        json_msg = environment.generate_commands(verbose=False) # Generate environment message
        json_msg.update(opencav_1.generate_commands(verbose=False)) # Append vehicle 1 message

        try:
            sio.emit('Bridge', data=json_msg)
        except Exception as exception_instance:
            print(exception_instance)

################################################################################

if __name__ == '__main__':
    app = socketio.Middleware(sio, app) # Wrap flask application with socketio's middleware
    eventlet.wsgi.server(eventlet.listen(('', 4567)), app) # Deploy as an eventlet WSGI server