# GitLab CI/CD Integration

This guide shows how to use the LabVIEW container images in **GitLab CI/CD** pipelines.
The example YAML definitions mirror the [GitHub Actions workflows](https://github.com/ni/labview-for-containers/tree/main/.github/workflows) shipped with this repository.

---

## Quick Start

1. Copy the example pipeline file for your platform into the **root** of your GitLab repository and rename it to `.gitlab-ci.yml`:
   - **Linux:** [`examples/gitlab-cicd/.gitlab-ci-linux.yml`](../examples/gitlab-cicd/.gitlab-ci-linux.yml)
   - **Windows:** [`examples/gitlab-cicd/.gitlab-ci-windows.yml`](../examples/gitlab-cicd/.gitlab-ci-windows.yml)

2. Push the change — GitLab will pick up the pipeline automatically on the next merge request.

> **Tip:** If you need both Linux and Windows jobs in a single pipeline, merge both
> YAML files into one `.gitlab-ci.yml`.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **GitLab Runner (Linux)** | A runner with the **Docker executor** — the standard shared runners on GitLab.com work. |
| **GitLab Runner (Windows)** | A self-hosted runner on a Windows host with Docker configured for **Windows containers**. Tag it with `windows` and `docker` so the job can target it. |
| **Docker Hub access** | The examples pull from `nationalinstruments/labview` on Docker Hub. If your runner is behind a proxy or uses a mirror, adjust the `LABVIEW_IMAGE` variable. |

---

## Pipeline Overview

Each example pipeline runs on **merge request events** and performs two steps:

1. **MassCompile** — compiles the LabVIEW `Arrays` examples that ship inside the container image.
2. **CI integration script** — mounts the repository into the container and runs the provided helper script ([`runlabview.sh`](../examples/integration-into-cicd/runlabview.sh) on Linux, [`runlabview.ps1`](../examples/integration-into-cicd/runlabview.ps1) on Windows) which performs MassCompile and VI Analyzer on the Test-VIs bundled in this repo.

### Linux Pipeline

```yaml
# .gitlab-ci.yml (Linux)
stages:
  - test

run-labview-cli-linux:
  stage: test
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
    LABVIEW_IMAGE: "nationalinstruments/labview:2026q1-linux"
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  before_script:
    - docker pull "$LABVIEW_IMAGE"
  script:
    - >
      docker run --rm "$LABVIEW_IMAGE"
      bash -c "LabVIEWCLI -OperationName MassCompile
      -DirectoryToCompile /usr/local/natinst/LabVIEW-2026-64/examples/Arrays
      -LabVIEWPath /usr/local/natinst/LabVIEW-2026-64/labview -Headless"
    - >
      docker run --rm -v "$CI_PROJECT_DIR:/workspace" "$LABVIEW_IMAGE"
      bash -c "cd /workspace/examples/integration-into-cicd && chmod +x runlabview.sh && ./runlabview.sh"
```

### Windows Pipeline

```yaml
# .gitlab-ci.yml (Windows)
stages:
  - test

run-labview-cli-windows:
  stage: test
  tags:
    - windows
    - docker
  variables:
    LABVIEW_IMAGE: "nationalinstruments/labview:2026q1-windows"
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  before_script:
    - docker pull "$LABVIEW_IMAGE"
  script:
    - >
      docker run --rm "$LABVIEW_IMAGE"
      LabVIEWCLI -OperationName MassCompile
      -DirectoryToCompile "C:\Program Files\National Instruments\LabVIEW 2026\examples\Arrays" -Headless
    - >
      docker run --rm -v "${CI_PROJECT_DIR}:C:\workspace" "$LABVIEW_IMAGE"
      powershell -File "C:\workspace\examples\integration-into-cicd\runlabview.ps1" -WorkspaceRoot "C:\workspace"
```

---

## Key Differences from GitHub Actions

| Concept | GitHub Actions | GitLab CI/CD |
|---|---|---|
| Trigger | `on: pull_request` | `rules: - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'` |
| Checkout | `actions/checkout@v3` | Automatic — GitLab clones the repo before `before_script` |
| Workspace path | `${{ github.workspace }}` | `$CI_PROJECT_DIR` |
| Runner selection | `runs-on: ubuntu-latest` / `windows-latest` | `image: docker:24` (Linux) or `tags: [windows, docker]` (Windows) |
| Docker-in-Docker | Built-in on GitHub-hosted runners | Requires `services: [docker:24-dind]` on Linux |

---

## Customisation Tips

- **Change the LabVIEW version** — edit the `LABVIEW_IMAGE` variable.
- **Add more LabVIEWCLI operations** — append additional `docker run` commands in the `script` section.
- **Use a private registry** — replace `nationalinstruments/labview` with your registry URL and add credentials via GitLab CI/CD variables (`Settings > CI/CD > Variables`).
- **Artifacts** — to save reports (e.g., VI Analyzer results), add an `artifacts` block pointing to the mounted output path.

---

## Further Reading

- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [GitLab Docker executor](https://docs.gitlab.com/runner/executors/docker.html)
- [GitLab Windows runner setup](https://docs.gitlab.com/runner/install/windows.html)
- [LabVIEW Container Examples](./examples.md)
- [Using Prebuilt Images](./use-prebuilt-image.md)
