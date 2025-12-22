# Building Your Own LabVIEW Windows Container Image

This guide provides instructions for building your own LabVIEW Windows container image using the official Windows Dockerfile and resources in this repository.

Use this approach if you need to:
- Install additional Windows tools or dependencies alongside LabVIEW
- Include custom scripts or test frameworks
- Configure a Windows-based CI/CD environment where LabVIEW runs headlessly inside a Windows container

## Table of Contents
- [Prerequisites](#prerequisites)
- [Important Considerations](#important-considerations)
- [Dockerfile Overview](#dockerfile-overview)
- [How to Build the Image](#how-to-build-the-image)
- [Final Notes](#final-notes)

## Prerequisites

Before building your own Windows image, make sure you have:

- A compatible Windows host with Docker installed and configured for **Windows containers**
- Permissions to run Windows Server Core–based images (for example, `mcr.microsoft.com/windows/server:ltsc2022`)
- Access to NI Package Manager (NIPKG) offline installers and the appropriate LabVIEW feeds
- A working internet connection if you rely on external feeds (optional if entirely offline)
- Access to the official Windows Dockerfile, located at: [examples/build-your-own-image/Dockerfile-windows](../examples/build-your-own-image/Dockerfile-windows)

## Important Considerations

- These images are based on a Windows Server image and are intended for **headless** LabVIEW use.
- All interactions with LabVIEW inside the container should be performed using **LabVIEWCLI**.
- When running LabVIEWCLI in Windows containers for LabVIEW 2026 Q1 and later, you must use the `-Headless` argument as described in the [Windows Prebuilt Images](./windows-prebuilt.md) documentation.

## Dockerfile Overview

The Windows Dockerfile at `examples/build-your-own-image/Dockerfile-windows` performs the following key tasks.

1. **Base Image and LabVIEW Year**
   ```dockerfile
   FROM mcr.microsoft.com/windows/server:ltsc2022

   ARG LV_YEAR=2026
   ARG LV_FEED_LOCATION=http://argohttp.natinst.com/ni/nipkg/feeds/ni-l/ni-labview-2026/26.1.0/26.1.0.625-0+d625/offline
   ENV LV_YEAR=${LV_YEAR}
   ENV LV_FEED_LOCATION=${LV_FEED_LOCATION}
   ```
   - Uses a Windows Server LTSC 2022 base image.
   - Exposes `LV_YEAR` and `LV_FEED_LOCATION` as build arguments and environment variables.
   - `LV_FEED_LOCATION` should point to a valid NI feed containing the desired LabVIEW version.

2. **Configure PowerShell for Automated Installation**
   ```dockerfile
   SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Continue'; $ProgressPreference = 'SilentlyContinue'; $ConfirmPreference = 'None'; $VerbosePreference = 'Continue'; $WarningPreference = 'Continue';"]
   ```
   - Configures PowerShell preferences to enable automated, unattended installs.

3. **Prepare Installer Resources**
   ```dockerfile
   RUN New-Item -ItemType Directory -Path 'C:\\ni\\resources' -Force
   COPY ["Resources/Windows Resources", "C:/ni/resources/"]
   ```
   - Creates a temporary folder for installers.
   - Copies Windows installer resources from `Resources/Windows Resources` into the image (for example, NI Package Manager bootstrapper and LabVIEW.ini template).
   - **You would have to place the NI Package Manager installer and name it as install.exe under `Resources/Windows Resources`.**

4. **Install NI Package Manager (NIPKG)**
   ```dockerfile
   RUN Start-Process -wait C:\\ni\\resources\\install.exe -ArgumentList '--passive', '--accept-eulas', '--no-shortcuts', '--no-start-menu', '--no-desktop-icon', '--no-update-check', '--prevent-reboot'
   ```
   - Installs NI Package Manager in passive mode, accepting EULAs and preventing reboots.

5. **Add NIPKG to PATH**
   ```dockerfile
   RUN setx PATH "%PATH%;C:\\Program Files\\National Instruments\\NI Package Manager"
   ```
   - Ensures `nipkg` is available on the PATH for later steps.

6. **Install LabVIEW and Tooling Using NIPKG**
   ```dockerfile
   SHELL ["cmd", "/S", "/C"]
   RUN nipkg feed-add --name=LV%LV_YEAR% %LV_FEED_LOCATION%
   RUN nipkg feed-info
   RUN nipkg feed-update
   RUN nipkg install --accept-eulas -y ni-offline-help-viewer || exit /b 0
   RUN nipkg install --accept-eulas -y ni-ceip ni-labview-%LV_YEAR%-core-en ni-viawin-labview-support || exit /b 0
   RUN nipkg install --accept-eulas -y ni-labview-command-line-interface-x86 || exit /b 0
   ```
   - Switches to `cmd` for compatibility with `nipkg` commands.
   - Adds the LabVIEW feed, updates feeds, and installs:
     - NI offline help viewer
     - CEIP, LabVIEW core, VI Analyzer support
     - LabVIEW Command Line Interface (x86)
   - Uses `|| exit /b 0` to avoid failing the build if a package runs into issues while installing.

7. **Remove Internal Feeds and Enable VI Server**
   ```dockerfile
   RUN nipkg feed-remove LV%LV_YEAR%
   RUN nipkg feed-update
   RUN move C:\\ni\\resources\\LabVIEW.ini "C:\\Program Files\\National Instruments\\LabVIEW %LV_YEAR%\\LabVIEW.ini"
   ```
   - Removes the temporary feed configuration.
   - Moves a preconfigured `LabVIEW.ini` into the LabVIEW installation directory to enable VI Server and other required INI tokens.

8. **Cleanup**
   ```dockerfile
   SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Continue'; $ProgressPreference = 'SilentlyContinue'; $ConfirmPreference = 'None'; $VerbosePreference = 'Continue'; $WarningPreference = 'Continue';"]
   RUN Remove-Item -Path 'C:\\ni\\resources' -Recurse -Force
   ```
   - Switches back to PowerShell and removes installer resources to keep the image smaller and cleaner.

## How to Build the Image

Once you've reviewed and optionally customized the Dockerfile, you can build your LabVIEW Windows container image using the `docker build` command.

1. Copy `Dockerfile-windows` and the `Resources/Windows Resources` folder to a working directory on your Windows build machine (or use them directly from the repo as your build context).
2. Ensure the contents of `Resources/Windows Resources` match your environment (for example, the NI Package Manager installer and the appropriate `LabVIEW.ini` file).
3. From the directory containing `Dockerfile-windows`, run:

```powershell
docker build -t <image-name> -f Dockerfile-windows .
```

You can override the LabVIEW year and feed location at build time if needed:

```powershell
docker build -t <image-name> -f Dockerfile-windows `
  --build-arg LV_YEAR=2026 `
  --build-arg LV_FEED_LOCATION=<your-offline-feed-url>
```

After the build completes, verify that the image exists:

```powershell
docker images
```

You can test the image interactively:

```powershell
docker run -it <image-name>
```

From inside the container, you can invoke `LabVIEWCLI` to run VIs, perform builds, or execute VI Analyzer operations. Remember to use the `-Headless` flag for supported LabVIEW versions, as described in the Windows prebuilt documentation.

## Final Notes

Before you finish, keep the following important points in mind:

1. These images are Windows Server–based and can only run on a **Windows host** configured for Windows containers.
2. Ensure that all required NI packages (LabVIEW core, VI Analyzer support, LabVIEWCLI, CEIP as desired) are installed via `nipkg` for your selected LabVIEW version.
3. Do not remove the steps that configure VI Server or the `LabVIEW.ini` file; doing so will break LabVIEWCLI operations.
4. If you modify the Dockerfile or build context, rebuild the image using a new tag, for example:
   ```powershell
   docker build -t labview-custom-windows:2026q1 -f Dockerfile-windows .
   ```
5. Start by testing the image interactively to confirm that LabVIEWCLI works end-to-end before integrating it into CI/CD pipelines.
6. Consider publishing your custom image to a private container registry (such as GHCR or Docker Hub) for easier sharing across your team or CI systems.
7. For guidance on running LabVIEW headlessly in Windows containers and using the `-Headless` argument, see the [Windows Prebuilt Images](./windows-prebuilt.md) and [Headless LabVIEW](./headless-labview.md) documentation.

## What's next

- Learn how to use the official prebuilt images: [Using the Prebuilt Images](./use-prebuilt-image.md)
- Review Windows container behavior and requirements: [Windows Prebuilt Images](./windows-prebuilt.md)
- Explore CI/CD integration patterns and LabVIEWCLI usage: [Examples](./examples.md)
