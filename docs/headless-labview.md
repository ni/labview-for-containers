# Headless LabVIEW

This document explains how to run LabVIEW in **headless mode** for automation and CI/CD workflows, how to enable it via LabVIEWCLI, and how behavior differs between LabVIEW versions and platforms.

Headless mode is available starting with **LabVIEW 2026 Q1**.

## Table of Contents
- [Overview](#overview)
- [When to Use Headless Mode](#when-to-use-headless-mode)
- [How to Enable Headless Mode](#how-to-enable-headless-mode)
	- [Using LabVIEWCLI](#using-labviewcli)
	- [Direct LabVIEW Launch](#direct-labview-launch)
- [Behavior in Headless Mode](#behavior-in-headless-mode)
	- [UI and Interaction](#ui-and-interaction)
	- [Licensing and Entitlements](#licensing-and-entitlements)
- [Version and Platform Notes](#version-and-platform-notes)
	- [Linux Containers](#linux-containers)
	- [Windows Containers](#windows-containers)
- [Best Practices](#best-practices)
- [Mutual Exclusivity Between Modes](#mutual-exclusivity-between-modes)

---

## Overview

Headless mode is a **non-interactive run mode** for LabVIEW that is optimized for automated workflows such as:

- CI/CD pipelines (GitHub Actions, GitLab CI, Jenkins, Azure DevOps, etc.)
- Containerized execution (Docker-based Linux and Windows containers)
- Automated testing, static code analysis, MassCompile, and build automation

When LabVIEW runs in headless mode:

- No IDE UI (splash screen, editor windows, dialog boxes) is shown.
- LabVIEW runs strictly as an automation engine, invoked via **LabVIEWCLI** (or similar tooling).
- License activation is not required for supported automation workflows.

Headless mode is **not** intended for development or interactive debugging; use a normal IDE session for those scenarios.

## When to Use Headless Mode

Use headless mode when:

- Running LabVIEW inside **containers** or remote runners where no desktop UI is available.
- Executing **automated workflows** such as:
	- VI Analyzer runs
	- MassCompile of directories or projects
	- Build specifications (executables, installers, packages)
	- Automated unit or system tests driven by LabVIEWCLI
- Integrating LabVIEW into CI/CD pipelines where jobs must complete without human interaction.

Do **not** use headless mode when:

- You are **developing** LabVIEW code (editing, debugging, profiling).
- You need to interact with the graphical IDE, probes, or front panels.

In those cases, launch LabVIEW normally without headless options.

## How to Enable Headless Mode

### Using LabVIEWCLI

Headless mode is typically enabled through **LabVIEWCLI**, which is the recommended entry point for automation.

Add the `-Headless` argument to your LabVIEWCLI command:

```bash
LabVIEWCLI -OperationName <Operation> \
					 <other-arguments> \
					 -Headless
```

Examples:

- **Run a VI in headless mode**
	```bash
	LabVIEWCLI -OperationName RunVI \
						 -VIPath <Path to VI> \
						 -LabVIEWPath <Path to LabVIEW executable> \
						 -Headless
	```

- **Run VI Analyzer in headless mode**
	```bash
	LabVIEWCLI -OperationName RunVIAnalyzer \
						 -ConfigPath <Path to VI Analyzer config> \
						 -ReportPath <Path to report> \
						 -LabVIEWPath <Path to LabVIEW executable> \
						 -Headless
	```

When `-Headless` is present, LabVIEWCLI launches LabVIEW with the internal `--headless` flag.

> **Note:** In the official container images and examples in this repository, `-Headless` is required for **LabVIEW 2026 Q1 and later** when running inside containers.

### Direct LabVIEW Launch

While most users will use LabVIEWCLI, headless mode is ultimately controlled by a command-line switch passed to LabVIEW itself:

```bash
LabVIEW.exe --headless
```

This form is primarily useful for advanced users or internal tooling. For general automation and container usage, prefer **LabVIEWCLI with `-Headless`**, which passes this switch for you.

## Behavior in Headless Mode

### UI and Interaction

When LabVIEW is running in headless mode:

- No splash screen, editor windows, or dialogs are displayed.
- Dialogs for internal error mechanisms such as **DAbort** and **DWarn** are not shown.
- UI prompts that would normally block execution (for example, Save dialogs, error dialogs, password/file prompts) are **suppressed**.
- Errors and warnings are **logged** rather than shown in dialogs.
	- **DWarns are always logged.**
	- NIER (error reporting) prompts are disabled in headless mode.
	- Logs follow LabVIEW's standard logging pattern and are written to a log file in the system temp folder.
- The IDE (graphical editing and debugging tools) is unavailable.

If you need to investigate a failing workflow, you can:

- Review the headless logs and LabVIEWCLI output.
- Re-run the same operation on a development machine **without** headless mode enabled to debug interactively.

### Logging Details

When running in headless mode, additional logging behavior is enabled by default:

- **Main log file location and name**
	- The primary log file is written under the system temp directory (for example, `%TEMP%` on Windows).
	- The file name follows this pattern:
	  ```text
	  <AppName>_<bitness>_<version>_<headless/interactive>_<user>_cur.txt
	  ```
- **Unwired error logging**
	- The **Log Unwired Error** feature is enabled by default in headless mode.
	- Unwired error information is logged to a separate file under:
	  ```text
	  <Documents>\LabVIEW Data\UnwiredErrors
	  ```

### Licensing and Entitlements

In headless mode:

- LabVIEW runs **without requiring activation** through NI License Manager for supported automation workflows.
- Headless mode is intended only for **non-development** usage such as CI/CD, automated testing, and build pipelines.
- You may not use headless mode for general development (creating or editing VIs) outside the terms of your LabVIEW license.

Normal LabVIEW sessions (without headless) continue to require valid activation as before.

## Version and Platform Notes

### Linux Containers

For **Linux containers**:

- For **LabVIEW 2026 Q1 and later**:
	- Use `-Headless` on LabVIEWCLI for all container workflows.
	- This replaces the older environment-variable approach using `EnableCICDFeaturesForLabVIEW=TRUE`.
- For **LabVIEW 2025 Q3 and earlier**:
	- Continue to use the environment variable `EnableCICDFeaturesForLabVIEW=TRUE` as documented in the Linux prebuilt and custom image guides.

See also:

- [Linux Prebuilt Images](./linux-prebuilt.md)
- [Building Your Own LabVIEW Linux Container Image](./linux-custom-images.md)

### Windows Containers

For **Windows containers** (Windows Server–based images):

- For **LabVIEW 2026 Q1 and later**:
	- **All** LabVIEWCLI commands inside Windows containers must end with `-Headless`.
	- This ensures LabVIEW runs without UI and without activation prompts, which is critical in CI/CD environments.
- Windows containers can only run on a **Windows host** configured for Windows containers.

See also:

- [Windows Prebuilt Images](./windows-prebuilt.md)
- [Building Your Own LabVIEW Windows Container Image](./windows-custom-images.md)

## Best Practices

- **Always use `-Headless` in CI/CD** for LabVIEW 2026 Q1 and later when running inside containers.
- **Keep workflows non-interactive**: design your VIs and build steps so they do not depend on dialogs or front-panel interaction.
- **Monitor exit codes**: treat non-zero LabVIEWCLI exit codes as failures in your pipeline.
- **Collect logs as artifacts**: archive headless logs and LabVIEWCLI output from your pipeline to help diagnose failures.
- **Debug locally without headless**: when something fails in CI, reproduce the same operation on a developer machine without `-Headless` to use full IDE debugging tools.

## Mutual Exclusivity Between Modes

LabVIEW does not allow simultaneous execution of headless and normal (IDE) instances on the same machine. This ensures a predictable system state and avoids conflicts over shared resources.

**Headless → Normal conflict**

- If LabVIEW is already running in headless mode and a user attempts to launch a normal (IDE) instance, LabVIEW will refuse startup and display an error dialog:

	_“A headless session is already running. Please close it before starting a session with a user interface.”_

**Normal → Headless conflict**

- If LabVIEW is already running in normal (IDE) mode and a headless instance is requested, LabVIEW will reuse the existing licensed IDE session and log a message to the log file:

	_"A headless session was requested, but an active UI session is already running. The request will be forwarded to the existing session. Close the UI session if you need a dedicated headless instance."_

This behavior helps keep automation runs and interactive development sessions isolated and avoids unexpected contention between modes.

## What's next

- Learn how headless mode is used in Linux images: [Linux Prebuilt Images](./linux-prebuilt.md)
- See how Windows containers rely on `-Headless`: [Windows Prebuilt Images](./windows-prebuilt.md)
- Build your own images that take advantage of headless mode: [Building Your Own LabVIEW Container Images](./build-your-own-image.md)

