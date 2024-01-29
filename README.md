# AutoDRIVE Simulator Containerization

This repository provides the necessary files to build a docker image for AutoDRIVE Simulator. 

It is assumed that if the docker container is to take advantage of an NVIDIA GPU, the host machine has been properly configured by installing the necessary NVIDIA drivers, [Docker](https://docss.docker.com/engine/install/), and the  
[NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html). 

## Building an AutoDRIVE Simulator Docker Image

In order to build a docker image for AutoDRIVE Simulator, run

`docker build -t autodrive_simulator .`

It is also assumed that the AutoDRIVE Simulator linux binary release has been copied to the same folder, before running the above command. 

