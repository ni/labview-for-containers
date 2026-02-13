# Example Usages of LabVIEW Container
Please find the old examples for Linux Containers with LabVIEW 2025 Q3 [here](./examples2025q3.md)

The following examples are for **LabVIEW 2026 Q1** supporting **both Linux and Windows containers** along with the introduction of **Headless Run Mode**

## Setup your system for windows containers
Please refer to official Microsoft's instructions on how to setup your windows machines for windows containers here: [Get started: Prep Windows for containers](https://discord.com/channels/1015999107921354932/1049145020764127352)

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

For other supported operations, see example scripts here: 
1. [Example Script for Windows](../examples/integration-into-cicd/runlabview.ps1)
2. [Example Script for Linux](../examples/integration-into-cicd/runlabview.sh)

### 7. Closing LabVIEW Gracefully
The recommended way to close a Headless LabVIEW instance is through LabVIEWCLI `CloseLabVIEW` operation.
```powershell
LabVIEWCLI -OperationName CloseLabVIEW -Headless
```
![CloseLabVIEW](../examples/CloseLV.png)

### 8. Debugging LabVIEW Issues
There is no UI when LabVIEW in running in Headless mode. To debug a issue in LabVIEW, use the following techniques:
1. **Inspect LabVIEWCLI Log**
    - Whenever a LabVIEWCLI Operation is ran, LabVIEW logs the operation output into a log file. 
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

### 9. Integration into GitHub Actions
A example GitHub action is configured to run LabVIEWCLI on LabVIEW Containers.
The YAML Configurations are located here: [GitHub Actions for LabVIEW Containers](https://github.com/ni/labview-for-containers/tree/main/.github/workflows)

To see all of this in action, do the following:
1. Fork this repository: [labview-for-containers](https://github.com/ni/labview-for-containers/tree/main)
2. Raise a Pull request with a small change to any of the repo files.
3. See the action running on LabVIEW Containers.

Example runs:
1. [Windows](https://github.com/ni/labview-for-containers/actions/runs/20814010697/job/59784984845)
2. [Linux](https://github.com/ni/labview-for-containers/actions/runs/20429840332/job/58697931582)

Feel free to tailor the workflow to your needs—add or remove jobs, adjust environment variables, or modify volume mounts. You can also use the provided YAML definitions as a springboard for your own CI/CD pipelines. This example is meant as a reference implementation to help you quickly integrate LabVIEWCLI commands into your automated workflows.






