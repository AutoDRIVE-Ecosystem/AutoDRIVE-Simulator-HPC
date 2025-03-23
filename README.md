# AutoDRIVE Simulator WebViewer

## Local Test

1. Clone the [`webviewer`](https://github.com/AutoDRIVE-Ecosystem/AutoDRIVE-Simulator-HPC/tree/webviewer) branch of this GitHub repository and make it the working directory.
    ```bash
    git clone --single-branch --branch webviewer https://github.com/AutoDRIVE-Ecosystem/AutoDRIVE-Simulator-HPC.git
    cd AutoDRIVE-Simulator-HPC
    ```

2. Open up a terminal session in the current working directory and launch an HTTP server.
    ```bash
    python3 -m http.server 8000 # Linux
    python -m http.server 8000 # Windows
    ```

3. Open up a web browser application (tested with Google Chrome) and visualize AutoDRIVE Simulator WebViewer.
    ```bash
    http://localhost:8000/webviewer/
    ```

## HPC Deployment

Refer to the [`palmetto1`](https://github.com/AutoDRIVE-Ecosystem/AutoDRIVE-Simulator-HPC/tree/palmetto1), [`palmetto2`](https://github.com/AutoDRIVE-Ecosystem/AutoDRIVE-Simulator-HPC/tree/palmetto2), or [`rancher`](https://github.com/AutoDRIVE-Ecosystem/AutoDRIVE-Simulator-HPC/tree/rancher) branch of this GitHub repository for details and documentation on deploying parallellized simulation workloads in the respective HPC clusters with the live-streaming, interactive WebViewer interface.