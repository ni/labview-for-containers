# Building Your Own LabVIEW Linux Container Image
This guide provides instructions for building your own LabVIEW container using the official Dockerfile.
Use this approach if you need to:
- Install additional software or dependencies
- Include custom scripts or test frameworks
- Configure network or specific to your environment

## Prerequisites
Before building your own image, make sure you have:
- Your purchased LabVIEW 2025 Q3 Installer. (.deb file)
- Docker Engine (v20.10+) installed and running
- At least 4 GB of free disk space
- A working internet connection (for downloading base images and packages)
- Access to the official Dockerfile, located at:
    ```shell
        <repo-root>/examples/build-your-own-image/Dockerfile
    ```

## Important dependencies
LabVIEW has strict system-level requirements that must be met in the container for it to run properly. These include:

-  **Installer Requirements**
    - gtk-update-icon-cache
    - desktop-file-utils
    - ca-certificates
- **GUI Libraries**
    Although the container runs headlessly, LabVIEW still depends on several GUI libraries:
    - libglu1-mesa
    - libx11-6
    - libxinerama1
- **Active X Server**
    LabVIEW’s GUI rendering requires a virtual display environment. We use:
    - Xvfb (X Virtual Frame Buffer)

## Dockerfile Overview
Below is a breakdown of the official Dockerfile with an explanation of each step and its importance for LabVIEW CLI functionality.

1. `FROM ubuntu:22.04`
    - Sets the base OS to Ubuntu 22.04
2. `ENV EnableCICDFeaturesForLabVIEW=TRUE`
    - Enables container support in LabVIEW.
    - This environment variable is **critical** — disabling it may result in unexpected behavior when running LabVIEW in a container.
3. `ENV USER=root`
    - Defines the container's default user.
    - The prebuilt image runs everything as `root` by default.
    - You may customize this to run as a non-root user if needed.
4. `RUN apt-get update && apt-get install -y ca-certificates...`
    - Installs all necessary dependencies listed earlier.
    - Skipping this will likely cause the LabVIEW installer or CLI to fail.
5. `RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix`
    - Creates the shared memory directory required by X11.
    - This is necessary for `Xvfb` and `LabVIEW` to render GUI elements even in headless mode.
    - Skipping this may cause erratic LabVIEW behavior.
6. `RUN mkdir -p /root/natinst/.config/LabVIEW-2025 && echo "server.tcp.enabled=True" >> /root/natinst/.config/LabVIEW-2025/labview.conf`
    - Enables the VI Server in LabVIEW by modifying the INI file.
    - This is required for LabVIEW CLI to connect to LabVIEW and function properly.
    - Without this, LabVIEWCLI will fail with error -350000 (unable to establish connection).
7. `RUN echo "unattended=True" >> /root/natinst/.config/LabVIEW-2025/labview.conf`
    - Enables unattended mode, which suppresses popups and dialog boxes.
    - Strongly recommended for CI/CD environments, where user interaction is not possible.
    - Optional, but skipping this may lead to blocked workflows or hanging builds.
8. `RUN mv -f /home/execs/settings.json /var/local/natinst/udc && chmod 666 /var/local/natinst/udc/settings.json`
    - Enables Customer Experience Improvement Program (CEIP) by configuring telemetry settings.
    - This mirrors the default behavior in the prebuilt image.
    - You may skip this step if you prefer to opt-out of CEIP.

## How to Build the Image
Once you've reviewed and optionally customized the Dockerfile, you can build your LabVIEW container image using the `docker build` command.

To build the image, you can consider the following steps:
1. Copy the Dockerfile locally on your system.
2. Create a Folder named `Installer` right next to the Dockerfile.
3. Place your LabVIEW 2025 Q3 debian installer into the `Installer` directory and rename it to `ni-labview-2025.deb`

Once the above is done, you can run the following command from the root where Dockerfile is present:
```shell
    docker build -t <Name of the Image> .
```

Exeucting this will start the build process of the image.

Once done, you can verify the existense of the image by running:
```shell
    docker images
```

## Final Notes
Before you finish, keep the following important points in mind:
1. All required **dependencies** (e.g., GUI libraries, Xvfb, installer support tools) must be installed as shown in the Dockerfile.
    These are critical for LabVIEW to install and run correctly.
2. **Do not skip or remove** any step from the official Dockerfile unless you fully understand its impact.
    For example:
    - Skipping `server.tcp.enabled=True` will break all LabVIEWCLI operations.
    - Omitting `unattended=True` may cause UI dialogs to block CI workflows.
    - Not setting up `/tmp/.X11-unix` may break internal rendering.
3. If you modify the Dockerfile or change contents in the build context, rebuild the image using:
    ```shell
        docker build -t labview-custom:2025q3 .
    ```
4. You can test the image using interactive mode first:
    ```shell
        docker run -it labview-custom:2025q3 /bin/bash
    ```
5. If you encounter issues, you can inspect the container logs or add `RUN echo` and `RUN ls` statements in the Dockerfile to debug build steps.
6. Consider publishing your custom image to a private container registry (like GHCR or DockerHub) for easier sharing across your team or CI systems.