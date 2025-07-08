# Example Usages of LabVIEW Container
## Example Usage: LabVIEWCLI
### LabVIEWCLI: Run VI Analyzer Tests on VIs
Run Static code analysis on VIs using VI Analyzer Toolkit

**Use Command:**
```
    LabVIEWCLI
    -OperationName RunVIAnalyzer \
    -ConfigPath <Path to VI Analyzer config file> \
    -ReportPath <Location for saving the report> \
    -LabVIEWPath <Path to LabVIEW Executable>
```
![Run VI Analyzer](../examples/VIA.PNG)

### LabVIEWCLI: CreateComparisonReport
Create a diff report between two VIs

**Use Command:**
```bash
    LabVIEWCLI -OperationName CreateComparisonReport \
    -VI1 VINameOrPath1.vi \
    -VI2 VINameOrPath2.vi \
    -ReportType html \
    -ReportPath ReportPath.html
```

![VIDiff](../examples/CompareReport.PNG)

**Generated Report:**
![GeneratedReport](../examples/DiffReport.PNG)

### LabVIEWCLI: MassCompile VIs
MassCompile a Directory

**Use Command:**
```bash
    LabVIEWCLI -OperationName MassCompile -DirectoryToCompile <Directory to Compile> -LabVIEWPath <Path to LabVIEW Executable>
```

![MassCompile](../examples/MassCompile.PNG)

### LabVIEWCLI: RunVI
Run a specific VI on the system.

**Use Command:**
```bash
    LabVIEWCLI -OperationName RunVI -VIPath <Path to VI> -LabVIEWPath <Path to LabVIEW Executable>
```

For full details on all available LabVIEWCLI Commands, please find the official NI's LabVIEWCLI Documentation [here.](https://www.ni.com/docs/en-US/bundle/labview/page/predefined-command-line-operations.html?srsltid=AfmBOorqX__K-Rfh8JZCEho3PyoM75cXxBwij71DN5g89FPu6YoTZ7VQ)

## Example Usage: Change entrypoint of the container
By default, the LabVIEW container image does not define a default **CMD** or **ENTRYPOINT.**

The entrypoint of a container is the primary process that runs when the container starts — often referred to as PID 1.

Fortunately, Docker allows you to override the entrypoint at runtime using the `--entrypoint` flag.

You can launch the container with LabVIEWCLI as the main process like this:

```shell
docker run --rm --entrypoint LabVIEWCLI labview:2025q3-linux
```

![Entrypoiny](../examples/Entrypoint.PNG)

This will start the container, run LabVIEWCLI, and then terminate the container once the CLI process exits.

### Why Use This?
- Perform a single CLI-driven task (e.g., mass compile, run a VI)
- Exit cleanly after completing that task
- Be used in CI/CD pipelines or automation scripts

## Example Usage: Mount Local Volumes
You can mount a local directory into the container using the `-v` (volume) flag.

Let's mount a local directory into the container and see the contents of a text file.

**Use Command:**
```shell
    docker run -it -v C:\ni:/mounted_directory labview:2025q3-linux
```

![Mount](../examples/MountLocalDir.PNG)

- `-v C:\ni:/mounted_directory` tells Docker to mount your local folder into `/mounted_directory `inside the container.
- The container will have read/write access to the mounted folder.

## Example Usage: Integration with CI/CD
The combination of the above usages along with automation tools like GitHub actions, Jenkins etc can unlock the true potential of LabVIEW in CI/CD Environments.

Let's look at an example of integrating LabVIEW Container into a GitHub action. All the neccessary files are present at **{repo-root}/examples/integration-into-cicd**

### Testing Script
A script designed to run LabVIEWCLI to perform `MassCompile` and `RunVIAnalyzer` operations on a set of Test-VIs.

The script is located here: [runlabview.sh](../examples/integration-into-cicd/runlabview.sh)

The job of the script is to:
1. Run LabVIEWCLI MassCompile Operation
2. Run LabVIEWCLI VI Analyzer Operation
3. Exit with error is any of the above operation fail.

### GitHub Action
The configuration file for example GitHub Action is located here at: [labview-container-check.yml](../.github/workflows/labview-container-check.yml)

The action does the following:
1. Login into GitHub Container Registry
2. Pull in the image `labview:2025q3-linux`
3. Mount the repository into the container
4. Run the script `runlabview.sh` as container's entrypoint.

The action is set to be triggered when any pull request is created, updated or reopened.

### Running the GitHub Action
A testing Pull Request has been created that demonstrates the use of the script `runlabview.sh` and the GitHub Action to run LabVIEWCLI inside a container.

Link to the Pull Request: [Integration into CI/CD](https://github.com/ni/labview-for-containers/pull/5)

- When a Pull Request is opened, a status check running the GitHub Action can be seen.
    ![CICD-PullRequest](../examples/int-cicd.PNG)

- If we navigate to the run logs by clicking on the Action, we can see what all jobs were executed as part of this pipeline.
    ![Log](../examples/TopLevelLog.PNG)

- Expanding the job shows the full log of that particular step.
    ![CompLog](../examples/CompleteLog.PNG)

The Complete run can be found [here.](https://github.com/ni/labview-for-containers/actions/runs/16333422879/job/46140796978?pr=5)

___

Feel free to tailor the workflow to your needs—add or remove jobs, adjust environment variables, or modify volume mounts. You can also use the provided YAML definitions as a springboard for your own CI/CD pipelines. This example is meant as a reference implementation to help you quickly integrate LabVIEWCLI commands into your automated workflows.







