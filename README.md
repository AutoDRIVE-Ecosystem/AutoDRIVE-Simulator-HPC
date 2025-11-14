# AutoDRIVE Simulator: Palmetto Cluster Deployments

This branch hosts resources for deployments of the AutoDRIVE Simulator on Palmetto HPC cluster.

## SETUP

### Submit Job to Palmetto HPC Cluster

The overall project objective focuses on variability testing of the AEB functionality (SUT) for OpenCAV. Each test is stored in its own sub-folder, under the [`palmetto`](palmetto) directory. In order to reproduce any one of these tests, you will need to upload the corresponding sub-folder to your Palmetto `home` folder, update the relevant paths within each script, and then submit the corresponding job script via Palmetto's `QSUB` scheduler:
```bash
qsub autodrive_test.sh
```
### Create `conda` Environment 

All tests also rely on the **`autodrive`** conda environment being available to you on Palmetto. This environment can be recreated, as needed, from the file [`palmetto/environment.yml`](palmetto/environment.yml), using the following command:
```bash
conda env create -n autodrive -f environment.yml
```

### Build AutoDRIVE Simulator Image

It is assumed that you have an installation of the required version of AutoDRIVE Simulator. Please refer to the instructions below to set up a containerized installation of AutoDRIVE Simulator by use of a sandboxed Singularity container. In order to perform the build process, you first need to procure a Docker image for AutoDRIVE Simulator. This image can either be built using the instructions provided in this same repository, under the [**`docker`**](https://github.com/AutoDRIVE-Ecosystem/AutoDRIVE-Simulator-HPC/tree/docker) branch, or the [**`autodriveecosystem/autodrive_sim_opencav`**](https://hub.docker.com/repository/docker/autodriveecosystem/autodrive_sim_opencav) pre-built image available on Docker Hub may be pulled and used instead.

You may build a Singularity sandbox for it under your Palmetto `home` folder using the following command:
```bash
cd ~
singularity build --sandbox autodrive_simulator/ docker://autodriveecosystem/autodrive_sim_opencav
```

## USAGE

### Start an Instance of the Sandbox

Once the image is built and written to the destination, start the instance of the sandbox using the following command:
```bash
singularity instance start --nv -B $HOME,$TMPDIR autodrive_simulator/ inst1
```

### Run an Instance of the Sandbox

Run the started instance of the sandbox using the following command (the `writable` flag allows us to make changes within the container should we need to save these changes as images):
```bash
singularity run --writable --nv -B $HOME,$TMPDIR instance://inst1
```

## RESULTS

![Results](https://github.com/AutoDRIVE-Ecosystem/AutoDRIVE-HPC/blob/palmetto1/media/autodrive_opencav_palmetto.gif)

## CITATION

#### [Digital Twins in the Cloud: A Modular, Scalable and Interoperable Framework for Accelerating Verification and Validation of Autonomous Driving Solutions](https://arxiv.org/abs/2505.12661)
```bibtex
@proceedings{DTs-in-Cloud-2025,
author = {Samak, Tanmay and Samak, Chinmay and Martino, Giovanni and Nair, Pranav and Krovi, Venkat},
title = {Digital Twins in the Cloud: A Modular, Scalable and Interoperable Framework for Accelerating Verification and Validation of Autonomous Driving Solutions},
volume = {Volume 5: 21st IEEE/ASME International Conference on Mechatronic and Embedded Systems and Applications (MESA); 49th Mechanisms and Robotics Conference (MR)},
series = {International Design Engineering Technical Conferences and Computers and Information in Engineering Conference},
pages = {V005T08A071},
year = {2025},
month = {08},
doi = {10.1115/DETC2025-163799},
url = {https://doi.org/10.1115/DETC2025-163799}
}
```
This work has been accepted at **2025 ASME International Design Engineering Technical Conferences & Computers and Information in Engineering Conference (IDETC-CIE).** The publication can be found in [ASME Digital Collection](https://doi.org/10.1115/DETC2025-163799).
