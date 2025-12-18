# Using the Prebuilt Images (Recommended for Most Users)
This guide provides instructions for using the prebuilt LabVIEW container images, publicly available on DockerHub.

Use this approach if you're looking for a plug-and-play experience with minimal configuration effort.

## Image Specifications
### Image Name
National Instrument's official LabVIEW Docker images follow the naming convention: `labview-<release>-<platform>` 

For example: `labview:2026q1-windows`, `labview:2025q3patch1-linux`

The list of all official releases can be found here: [Releases](https://github.com/ni/labview-for-containers/releases)

**Link to all the available docker images is [here.](https://hub.docker.com/r/nationalinstruments/labview)**

For more information on windows and linux images, please follow the below readmes:
1. [Windows Prebuilt Images](./windows-prebuilt.md)
2. [Linux Prebuilt Images](./linux-prebuilt.md)

## Examples
For detailed examples on:
- Using **LabVIEWCLI**
- Changing the **default entrypoint**
- **Mounting local volumes** to access your source files

Please see the [Examples Guide](./examples.md)

## What's next
- [Windows Prebuilt Images](./windows-prebuilt.md)
- [Linux Prebuilt Images](./linux-prebuilt.md)
- [Examples](./examples.md)