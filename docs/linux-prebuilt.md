# Linux Prebuilt Images

## Overview
These prebuilt images provide a ready-to-use LabVIEW environment for Linux containers, optimized for headless automation and CI/CD workflows.

## Table of Contents
- [Overview](#overview)
    - [Base Image](#base-image)
    - [Preinstalled Software Stack](#preinstalled-software-stack)
    - [Intended Use](#intended-use)
- [Accessing the image](#accessing-the-image)
- [Running the image](#running-the-image)
- [Customer Experience Improvement Program (CEIP)](#customer-experience-improvement-program-ceip)
- [Important](#important)
- [What's next](#whats-next)

### Base Image
Prebuilt images for Linux containers use `ubuntu:22.04` as their base image. 

While it may also run on other Linux distribution base images (with Docker), we officially support and test only on Ubuntu 22.04 as the container base.

### Preinstalled Software Stack
The image comes with the following software pre-installed.
1. LabVIEW Professional
2. LabVIEW RunTime Engine
3. LabVIEW Command Line Interface (LabVIEWCLI)
4. VI Analyzer Toolkit
5. X Virtual Frame Buffer (Xvfb)

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

The prebuilt image is hosted on [NI’s official Docker Hub](https://hub.docker.com/r/nationalinstruments/labview) account and is configured to allow anonymous pulls (no login required).

Use the command:
```shell
    docker pull nationalinstruments/labview:2025q3-linux
```

Or, if you want the latest:
```shell
    docker pull nationalinstruments/labview:latest-linux
```

Once the image is pulled successfully, it will be available locally and ready to use in your CI/CD pipeline or development environment.

You can verify the image is available by running:
```shell
    docker images
```
Look for an entry similar to:

```s
REPOSITORY         TAG         IMAGE ID       CREATED        SIZE

nationalinstruments/labview   2025q3-linux   abc123xyz...   2 days ago     3.2GB
```
## Running the image

Once the image has been successfully pulled, run the following command to enter the container’s interactive shell:
```shell
    docker run -it nationalinstruments/labview:2025q3-linux
```

This will drop you into a Bash shell inside the container.

From here, you're ready to execute **LabVIEWCLI commands** to run VIs, perform builds, or run VI Analyzer tests.

**NOTE:** LabVIEW Linux container images can run on any host OS that supports Docker and Linux containers (for example, Windows or Linux).

## Customer Experience Improvement Program (CEIP)

By default, NI's Customer Experience Improvement Program (CEIP) is enabled on the image and NI collects anonymous information about the use of NI products, your computer or device, and connected devices. NI uses the aggregate of this information to improve the products and features customers use most often and to help solve problems. NI does not collect personal data or proprietary application information, and NI does not sell usage information to third parties.

For more information on NI's Customer Experience Improvement Program please see: [NI Customer Experience Improvement Program](https://www.ni.com/en/about-ni/legal/ceip.html).

To **enable or disable the collection of CEIP data**, execute this command once inside the container shell:
```bash
LabVIEWCLI -OperationName RunVI -VIPath /usr/local/natinst/share/nilvcli/supportVIs/ToggleCEIP.vi <ON/OFF> -LabVIEWPath /usr/local/natinst/LabVIEW-2025-64/labview
```

## Important
LabVIEW 2026 Q1 and onwards support Headless LabVIEW run mode, which is a replacement for the environment variable toggle `EnableCICDFeaturesForLabVIEW=TRUE`.

To enable CI/CD features in LabVIEW and run it on Linux containers, **all LabVIEWCLI commands must end with the `-Headless` argument**, which enables LabVIEW to run completely headless.

If the `-Headless` argument is NOT passed to LabVIEWCLI, it can cause compatibility issues on Docker images. The `-Headless` argument is necessary to satisfy all requirements to run LabVIEW on Linux containers.

**NOTE:** The above is TRUE only for LabVIEW 2026 Q1 and onwards. For older images using LabVIEW 2025 Q3, continue using the environment variable `EnableCICDFeaturesForLabVIEW=TRUE`.

## What's next
- [Windows Prebuilt Images](./windows-prebuilt.md)
- [Headless LabVIEW](./headless-labview.md)
- [Examples](./examples.md)