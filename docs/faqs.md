# Frequently Asked Questions (FAQs)

## Table of contents

1. [Can I use the LabVIEW container with the full GUI/IDE?](#1-can-i-use-the-labview-container-with-the-full-guiide)
2. [Why do I need to install Xvfb if the container is headless?](#2-why-do-i-need-to-install-xvfb-if-the-container-is-headless)
3. [LabVIEWCLI fails with error -350000. What does this mean?](#3-labviewcli-fails-with-error--350000-what-does-this-mean)
4. [Can I build my own image with additional tools like Git or Python?](#4-can-i-build-my-own-image-with-additional-tools-like-git-or-python)
5. [Can I use the containers in GitHub Actions or GitLab CI pipelines?](#5-can-i-use-the-containers-in-github-actions-or-gitlab-ci-pipelines)
6. [Why is `unattended=True` (or similar tokens) set in the config file?](#6-why-is-unattendedtrue-or-similar-tokens-set-in-the-config-file)
7. [What host OS do I need to run these images?](#7-what-host-os-do-i-need-to-run-these-images)
8. [I launched LabVIEW without headless mode and now LabVIEWCLI will not work, even when I pass the headless argument. What is happening?](#8-i-launched-labview-without-headless-mode-and-now-labviewcli-will-not-work-even-when-i-pass-the-headless-argument-what-is-happening)
9. [Do I have to always pass the headless argument?](#9-do-i-have-to-always-pass-the-headless-argument)
10. [Is there a global override that always enables headless mode for LabVIEW?](#10-is-there-a-global-override-that-always-enables-headless-mode-for-labview)
11. [How do I close a headless LabVIEW instance?](#11-how-do-i-close-a-headless-labview-instance)
12. [Is headless mode supported for built applications as well?](#12-is-headless-mode-supported-for-built-applications-as-well)
13. [I cannot start an IDE instance and a headless instance simultaneously. Is that expected?](#13-i-cannot-start-an-ide-instance-and-a-headless-instance-simultaneously-is-that-expected)
14. [How can I debug headless LabVIEW on containers without a UI?](#14-how-can-i-debug-headless-labview-on-containers-without-a-ui)
15. [LabVIEWCLI fails to connect to LabVIEW on Windows containers, even with `-Headless` and VI Server enabled. What can I do?](#15-labviewcli-fails-to-connect-to-labview-on-windows-containers-even-with--headless-and-vi-server-enabled-what-can-i-do)

### 1. Can I use the LabVIEW container with the full GUI/IDE?
No. The containers are designed for headless use only, meaning the LabVIEW IDE GUI is not supported inside the container.
All interactions must happen via LabVIEWCLI (or `LabVIEW.exe --headless` for some workflows), which supports operations like RunVI, MassCompile, AnalyzeProject, and VI Analyzer runs.

For more details on how headless execution behaves, see [Headless LabVIEW](./headless-labview.md).

### 2. Why do I need to install Xvfb if the container is headless?
For Linux containers, LabVIEW still requires X11 support internally to render UI components, even when no visible display is shown.

`Xvfb` acts as a virtual framebuffer and satisfies these dependencies without a physical display.

### 3. LabVIEWCLI fails with error -350000. What does this mean?
This typically means the VI Server is not enabled or not reachable.

Ensure your `labview.conf` (or equivalent LabVIEW.ini on windows) includes this line:
```ini
server.tcp.enabled=True
```
This allows LabVIEWCLI to connect to the LabVIEW instance running inside the container.

### 4. Can I build my own image with additional tools like Git or Python?
Yes. You can customize the Dockerfile to install additional tools using your package manager (for example, `apt-get` on Linux or `choco`/`winget` on Windows).

For a Linux example:
```dockerfile
RUN apt-get update && apt-get install -y git python3
```

For full guidance on extending the base images, see:
- [Linux Custom Images](./linux-custom-images.md)
- [Windows Custom Images](./windows-custom-images.md)

### 5. Can I use the containers in GitHub Actions or GitLab CI pipelines?
Absolutely. The images are specifically designed for CI/CD workflows and have LabVIEWCLI and related tooling preinstalled.

See [Examples](./examples.md) for real-world CI usage patterns.

### 6. Why is `unattended=True` (or similar tokens) set in the config file?
These INI tokens suppress pop-ups and GUI dialogs from LabVIEW, which is critical for CI automation and headless runs.

You may temporarily remove or comment them out during manual debugging, but they are strongly recommended for automation scenarios.

### 7. What host OS do I need to run these images?
For Linux LabVIEW images, the container can run on any host OS (for example, RHEL, openSUSE, Ubuntu, Windows) as long as Docker is available and configured for Linux containers.

For Windows LabVIEW images, you must use a Windows host configured to run Windows containers. See:
- [Linux Prebuilt Images](./linux-prebuilt.md)
- [Windows Prebuilt Images](./windows-prebuilt.md)

### 8. I launched LabVIEW without headless mode and now LabVIEWCLI will not work, even when I pass the headless argument. What is happening?
Launching LabVIEW without the headless argument can show the activation wizard or other UI dialogs that block execution and require user interaction.

If an interactive IDE session is already running, starting a new headless LabVIEW instance will not succeed: the headless request will exit or be forwarded to the existing UI session.

Close the interactive LabVIEW IDE session first, then re-run your LabVIEWCLI command with the headless argument. For more details, see [Mutual Exclusivity Between Modes](./headless-labview.md#mutual-exclusivity-between-modes).

### 9. Do I have to always pass the headless argument?
On Windows containers, the first use of LabVIEWCLI with the `-Headless` argument will launch LabVIEW in headless mode. Subsequent LabVIEWCLI commands can reuse that headless session even if `-Headless` is not passed again, although it is recommended to always include `-Headless` for consistency and clarity.

On Linux containers, you must always pass the `-Headless` argument for headless executions.

For more details and best practices, see [Headless LabVIEW](./headless-labview.md).

### 10. Is there a global override that always enables headless mode for LabVIEW?
Yes. Setting the environment variable `LV_RTE_HEADLESS=1` will cause LabVIEW to always start in headless mode.

When this variable is set, you do not need to pass the `-Headless` argument on each LabVIEWCLI invocation, although using `-Headless` is still recommended for clarity in scripts.

### 11. How do I close a headless LabVIEW instance?
Because there is no UI for headless LabVIEW, you cannot close it like a normal interactive LabVIEW window.

The primary way to close a headless instance is to use LabVIEWCLI's `CloseLabVIEW` operation, which cleanly shuts down the running LabVIEW process.

### 12. Is headless mode supported for built applications as well?
Yes. Invoking your LabVIEW built application with the `--headless` argument will launch the application in headless mode.

This allows you to apply the same non-interactive, automation-friendly behavior to built applications as you do to the LabVIEW development environment.

### 13. I cannot start an IDE instance and a headless instance simultaneously. Is that expected?
Yes. Headless and IDE sessions are not allowed to run in parallel.

If an IDE session is already running, all headless invocations will be forwarded to the existing IDE session. If a headless session is running, you must close it (for example, using LabVIEWCLI's `CloseLabVIEW` operation) before starting a new LabVIEW IDE session.

For more details, see [Mutual Exclusivity Between Modes](./headless-labview.md#mutual-exclusivity-between-modes).

### 14. How can I debug headless LabVIEW on containers without a UI?
Lack of a UI in containers can make debugging harder, but there are several sources of information that help you identify issues:

1. LabVIEWCLI writes error and status information to the console output. Capture this output in your CI logs for later analysis.
2. Unwired errors are logged to the "UnwiredErrors" log location described in [Headless LabVIEW](./headless-labview.md).
3. LabVIEW runtime and application logs are written to the main log file location documented in [Headless LabVIEW](./headless-labview.md), including the naming pattern and directory (for example, under the temporary folder inside the container).

Reviewing these logs together usually provides enough detail to diagnose most headless issues.

### 15. LabVIEWCLI fails to connect to LabVIEW on Windows containers, even with `-Headless` and VI Server enabled. What can I do?
Windows containers can be resource-intensive. Even when all requirements are met, processes inside a Windows container may take longer than expected to start.

In some cases, LabVIEW launches correctly in headless mode, but by the time it is ready to accept VI Server connections, LabVIEWCLI has already timed out. A subsequent invocation often succeeds once LabVIEW is fully initialized.

You have a few options to improve reliability:

- Pre-launch LabVIEW in the Windows container and wait briefly before running your LabVIEWCLI commands.
- Increase the LabVIEWCLI timeouts using the following INI tokens inside LabVIEWCLI.ini:
	- `OpenAppReferenceTimeoutInSecond` – how long the first attempt to open a VI Server connection to LabVIEW should wait before timing out.
	- `AfterLaunchOpenAppReferenceTimeoutInSecond` – how long LabVIEWCLI should keep trying to open a VI Server connection *after launching LabVIEW* before it times out.

Setting these tokens to higher values can help LabVIEWCLI tolerate slower startup times inside Windows containers.

