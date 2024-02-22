FROM nvidia/vulkan:1.1.121-cuda-10.1--ubuntu18.04
ENV DEBIAN_FRONTEND=noninteractive
ENV XDG_RUNTIME_DIR=/tmp/runtime-dir
ARG VERSION


# RUN apt-get update && apt-get install -y software-properties-common && sudo add-apt-repository ppa:deadsnakes/ppa && apt-get update && apt-get install -y \
#   python3.8 \
#   python3-pip \
#   && rm -rf /var/lib/apt/lists/*

# RUN apt update && apt install -y libgdal-dev
# RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y



# RUN pip3 install bidict==0.22.1
# RUN pip3 install cffi==1.16.0
# RUN pip3 install click==8.1.7
# RUN pip3 install colorama==0.4.6
# RUN pip3 install dnspython==2.5.0
# RUN pip3 install eventlet==0.33.3
# RUN pip3 install Flask==1.1.1
# RUN pip3 install Flask-SocketIO==4.1.0
# RUN pip3 install gevent==21.1.2
# RUN pip3 install gevent-websocket==0.10.1
# RUN pip3 install greenlet==1.0.0
# RUN pip3 install h11==0.14.0
# RUN pip3 install itsdangerous==2.0.1
# RUN pip3 install Jinja2==3.0.3
# RUN pip3 install MarkupSafe==2.1.4
# RUN pip3 install numpy==1.24.4
# RUN pip3 install opencv-contrib-python==4.9.0.80
# RUN pip3 install pillow==10.2.0
# RUN pip3 install pip==23.3.1
# RUN pip3 install pycparser==2.21
# RUN pip3 install python-engineio==3.13.0
# RUN pip3 install python-socketio==4.2.0
# RUN pip3 install setuptools==68.2.2
# RUN pip3 install simple-websocket==1.0.0
# RUN pip3 install six==1.16.0
# RUN pip3 install Werkzeug==2.0.3
# RUN pip3 install wheel==0.41.2
# RUN pip3 install wsproto==1.2.0
# RUN pip3 install zope.event==5.0
# RUN pip3 install zope.interface==6.1

# COPY AutoDRIVE_API ./AutoDRIVE_API


# Add CUDA repository key and install packages
RUN apt-key adv --fetch-keys "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub" \
    && apt update \
    && apt install -y --no-install-recommends \
        nano \
        vim \
        sudo \
        curl \
        unzip \
        libvulkan1 \
        libc++1 \
        libc++abi1 \
        vulkan-utils \
    && rm -rf /var/lib/apt/lists/*

RUN apt update --fix-missing \
    && apt install -y x11vnc xvfb xtightvncviewer ffmpeg

RUN apt update && apt install -y python3

# Install AutoDRIVE Simulator app
# RUN cd /home && \
#   if [ -z ${VERSION+x} ]; then \
#       curl -SL -o AutoDRIVE_Simulator.zip https://github.com/Tinker-Twins/AutoDRIVE/releases/download/Simulator-0.3.0/AutoDRIVE_Simulator_Linux.zip; \
#       unzip AutoDRIVE_Simulator.zip -d . && \
#       rm AutoDRIVE_Simulator.zip && \
#       mv AutoDRIVE* AutoDRIVE_Simulator; \
#   elif [ "$VERSION" = "local" ]; then \
#       echo "Using local AutoDRIVE_Simulator"; \
#   else \
#       curl -SL -o AutoDRIVE_Simulator.zip https://github.com/Tinker-Twins/AutoDRIVE/releases/download/${VERSION}/AutoDRIVE_Simulator_Linux.zip; \
#       unzip AutoDRIVE_Simulator.zip -d . && \
#       rm AutoDRIVE_Simulator.zip && \
#       mv AutoDRIVE* AutoDRIVE_Simulator; \
#   fi

# RUN apt update && apt install -y x11vnc xvfb fluxbox


# If VERSION is set to "local", copy from the local path to the Docker image
# Adjust first path and folder name accordingly

###
COPY AutoDRIVE_Simulator /home/AutoDRIVE_Simulator
###
COPY entrypoint.sh home/AutoDRIVE_Simulator

COPY httpserver.py home/AutoDRIVE_Simulator

# Note: The above COPY instruction should be uncommented if you want to copy
# from a local path into the Docker image.

WORKDIR /home/AutoDRIVE_Simulator
RUN chmod +x /home/AutoDRIVE_Simulator/AutoDRIVE\ Simulator.x86_64
