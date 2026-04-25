# LabVIEW for Containers

> **LabVIEW Docker container images** — run headless LabVIEW in Docker for LabVIEW automation, automated builds, CI/CD pipelines, static code analysis, and more on Linux and Windows.

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-nationalinstruments%2Flabview-blue?logo=docker)](https://hub.docker.com/r/nationalinstruments/labview)

This project provides prebuilt LabVIEW container images and Dockerfiles for running LabVIEW and LabVIEWCLI in Docker. Use them for LabVIEW headless builds, LabVIEW CICD integration, MassCompile, VI Analyzer, RunVI, build specs, and other LabVIEWCLI operations — with GitHub Actions, GitLab CI/CD, Jenkins, Azure DevOps, and more.

**Key features:**
- Prebuilt Linux and Windows LabVIEW Docker container images on Docker Hub
- Headless LabVIEW execution (LabVIEW 2026 Q1+) — no display or GUI required
- Ready-to-use GitHub Actions and GitLab CI/CD workflow examples
- Dockerfiles for building custom LabVIEW container images with your own tools and dependencies

---

<strong>Table of Contents</strong>

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [Prebuilt Images](#prebuilt-images-recommended-for-most-users)
  - [Build Your Own Image](#build-your-own-image-for-advanced-users)
- [Examples & CI/CD Integration](#examples--cicd-integration)
- [Releases & Changelog](#releases--changelog)
- [Frequently Asked Questions](#frequently-asked-questions)
- [License](#license)



## Overview
National Instruments officially supports LabVIEW containers on both Windows and Linux to streamline LabVIEW automation and LabVIEW CICD workflows. The base images are publicly available on Docker Hub:

**Docker Hub:** [nationalinstruments/labview](https://hub.docker.com/r/nationalinstruments/labview)

## Prerequisites 
1. Docker Engine or Docker CLI (version 20.10+)
2. At least 8 GB RAM (16 GB for Windows containers) and 4 CPU cores available (recommended)
3. Internet connection for downloading and/or building your own image.
4. Familiarity with Docker commands and concepts is helpful, especially if you plan to use or extend the Dockerfile.

## Getting Started
We offer two delivery options depending on your use case:

### Prebuilt Images (Recommended for Most Users)
Prebuilt LabVIEW container images on Docker Hub include a ready-to-use LabVIEW installation. Use these for a plug-and-play experience with minimal configuration.

- **Image name:** `nationalinstruments/labview:<release>-<platform>`
- See [Releases](https://github.com/ni/labview-for-containers/releases) for available LabVIEW Docker container tags.
- **Full guide:** [Using Prebuilt Images](./docs/use-prebuilt-image.md) — image specs, pulling, running, and examples.

**Beta releases:** We publish beta versions for every new LabVIEW release with tag `<release>-<platform>-beta` on [Docker Hub](https://hub.docker.com/r/nationalinstruments/labview).

### Build Your Own Image (For Advanced Users)
For teams that need more control — adding custom tools, scripts, network settings, or dependencies — we provide official Dockerfiles.

- **Full guide:** [Build Your Own Image](./docs/build-your-own-image.md) — prerequisites, Dockerfile overview, and build instructions.

## Examples & CI/CD Integration
The [Examples guide](./docs/examples.md) covers interactive usage of LabVIEW containers — pulling images, running LabVIEWCLI commands, mounting volumes, debugging headless LabVIEW, and more.

For LabVIEW automated builds and LabVIEW CICD pipeline integration:
- **GitHub Actions:** [CI/CD Examples](./docs/cicd-examples.md) — MassCompile and VI Analyzer workflows with helper scripts
- **GitLab CI/CD:** [GitLab CI/CD Integration](./docs/gitlab-cicd.md) — equivalent pipeline definitions

## Releases & Changelog

Official LabVIEW container images are released on Docker Hub and documented
using GitHub Releases.

**Release notes:** https://github.com/ni/labview-for-containers/releases

Each GitHub Release corresponds to **one Docker image tag** published on Docker Hub.

### Version Mapping
| GitHub Release | Docker Image Tag |
|---------------|------------------|
| `v2025q3-linux`    | `nationalinstruments/labview:2025q3-linux` |
| `v2025q3patch1-linux` | `nationalinstruments/labview:2025q3patch1-linux` |


## Frequently Asked Questions
See [FAQs](./docs/faqs.md) for common questions about LabVIEW containers, headless LabVIEW, LabVIEWCLI, and CI/CD integration.

## License
If you have acquired a development license, you may deploy and use LabVIEW software within Docker containers, virtual machines, or similar containerized environments (“Container Instances”) solely for continuous integration, continuous deployment (CI/CD), automated testing, automated validation, automated review, automated build processes, static code analysis, unit testing, executable generation, and report generation activities. You may create unlimited Container Instances and run unlimited concurrent Container Instances for these authorized automation purposes. It is hereby clarified that You may only host, distribute, and make available Container Instances containing LabVIEW software internally within your organization where such Container Instances are not made available to anyone outside your organization unless otherwise agreed under your license terms. Container Instances may be accessed by multiple users within your organization for the automation purposes specified in this paragraph, without requiring individual licenses for each user accessing the Container Instance. In no event may you use LabVIEW software within Container Instances for development purposes, including but not limited to creating, editing, or modifying LabVIEW code, with the exception of debugging automation processes as specifically permitted above. You may not distribute Container Instances containing LabVIEW software to third parties outside your organization without NI’s prior written consent.


## What's next
- [Examples](./docs/examples.md) — interactive usage, LabVIEWCLI commands, and debugging
- [CI/CD Examples](./docs/cicd-examples.md) — MassCompile and VI Analyzer workflows
- [Headless LabVIEW](./docs/headless-labview.md) — headless execution mode details