# Using the Prebuilt Image (Recommended for Most Users)
This guide provides instructions for using the prebuilt LabVIEW Linux container image, publicly available on DockerHub.

Use this approach if you're looking for a plug-and-play experience with minimal configuration effort.

## Image Specifications
### Image Name
This image is available on NI's Official DockerHub Account with the name `labview:2025q3-linux`.


### Base Image
This Prebuilt Image uses `ubuntu:22.04` as its base image. 

While it may run on other Linux distributions base images (with Docker), we officially support and test only on Ubuntu 22.04 as the container base.

### Preinstalled Software Stack
The image comes with the following software pre-installed.
1. LabVIEW Professional 2025 Q3
2. LabVIEW RunTime Engine 2025 Q3
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
**_TODO:** Update links to the image on dockerhub once available.
The prebuilt image is hosted on NI’s official DockerHub account and is configured to allow anonymous pulls (no login required).

Use the command:
```
    docker pull <PlaceHolder for the link>/labview:2025q3-linux
```
Once the image is pulled successfully, it will be available locally and ready to use in your CI/CD pipeline or development environment.

You can verify the image is available by running:
```
    docker images
```
Look for an entry similar to:

```
REPOSITORY         TAG         IMAGE ID       CREATED        SIZE

ni/labview         2025q3-linux   abc123xyz...   2 days ago     3.2GB
```
## Running the image
**_TODO:** Update links to the image on dockerhub once available.
Once the image has been successfully pulled, run the following command to enter the container’s interactive shell:
```
    docker run -it <PlaceHolder for link>/labview:2025q3-linux
```

This will drop you into a Bash shell inside the container.

From here, you're ready to execute **LabVIEWCLI commands** to run VIs, perform builds, or run VI Analyzer tests.

## Examples
For detailed examples on:
- Using **LabVIEWCLI**
- Changing the **default entrypoint**
- **Mounting local volumes** to access your source files
Please see the [Examples Guide](./examples.md)

---
**NOTE:** By default, the NI's Customer Experience Improvement Program (CEIP) is enabled on the image and we collect anonymous information about the use of NI products, your computer or device, and connected devices. NI uses the aggregate of this information to improve the products and features customers use most often and to help solve problems. We do not collect personal data or proprietary application information, and we do not sell usage information to third parties.

For more information on NI's Customer Experience Improvement Program please see this: [NI Customer Experience Improvement Program](https://www.ni.com/en/about-ni/legal/ceip.html?srsltid=AfmBOorZGikj9CSWmeYxwtWemmv_Byhk3ew3YcSwNaRmAhkIBtCzXWmF)

To **enable/disable the collection of CEIP Data**, execute this command once inside the container shell:
```
LabVIEWCLI -OperationName RunVI -VIPath /usr/local/natinst/share/nilvcli/supportVIs/ToggleCEIP.vi <ON/OFF> -LabVIEWPath /usr/local/natinst/LabVIEW-2025-64/labview
```