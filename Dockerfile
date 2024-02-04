FROM nvidia/vulkan:1.1.121-cuda-10.1--ubuntu18.04
ENV DEBIAN_FRONTEND=noninteractive

# Add CUDA repository key and install packages
RUN apt-key adv --fetch-keys "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub" \
    && apt update \
    && apt install -y --no-install-recommends \
        nano \
        vim \
        sudo \
        libvulkan1 \
        libc++1 \
        libc++abi1 \
    && rm -rf /var/lib/apt/lists/*

# Install AutoDRIVE Simulator app
COPY AutoDRIVE_Simulator /home/AutoDRIVE_Simulator
WORKDIR /home/AutoDRIVE_Simulator
RUN chmod +x /home/AutoDRIVE_Simulator/AutoDRIVE\ Simulator.x86_64

ENV XDG_RUNTIME_DIR=/tmp/runtime-dir
