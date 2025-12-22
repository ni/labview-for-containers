# Using the Prebuilt Images (Recommended for Most Users)
This guide provides instructions for using the prebuilt LabVIEW container images, publicly available on Docker Hub.

Use this approach if you're looking for a plug-and-play experience with minimal configuration effort.

## Table of Contents
- [Image Specifications](#image-specifications)
- [Examples](#examples)
- [What's next](#whats-next)

## Image Specifications
### Image Name
National Instruments' official LabVIEW Docker images are published under the repository `nationalinstruments/labview` and follow the tag naming convention:

```text
<release>-<platform>
```

For example:

- `nationalinstruments/labview:2026q1-windows`
- `nationalinstruments/labview:2025q3patch1-linux`

The list of all official releases can be found here: [Releases](https://github.com/ni/labview-for-containers/releases).

**Link to all available Docker images is [here.](https://hub.docker.com/r/nationalinstruments/labview)**

For more information on Windows and Linux images, please follow the documents below:
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