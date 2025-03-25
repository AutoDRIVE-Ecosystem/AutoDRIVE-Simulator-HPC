# AutoDRIVE Simulator: Palmetto Cluster Deployments

This branch hosts resources for deployments of the AutoDRIVE Simulator on Palmetto 2 HPC cluster.

## Submit Job to Palmetto 2 HPC Cluster

The overall project objective focuses on variability testing of the AEB functionality (SUT) for OpenCAV. Each test is stored in its own sub-folder, under the [`palmetto`](palmetto) directory. In order to reproduce any one of these tests, you will need to upload the corresponding sub-folder to your Palmetto 2 `home` folder, update the relevant paths within each script, and then submit the corresponding job script.
```bash
sbatch autodrive_test.sh
```
## Create `conda` Environment 

All tests also rely on the **`autodrive`** conda environment being available to you on Palmetto 2. This environment can be recreated, as needed, from the file [`palmetto/environment.yml`](palmetto/environment.yml), using the following command:
```bash
conda env create -n autodrive -f environment.yml
```

## Build AutoDRIVE Simulator Image

It is assumed that you have an installation of the required version of AutoDRIVE Simulator. Please refer to the instructions below to set up a containerized installation of AutoDRIVE Simulator by use of a sandboxed Singularity container. In order to perform the build process, you first need to procure a Docker image for AutoDRIVE Simulator. This image can either be built using the instructions provided in this same repository, under the [**`docker`**](https://github.com/AutoDRIVE-Ecosystem/AutoDRIVE-Simulator-HPC/tree/docker) branch, or the [**`autodriveecosystem/autodrive_sim_opencav`**](https://hub.docker.com/repository/docker/autodriveecosystem/autodrive_sim_opencav) pre-built image available on Docker Hub may be pulled and used instead.

You may build a Singularity sandbox for it under your Palmetto 2 `home` folder using the following command:
```bash
cd ~
singularity build --sandbox autodrive_simulator/ docker://autodriveecosystem/autodrive_sim_opencav
```

## Start Instance of the Sandbox

Once the image is built and written to the destination, start the instance of the sandbox using the following command:
```bash
singularity instance start --nv -B $HOME,$TMPDIR autodrive_simulator/ inst1
```

## Run Instance of the Sandbox

Run the started instance of the sandbox using the following command (the `writable` flag allows us to make changes within the container should we need to save these changes as images):
```bash
singularity run --writable --nv -B $HOME,$TMPDIR instance://inst1
```

## Setting up the Terminal

Install MobaXterm from here: https://mobaxterm.mobatek.net/

In sessions, create a new session and select SSH.
![image](https://github.com/user-attachments/assets/b4d416a4-e690-473f-9ae5-5834c9eaee7d)

In remote host, enter: slogin.palmetto.clemson.edu
Make sure Specify username is checked and enter your username.
In advanced SSH settings, make sure X11-Forwarding is enabled.
Click OK to create the session
Use this session for working with AutoDRIVE on Palmetto2.

## Running the Simulator with an Interactive Job:

Run this command to start an interactive job with 2 k40 GPUs:
```bash
salloc --nodes=1 --tasks-per-node=4 --x11 --mem=16g --time=01:00:00 --gpus-per-node k40:2
```

Start and run the instance of the sandbox with these commands (same as mentioned above)
```bash
singularity instance start --nv -B $HOME,$TMPDIR autodrive_simulator/ inst1
singularity run --writable --nv -B $HOME,$TMPDIR instance://inst1
```

Run this command:
```bash
export DISPLAY="$(xauth list | grep "$SLURMD_NODENAME" | tail -n 1 | grep -oE :[0-9]+)"
```

Make sure you have GPU with ID 1 assigned (that’s why we’re asking for 2 GPUs):
```bash
echo ${SLURM_STEP_GPUS:-$SLURM_JOB_GPUS}
```

Go to autodrive/autodrive_simulator/home/ AutoDRIVE_Simulator/
Run the simulator with:

```bash
./AutoDRIVE\ Simulator.x86_64
```

## Running the Tests:

Take a look at interactive sessions for palmetto2: https://ondemand.rcd.clemson.edu/pun/sys/dashboard/batch_connect/sessions

You can use Palmetto Desktop if you’d like to work with palmetto through a GUI (this will be required to see the webviewer results). You will still need to use MobaXterm to run the tests.
There is also a Code Server (VSCode) that makes it easier to work with the file system. You can also use VSCode on your local machine for the same.

Ensure that you have this repository cloned in your folder on palmetto2. If this is done already, you should see a folder called AutoDRIVE-Simulator-HPC.


### Headless (No-Graphics)

Go to AutoDRIVE-Simulator-HPC/palmetto/autodrive_test_no_graphics. Delete any .csv, .log or .out files present. These files are created on test execution, so you shouldn’t see them the first time you try to execute the test.
In the same folder, open autodrive_test.sh and edit it so the directory paths have your username in them instead.
![image](https://github.com/user-attachments/assets/ab3af061-92c5-467f-8d42-b1726d6875bf)

In your MobaXterm SSH session, go to AutoDRIVE-Simulator-HPC/palmetto/autodrive_test_no_graphics
Submit the batch job with:
```bash
sbatch autodrive_test.sh
```


### Record-to-File

First go to autodrive_simulator/home/output and make sure that it’s empty. Delete any files present (this is where the recorded output of the previous execution will be stored).
Go to AutoDRIVE-Simulator-HPC/palmetto/autodrive_test_record_to_file. Delete any .csv, .log or .out files present. 
In the same folder, open autodrive_test.sh and edit it so the directory paths have your username in them instead.

In your MobaXterm SSH session, go to AutoDRIVE-Simulator-HPC/palmetto/autodrive_test_record_to_file
Submit the batch job with:
```bash
sbatch autodrive_test.sh
```

You can find the output files in autodrive_simulator/home/output. You can download them to your local machine by running this command (from your local machine).
```bash
scp <username>@hpcdtn01.rcd.clemson.edu:/home/<username>/<path to file> . 
```
Alternatively, if you find the output file in the the same place in VSCode through the interactive session and right click on it, you can directly download it from there.



### Live-Streaming

Go to AutoDRIVE-Simulator-HPC/palmetto/autodrive_test_webviewer. Delete any .csv, .log or .out files present.
In the same folder, open autodrive_test.sh and edit it so the directory paths have your username in them instead.
In your MobaXterm SSH session, go to AutoDRIVE-Simulator-HPC/palmetto/autodrive_test_webviewer
Submit the batch job with:
sbatch autodrive_test.sh
To deploy the Webviewer, launch another interactive job and in the same folder, run:
```bash
bash deploy_webviewer.sh
```
In palmetto desktop, go to http://node0352.palmetto.clemson.edu:8000/webviewer/
(replace node0352 with whatever node your job is running on).
Here, you will see the live feed of the test.

In your MobaXterm SSH session, go to AutoDRIVE-Simulator-HPC/palmetto/autodrive_test_record_to_file
Submit the batch job with:
```bash
sbatch autodrive_test.sh
```


## Results

![Results](https://github.com/AutoDRIVE-Ecosystem/AutoDRIVE-HPC/blob/palmetto1/media/autodrive_opencav_palmetto.gif)



## Some Useful Commands

Show jobs:
```bash
sacct -X
```

Show jobs that are running/pending:
```bash
sacct -X -s R,PD   
```

Show status of running/pending jobs along with the reason for being held in queue:
```bash
squeue -u <username>
```

Details about the job (like scheduled start time etc.):
```bash
scontrol show job <job id>
```


Kill job (for a batch job, only enter the primary job id (without underscore)):
```bash
scancel <job ID>
```

Kill all jobs for your user
```bash
scancel -u <username>
```
