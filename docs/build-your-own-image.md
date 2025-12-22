# Building Your Own LabVIEW Container Images

This document is an entry point for building **custom LabVIEW container images**. There are separate guides for Linux and Windows containers:

- [Building Your Own LabVIEW Linux Container Image](./linux-custom-images.md)
- [Building Your Own LabVIEW Windows Container Image](./windows-custom-images.md)

Use these guides if you need more control than the prebuilt images provide—for example, to:
- Install additional software or dependencies
- Include custom scripts or test frameworks
- Configure environment- or network-specific settings

## When to Use Which Guide

- Use the **Linux** custom image guide when:
  - Your CI/CD runners or deployment targets rely on Linux containers.
  - You are comfortable working with Ubuntu-based images and `.deb` installers.

- Use the **Windows** custom image guide when:
  - You need a Windows Server–based container running on a Windows host.
  - Your automation must integrate with Windows-only tooling or drivers.

For general information about supported base images and headless operation, see:
- [Linux Prebuilt Images](./linux-prebuilt.md)
- [Windows Prebuilt Images](./windows-prebuilt.md)
- [Headless LabVIEW](./headless-labview.md)

## What's next

- If you are targeting **Linux containers**, continue with: [Building Your Own LabVIEW Linux Container Image](./linux-custom-images.md)
- If you are targeting **Windows containers**, continue with: [Building Your Own LabVIEW Windows Container Image](./windows-custom-images.md)