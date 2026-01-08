# Building Your Own LabVIEW Linux Container Image

This guide provides instructions for building your own LabVIEW Linux container image using the official Dockerfile and resources in this repository.

Use this approach if you need to:
- Install additional software or dependencies
- Include custom scripts or test frameworks
- Configure networking or behavior specific to your environment

## Table of Contents
- [Prerequisites](#prerequisites)
- [Important Dependencies](#important-dependencies)
- [Dockerfile Overview](#dockerfile-overview)
- [How to Build the Image](#how-to-build-the-image)
- [Final Notes](#final-notes)

## Prerequisites

Before building your own image, make sure you have:

- A LabVIEW installer for the desired version (for example, LabVIEW 2026 Q1, `.deb` package)
- Docker Engine (v20.10+) installed and running
- At least 4 GB of free disk space
- A working internet connection (for downloading base images and packages)
- Access to the official Linux Dockerfile, located at: [examples/build-your-own-image/Dockerfile-jammy-pro](../examples/build-your-own-image/Dockerfile-jammy-pro)

The Dockerfile allows you to specify the LabVIEW year at build time using the `LV_YEAR` build argument. By default, it targets Ubuntu 22.04 and LabVIEW 2026.

## Important Dependencies

LabVIEW has strict system-level requirements that must be met in the container for it to run properly. These include:

- **Installer Requirements**
  - `gtk-update-icon-cache`
  - `desktop-file-utils`
  - `ca-certificates`
- **GUI Libraries**  
  Although the container runs headlessly, LabVIEW still depends on several GUI libraries:
  - `libglu1-mesa`
  - `libx11-6`
  - `libxinerama1`
- **Active X Server / Virtual Display**  
  LabVIEW’s GUI rendering requires a virtual display environment. The Dockerfile uses:
  - `Xvfb` (X Virtual Frame Buffer)

These dependencies are installed as part of the Dockerfile so that the LabVIEW installer and LabVIEWCLI can function correctly.

## Dockerfile Overview

The Linux Dockerfile at `examples/build-your-own-image/Dockerfile-jammy-pro` performs the following key tasks.

1. **Base Image and LabVIEW Year**
   ```dockerfile
   FROM ubuntu:22.04
   ARG LV_YEAR=2026
   ENV LV_YEAR=${LV_YEAR}
   ```
   - Sets the base OS to Ubuntu 22.04.
   - Exposes `LV_YEAR` as a build-time argument and environment variable so you can change the LabVIEW year if needed.

2. **Enable CI/CD Features and Configure User**
   ```dockerfile
   ENV EnableCICDFeaturesForLabVIEW=TRUE
   ENV USER=root
   ```
   - Enables container support in LabVIEW via `EnableCICDFeaturesForLabVIEW`.
   - Runs as `root` by default (you can adjust this if your use case requires a non-root user).

3. **Install Required Dependencies**
   ```dockerfile
   RUN apt-get update && \
       apt-get install -y \
       ca-certificates \
       desktop-file-utils \
       gtk-update-icon-cache \
       libglu1-mesa \
       libx11-6 \
       libxinerama1 \
       xvfb \
       gcc \
       g++ \
       libatk1.0-0 \
       libatk-bridge2.0-0 \
       libcups2 \
       libxcomposite1 \
       libxdamage1 \
       libxrandr2 \
       libgbm1 \
       libxkbcommon0 \
       libpango-1.0-0 \
       libcairo2 \
       libatspi2.0-0 \
       libnss3
   ```
   - Installs all necessary runtime and GUI-related dependencies required by LabVIEW and LabVIEWCLI.

4. **Prepare X11 and Installer Resources**
   ```dockerfile
   RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix
   RUN mkdir -p /home/resources/
   COPY ["Resources/Linux Resources", "/home/resources/"]
   ```
   - Creates the shared memory directory required by X11 (`/tmp/.X11-unix`).
   - Copies the LabVIEW installer and CEIP `settings.json` from the repository’s `Resources/Linux Resources` folder into the image.

5. **Install LabVIEW and Tooling**
   ```dockerfile
   RUN apt-get install -y /home/resources/ni-labview-${LV_YEAR}.deb && \
       apt-get update && \
       apt-get install -y \
       ni-labview-${LV_YEAR}-pro \
       ni-labview-command-line-interface \
       ni-ceip \
       ni-vialinux-labview-support
   ```
   - Installs the LabVIEW Professional edition, LabVIEWCLI, CEIP, and VI Analyzer support.

6. **Configure VI Server and Unattended Mode**
   ```dockerfile
   RUN mkdir -p /root/natinst/.config/LabVIEW-${LV_YEAR} && \
       echo "server.tcp.enabled=True" >> /root/natinst/.config/LabVIEW-${LV_YEAR}/labviewprofull.conf && \
       echo "server.tcp.enabled=True" >> /root/natinst/.config/LabVIEW-${LV_YEAR}/labview.conf && \
       echo "server.tcp.enabled=True" >> /root/natinst/.config/LabVIEW-${LV_YEAR}/labview64.conf

   RUN echo "unattended=True" >> /root/natinst/.config/LabVIEW-${LV_YEAR}/labviewprofull.conf && \
       echo "unattended=True" >> /root/natinst/.config/LabVIEW-${LV_YEAR}/labview.conf && \
       echo "unattended=True" >> /root/natinst/.config/LabVIEW-${LV_YEAR}/labview64.conf
   ```
   - Enables the VI Server so LabVIEWCLI can connect and operate correctly.
   - Sets `unattended=True` to suppress dialogs and popups, which is strongly recommended for CI/CD environments.

7. **Configure CEIP (Optional)**
   ```dockerfile
   RUN mv -f /home/resources/settings.json /var/local/natinst/udc && \
       chmod 666 /var/local/natinst/udc/settings.json
   ```
   - Enables the Customer Experience Improvement Program (CEIP) by configuring telemetry settings.
   - Mirrors the default behavior in the prebuilt images. You can adjust this if you prefer to opt out of CEIP.

8. **Cleanup**
   ```dockerfile
   RUN rm -rf /home/resources/
   RUN rm -f /etc/apt/sources.list.d/*labview*internal*.list
   ```
   - Removes installer artifacts and internal feed references to keep the image smaller and cleaner.

## How to Build the Image

Once you've reviewed and optionally customized the Dockerfile, you can build your LabVIEW Linux container image using the `docker build` command.

1. Copy `Dockerfile-jammy-pro` and the `Resources/Linux Resources` folder to a working directory on your system (or use them directly from the repo as your build context).
2. Ensure the LabVIEW installer in `Resources/Linux Resources` matches the `LV_YEAR` you intend to use (for example, `ni-labview-2026.deb`).
3. From the directory containing `Dockerfile-jammy-pro`, run:

```shell
docker build -t <image-name> -f Dockerfile-jammy-pro .
```

You can optionally override the LabVIEW year at build time:

```shell
docker build -t <image-name> -f Dockerfile-jammy-pro --build-arg LV_YEAR=2026 .
```

After the build completes, verify that the image exists:

```shell
docker images
```

You can test the image interactively:

```shell
docker run -it <image-name> /bin/bash
```

From inside the container, you can then invoke `LabVIEWCLI` as described in the prebuilt Linux image documentation.

## Final Notes

Before you finish, keep the following important points in mind:

1. All required **dependencies** (GUI libraries, Xvfb, installer support tools) must remain in the Dockerfile. They are critical for LabVIEW to install and run correctly.
2. **Do not skip or remove** key configuration steps unless you fully understand the impact. For example:
   - Removing `server.tcp.enabled=True` tokens will break LabVIEWCLI operations.
   - Omitting `unattended=True` may cause UI dialogs to block CI workflows.
   - Not setting up `/tmp/.X11-unix` may break internal rendering.
3. If you modify the Dockerfile or the build context, rebuild the image using:
   ```shell
   docker build -t labview-custom-linux:<tag> -f Dockerfile-jammy-pro .
   ```
4. Start by testing in interactive mode to confirm LabVIEWCLI commands run as expected before integrating the image into CI/CD pipelines.
5. Consider publishing your custom image to a private container registry (for example, GHCR or Docker Hub) for easier sharing across your team or CI systems.
6. For information about running LabVIEW in headless mode and the `-Headless` argument for newer LabVIEW versions, see the [Linux Prebuilt Images](./linux-prebuilt.md) and [Headless LabVIEW](./headless-labview.md) documentation.

## What's next

- Learn how to use ready-made images: [Using the Prebuilt Images](./use-prebuilt-image.md)
- Review how headless execution behaves in containers: [Headless LabVIEW](./headless-labview.md)
- Explore CI/CD and CLI usage patterns: [Examples](./examples.md)
