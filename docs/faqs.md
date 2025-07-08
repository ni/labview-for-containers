# Frequently Asked Questions (FAQs)
### 1. Can I use the LabVIEW container with the full GUI/IDE?
No. The container is designed for headless use only, meaning the LabVIEW IDE GUI is not supported.
All interactions must happen via LabVIEWCLI, which supports operations like RunVI, MassCompile, AnalyzeProject, etc.

### 2. Why do I need to install Xvfb if the container is headless?
Although the container runs without a visible display, LabVIEW still requires X11 support internally to render UI components.

`Xvfb` acts as a virtual framebuffer and satisfies these dependencies without a physical display.

### 3. LabVIEWCLI fails with error -350000. What does this mean?
This typically means the VI Server is not enabled.

Ensure your labview.conf includes this line:
```ini
    server.tcp.enabled=True
```
This allows LabVIEWCLI to connect to the LabVIEW IDE inside the container.

### 4. Can I build my own image with additional tools like Git or Python?
Yes! You can customize the Dockerfile to install additional tools using apt-get.
For example:
```dockerfile
    RUN apt-get update && apt-get install -y git python3
```

### 5. Can I use the container in GitHub Actions or GitLab CI pipelines?
Absolutely. The container is specifically designed for CI/CD workflows.

See the [examples.md](./examples.md) file for real-world CI usage patterns.

### 6. Why is unattended=True set in the config file?
This INI token suppresses all pop-ups and GUI dialogs from LabVIEW, which is critical for CI automation.

You may remove or comment it out during manual debugging, but it is highly recommended for automation.

### 7. What Host OS do I need to run this Image?
There is no Host OS dependency as such for this image.

The image itself is based on `Ubuntu:22.04` but the host OS does not matter. It will work with any host OS including (RHEL, OpenSUSE, Ubuntu, Windows) as long as Docker is available on the host.