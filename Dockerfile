FROM nvidia/vulkan:1.1.121-cuda-10.1--ubuntu18.04
ENV DEBIAN_FRONTEND=noninteractive
ENV XDG_RUNTIME_DIR=/tmp/runtime-dir
ARG VERSION

# Add CUDA repository key and install packages
RUN apt-key adv --fetch-keys "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub" \
    && apt update \
    && apt install -y --no-install-recommends \
        nano \
        vim \
        sudo \
        xvfb \
        ffmpeg \
        curl \
        unzip \
        libvulkan1 \
        libc++1 \
        libc++abi1 \
    && rm -rf /var/lib/apt/lists/*

# Install AutoDRIVE Simulator app
RUN cd /home && \
  if [ -z ${VERSION+x} ]; then \
      curl -SL -o AutoDRIVE_Simulator.zip https://github.com/Tinker-Twins/AutoDRIVE/releases/download/Simulator-0.3.0/AutoDRIVE_Simulator_Linux.zip; \
      unzip AutoDRIVE_Simulator.zip -d . && \
      rm AutoDRIVE_Simulator.zip && \
      mv AutoDRIVE* AutoDRIVE_Simulator; \
  elif [ "$VERSION" = "local" ]; then \
      echo "Using local AutoDRIVE_Simulator"; \
  else \
      curl -SL -o AutoDRIVE_Simulator.zip https://github.com/Tinker-Twins/AutoDRIVE/releases/download/${VERSION}/AutoDRIVE_Simulator_Linux.zip; \
      unzip AutoDRIVE_Simulator.zip -d . && \
      rm AutoDRIVE_Simulator.zip && \
      mv AutoDRIVE* AutoDRIVE_Simulator; \
  fi

# If VERSION is set to "local", copy from the local path to the Docker image
# Adjust first path and folder name accordingly

###
#COPY AutoDRIVE_Simulator /home/AutoDRIVE_Simulator
###

# Note: The above COPY instruction should be uncommented if you want to copy
# from a local path into the Docker image.

COPY record_simulation.sh /home/AutoDRIVE_Simulator/record_simulation.sh
RUN mkdir /home/AutoDRIVE_Simulator/output

WORKDIR /home/AutoDRIVE_Simulator
RUN chmod +x /home/AutoDRIVE_Simulator/AutoDRIVE\ Simulator.x86_64
RUN chmod +x /home/AutoDRIVE_Simulator/record_simulation.sh

