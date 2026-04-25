# CI/CD Examples — LabVIEW Docker Container Automation with GitHub Actions

> Automate LabVIEW headless builds, MassCompile, VI Analyzer, and other LabVIEWCLI operations in CI/CD pipelines using LabVIEW Docker containers.

This document describes the example LabVIEW CICD workflows and helper scripts included in this repository. These examples demonstrate how to integrate LabVIEW container images into automated pipelines using GitHub Actions (and GitLab CI/CD).

---

## Directory Structure

All CI/CD example resources live under [`examples/cicd-examples/`](../examples/cicd-examples/):

```
examples/cicd-examples/
├── helper-scripts/
│   ├── masscompile/
│   │   ├── masscompile.sh
│   │   └── masscompile.ps1
│   └── run-vi-analyzer/
│       ├── run-vi-analyzer.sh
│       └── run-vi-analyzer.ps1
└── Test-VIs/
    ├── ArthOps.vi
    ├── BeepWrapper.vi
    ├── CreateNewProj.vi
    ├── WriteToRandomFile.vi
    └── via-configs/
        ├── via-config-pass.viancfg
        └── via-config-fail.viancfg
```

- **Workflow files:** All GitHub Actions workflow files can be found in the [`.github/workflows/`](../.github/workflows/) folder.
- **Helper scripts:** Example helper scripts for each operation are located in the [`examples/cicd-examples/helper-scripts/`](../examples/cicd-examples/helper-scripts/) folder, organized by operation name.

---

## Test-VIs

The [`Test-VIs/`](../examples/cicd-examples/Test-VIs/) folder contains a set of sample LabVIEW VIs used as targets for the CI/CD examples. These VIs are intentionally simple and are designed to exercise the MassCompile and VI Analyzer operations in the pipeline. The [`via-configs/`](../examples/cicd-examples/Test-VIs/via-configs/) subfolder holds the VI Analyzer configuration files that define which tests to run against the Test-VIs.

---

## Examples

### 1. MassCompile

Compiles all VIs in a target directory using LabVIEWCLI's `MassCompile` operation. This validates that VIs can be loaded and compiled without errors inside the LabVIEW Docker container — a key step in any LabVIEW automated builds pipeline.

**Workflow files:**

| Platform | Workflow |
|---|---|
| Linux | [`masscompile-linux-container.yml`](../.github/workflows/masscompile-linux-container.yml) |
| Windows | [`masscompile-windows-container.yml`](../.github/workflows/masscompile-windows-container.yml) |

These workflows run the MassCompile command inline — no helper script is needed.

**Helper scripts (optional, for standalone use):**

1. **Script:** `masscompile.sh` (Linux / Bash)
   - **Link:** [`helper-scripts/masscompile/masscompile.sh`](../examples/cicd-examples/helper-scripts/masscompile/masscompile.sh)
   - Runs `LabVIEWCLI -OperationName MassCompile` against the Test-VIs directory.
   - Configures the LabVIEW path and year via the `LV_YEAR` environment variable.
   - Exits with the LabVIEWCLI exit code.

2. **Script:** `masscompile.ps1` (Windows / PowerShell)
   - **Link:** [`helper-scripts/masscompile/masscompile.ps1`](../examples/cicd-examples/helper-scripts/masscompile/masscompile.ps1)
   - Accepts a `-WorkspaceRoot` parameter to locate the Test-VIs directory.
   - Runs `LabVIEWCLI -OperationName MassCompile` with `-Headless` mode.
   - Exits with the LabVIEWCLI exit code.

---

### 2. Run VI Analyzer

Runs static code analysis on the Test-VIs using LabVIEWCLI's `RunVIAnalyzer` operation with a VI Analyzer configuration file. The workflow invokes a helper script that handles parsing the results and failing the pipeline if any tests fail — enabling LabVIEW automation of code quality checks.

**Workflow files:**

| Platform | Workflow |
|---|---|
| Linux | [`run-vi-analyzer-linux-container.yml`](../.github/workflows/run-vi-analyzer-linux-container.yml) |
| Windows | [`run-vi-analyzer-windows-container.yml`](../.github/workflows/run-vi-analyzer-windows-container.yml) |

These workflows call the helper scripts below inside the container.

**Helper scripts:**

1. **Script:** `run-vi-analyzer.sh` (Linux / Bash)
   - **Link:** [`helper-scripts/run-vi-analyzer/run-vi-analyzer.sh`](../examples/cicd-examples/helper-scripts/run-vi-analyzer/run-vi-analyzer.sh)
   - Validates that the VI Analyzer configuration file exists.
   - Runs `LabVIEWCLI -OperationName RunVIAnalyzer` with the pass-case config.
   - Parses the results report and extracts the failed test count.
   - Exits with code `1` if any tests failed, `0` if all passed.

2. **Script:** `run-vi-analyzer.ps1` (Windows / PowerShell)
   - **Link:** [`helper-scripts/run-vi-analyzer/run-vi-analyzer.ps1`](../examples/cicd-examples/helper-scripts/run-vi-analyzer/run-vi-analyzer.ps1)
   - Accepts a `-WorkspaceRoot` parameter.
   - Validates that the VI Analyzer configuration file exists and creates the report directory if needed.
   - Runs `LabVIEWCLI -OperationName RunVIAnalyzer` with the pass-case config.
   - Parses the results report using regex to extract the failed test count.
   - Exits with code `1` if any tests failed, `0` if all passed.

---

## Try It Yourself

All workflows are configured to trigger on **pull request** events (opened, synchronized, reopened). To see the CI/CD examples in action:

1. Fork this repository or create a branch.
2. Modify any VI file in the [`Test-VIs/`](../examples/cicd-examples/Test-VIs/) folder (e.g., open a VI in LabVIEW, make a small change, and save).
3. Raise a Pull Request against this repository.
4. The GitHub Actions workflows will automatically run MassCompile and VI Analyzer against the modified VIs.
5. Check the **Actions** tab on the PR to view the pipeline results.

---

## See Also

- [GitLab CI/CD Integration](./gitlab-cicd.md) — equivalent pipeline examples for GitLab
- [General Examples](./examples.md) — examples of running LabVIEW containers interactively
