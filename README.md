# LabVIEW Linux Container
Welcome to the official release of our containerized LabVIEW environment!
This project enables you to run LabVIEW seamlessly on Linux using Docker, making it easier to integrate with CI/CD workflows, automate testing, and ensure consistent build environments.

---

## Overview
With the release of LabVIEW 2025 Q3, we now officially support Linux containers to streamline CI/CD workflows. The base image is publicly available on DockerHub under the official National Instruments account as: `labview:2025q3-linux`

**DockerHub Repository:** [nationalinstruments/labview](https://hub.docker.com/r/nationalinstruments/labview)

This README provides step-by-step guidance on:
1. Accessing the image from DockerHub
2. Running and deploying the container
3. Example use cases in CI/CD pipelines
4. Building your own custom LabVIEW image using the provided Dockerfile.

## Prerequisites 
1. Docker Engine or Docker CLI (version 20.10+)
2. At least 8 GB RAM and 4 CPU Cores available (Recommended)
3. Internet connection for downloading and/or building your own image.
4. Familiarity with Docker commands and concepts is helpful, especially if you plan to use or extend the Dockerfile.

## Modes of Delivery
We offer two delivery options depending on your use case:
1. **Prebuilt Image (Recommended for Most Users)**
    - A prebuilt image is available on DockerHub, which includes a ready-to-use LabVIEW 2025 Q3 installation.
    - **Image Name:** `labview:2025q3-linux`
    - Use this if you want a plug-and-play experience with minimal configuration.
2. **Official Dockerfile (For Advanced Users)**
    - For teams that require more control (e.g., adding custom tools, scripts, custom network settings), we provide an official Dockerfile to build your own image.
    - Use this approach if you want to:
        - Integrate your own automation or test scripts
        - Install specific Linux dependencies
        - Debug or modify the container setup

## Using the Prebuilt Image (Recommended for Most Users)
Please see the [Using the Prebuilt Image](./docs/use-prebuilt-image.md) guide for full details.
The documentation contains information about:
1. Image Specifications
2. Access the Docker Image
3. Run the Image.
4. Example Usages

## How to build your own Image (For Advanced Users)
Please see the [Build your Own Image](./docs/build-your-own-image.md) guide for full details.
The Documentation contains information about:
1. Prerequisites
2. Important Dependencies
3. Dockerfile Overview
4. Building the Image

## Example Usages
This [Example Guide](./docs/examples.md) contains information on example use cases of LabVIEW Linux Image. 

## Frequently Asked Questions (FAQs)
See the FAQ section [here.](./docs/faqs.md)

## License
If you have acquired a development license, you may deploy and use LabVIEW software within Docker containers, virtual machines, or similar containerized environments (“Container Instances”) solely for continuous integration, continuous deployment (CI/CD), automated testing, automated validation, automated review, automated build processes, static code analysis, unit testing, executable generation, and report generation activities. You may create unlimited Container Instances and run unlimited concurrent Container Instances for these authorized automation purposes. It is hereby clarified that You may only host, distribute, and make available Container Instances containing LabVIEW software internally within your organization where such Container Instances are not made available to anyone outside your organization unless otherwise agreed under your license terms. Container Instances may be accessed by multiple users within your organization for the automation purposes specified in this paragraph, without requiring individual licenses for each user accessing the Container Instance. In no event may you use LabVIEW software within Container Instances for development purposes, including but not limited to creating, editing, or modifying LabVIEW code, with the exception of debugging automation processes as specifically permitted above. You may not distribute Container Instances containing LabVIEW software to third parties outside your organization without NI’s prior written consent.
