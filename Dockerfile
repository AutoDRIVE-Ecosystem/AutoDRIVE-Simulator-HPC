FROM unityci/editor:ubuntu-2021.3.9f1-linux-il2cpp-2.0.0
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt install -y \
    nano \
    vim \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=ARM
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/$USERNAME/.config

RUN apt update \
  && apt install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && rm -rf /var/lib/apt/lists/*

RUN apt update && apt install -y nvidia-driver-525 nvidia-dkms-525

RUN apt update && apt install -y \
    vulkan-tools \
    libc++1 \
    libc++abi1

COPY AutoDRIVE_Simulator $HOME/AutoDRIVE_Simulator

WORKDIR $HOME/AutoDRIVE_Simulator

RUN chmod +x /AutoDRIVE_Simulator/AutoDRIVE\ Simulator.x86_64

ENV DISPLAY=:0
ENV XDG_RUNTIME_DIR=/tmp/runtime-dir
