# Windows Prebuilt Images

## Overview
These prebuilt images provide a ready-to-use LabVIEW environment for Windows containers, optimized for headless automation and CI/CD workflows.

## Table of Contents
- [Overview](#overview)
    - [Base Image](#base-image)
    - [Preinstalled Software Stack](#preinstalled-software-stack)
    - [Intended Use](#intended-use)
- [Accessing the image](#accessing-the-image)
- [Running the image](#running-the-image)
- [Important](#important)
- [What's next](#whats-next)

### Base Image
Prebuilt images for Windows containers use `mcr.microsoft.com/windows/server:ltsc2022` as their base image. 

Minimal images like `servercore` lack many important system-level dependencies that are needed for running LabVIEW. This is the main reason for using the `server` image.

### Preinstalled Software Stack
The image comes with the following software pre-installed.
1. LabVIEW Professional (version depends on the tag of the image)
2. LabVIEW RunTime Engine
3. LabVIEW Command Line Interface (LabVIEWCLI)
4. VI Analyzer Toolkit
5. NI Package Manager and NI Package Manager CLI

### Intended Use
The prebuilt image is optimized for:
1. Automated Testing
2. VI Diff Report generation
3. MassCompiling VIs
4. Running Static Code Analysis using VI Analyzer
5. Headless project builds
6. CI/CD Integration (e.g., GitHub Actions, GitLab, Jenkins)

Use `LabVIEWCLI` as the primary interface for interacting with LabVIEW within the container.

**NOTE:** _This container is designed for headless automation and CI/CD. The LabVIEW GUI is not available, and all LabVIEW operations must be invoked through the LabVIEW CLI._

## Accessing the image

The prebuilt images are hosted on [NI’s official Docker Hub](https://hub.docker.com/r/nationalinstruments/labview) account and are configured to allow anonymous pulls (no login required).

**NOTE:** To pull a Windows Docker image, make sure you have a Windows host with Docker installed and configured for Windows containers.
To understand how to switch to Windows containers in Docker, follow [this guide](https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=dockerce#windows-10-and-windows-11-2).

Use the command:
```shell
    docker pull nationalinstruments/labview:2026q1-windows-beta
```

Or, if you want the latest:
```shell
    docker pull nationalinstruments/labview:latest-windows
```

Once the image is pulled successfully, it will be available locally and ready to use in your CI/CD pipeline or development environment.

You can verify the image is available by running:
```shell
    docker images
```
Look for an entry similar to:

```s
REPOSITORY         TAG         IMAGE ID       CREATED        SIZE

nationalinstruments/labview   2026q1-windows-beta   abc123xyz...   2 days ago     22.0GB
```

## Running the image
Once the image has been successfully pulled, run the following command to enter the container’s interactive shell:
```shell
    docker run -it nationalinstruments/labview:2026q1-windows-beta
```

This will drop you into a shell inside the container.

From here, you're ready to execute **LabVIEWCLI commands** to run VIs, perform builds, or run VI Analyzer tests.

**NOTE:** LabVIEW Windows container images can only run on a Windows host.

---

## Important
LabVIEW on Windows containers requires that **all LabVIEWCLI commands end with the `-Headless` argument**, which enables LabVIEW to run completely headless (without UI) and without the need for activation.

If the `-Headless` argument is NOT passed to LabVIEWCLI, LabVIEW will be launched in normal UI mode, which can cause multiple issues in CI/CD environments such as:
1. Activation prompts blocking execution indefinitely.
2. Other LabVIEW native popups blocking the execution indefinitely.
3. Because accessing the UI of Windows containers is not straightforward, any error popups that arise are not visible and can block execution indefinitely.

**NOTE:** The above is TRUE only for LabVIEW 2026 Q1 and onwards.

## What's next
- [Linux Prebuilt Images](./linux-prebuilt.md)
- [Headless LabVIEW](./headless-labview.md)
- [Examples](./examples.md)