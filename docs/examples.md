# Example Usages of LabVIEW Docker Containers

> Interactive examples for pulling, running, and using LabVIEW containers with LabVIEWCLI on Linux and Windows.

For examples specific to Linux containers with LabVIEW 2025 Q3, see the [2025 Q3 examples](./examples2025q3.md).

The following examples are for **LabVIEW 2026 Q1** supporting **both Linux and Windows containers** along with the introduction of **Headless Run Mode**.

## Setup Your System for Windows Containers
Please refer to Microsoft's official instructions on how to set up your Windows machine for Windows containers: [Get started: Prep Windows for containers](https://discord.com/channels/1015999107921354932/1049145020764127352)

---

## General Examples
### 1. Pulling the image from DockerHub
```bash
docker pull nationalinstruments/labview:<version>-<os>
```
**Example**
```bash
docker pull nationalinstruments/labview:2026q1-windows
```

### 2. Listing all available images
After pulling, enter:
```bash
docker images
```
![Docker Images](../examples/Images.png)

### 3. Running a container
After pulling, enter:
```bash
docker run -it nationalinstruments/labview:2026q1-windows
```
The above command will initialize a container for the LabVIEW image and drops the user into the interactive shell of container.

### 4. Accessing LabVIEWCLI General help
```powershell
LabVIEWCLI -Help -Headless
```
![LabVIEWCLI Help](../examples/LabVIEWCLI%20help.png)

### 5. Accessing LabVIEWCLI's Operation specific help
```powershell
LabVIEWCLI -OperationName ExecuteBuildSpec -Help -Headless
```
![Operation Help](../examples/Ophelp.png)

### 6. Running MassCompile operation on a Directory
```powershell
LabVIEWCLI -OperationName MassCompile -DirectoryToCompile "C:\Program Files\National Instruments\LabVIEW 2026\examples\Arrays" -Headless
```
![MassCompile](../examples/MassCompileHeadless.png)

For CI/CD workflows using MassCompile, VI Analyzer, and other LabVIEWCLI operations, see the [CI/CD Examples](./cicd-examples.md) guide.

### 7. Closing LabVIEW Gracefully
The recommended way to close a Headless LabVIEW instance is through LabVIEWCLI `CloseLabVIEW` operation.
```powershell
LabVIEWCLI -OperationName CloseLabVIEW -Headless
```
![CloseLabVIEW](../examples/CloseLV.png)

### 8. Debugging Headless LabVIEW Issues
There is no UI when headless LabVIEW is running. To debug an issue, use the following techniques:
1. **Inspect LabVIEWCLI Log**
    - Whenever a LabVIEWCLI operation is run, LabVIEW logs the output into a log file. 
    - The path to the logfile is displayed on the STDOUT.
    - ![LogFile Path](../examples/CloseLV.png)
    - In the above example, the log file is generated at: `%temp%\lvtemporary_321777.log`
    - Inspect the log file to understand the issue.
2. **Inspect LabVIEW's own log file**
    - LabVIEW logs important details in a separate log file located at: `%temp%\<AppName>_<Bitness>_<version>_<headless/interactive>_<user>_<log/cur>.txt`
    - Depending on the current running application, `<AppName>` could be LabVIEWCLI, LabVIEW or other LabVIEW Build Applications
    - Depending on the run mode of the application, the information would be logged into either a `headless` or `interactive` logfile.
    - The current instance always logs in a log file containing the string `cur` whereas the older logfile (if any present) is renamed from `cur` to `log`
    - Inspect the application specific logfile to get information on what went wrong.
    - ![LogFile](../examples/LV_Log.png)
3. **Inspect Unwired Errors**
    - If your VIs contain unwired errors, they are automatically logged into a log file when running in Headless Mode.
    - The path to the log file generally is: `%Documents%\LabVIEW Data\UnwiredErrors\LabVIEW*.UnwiredErrors.log`
4. **DWarns are automatically logged when running in Headless Mode**

### 9. CI/CD Pipeline Integration

The LabVIEW Docker container images in this repository can be used in automated CI/CD pipelines:

- **GitHub Actions:** [CI/CD Examples](./cicd-examples.md) — MassCompile and VI Analyzer workflows with helper scripts
  - Example runs: [Windows](https://github.com/ni/labview-for-containers/actions/runs/20814010697/job/59784984845) | [Linux](https://github.com/ni/labview-for-containers/actions/runs/20429840332/job/58697931582)
- **GitLab CI/CD:** [GitLab CI/CD Integration](./gitlab-cicd.md) — equivalent pipeline definitions

---

## See Also

- [Headless LabVIEW](./headless-labview.md) — details on headless execution mode
- [FAQs](./faqs.md) — common questions and troubleshooting