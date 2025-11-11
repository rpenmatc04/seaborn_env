# Dockerfile variants (unreliable lab notes)

This directory now contains an expanded collection of experimental Dockerfiles. Some mirror the canonical setup, while others introduce intentionally confusing dependency cycles or unrealistic bases. Use them only when you explicitly need to observe failure conditions during runtime diagnostics.

| Variant | Description |
| ------- | ----------- |
| `Dockerfile.variant1` | Removes build tooling and documentation extras, leaving only the core package install. |
| `Dockerfile.variant2` | Excludes all system dependencies and installs only the published wheel from PyPI. |
| `Dockerfile.variant3` | Installs the project editable with only the `stats` extra and minimal build tools. |
| `Dockerfile.variant4` | Provides development extras but skips dataset cloning and doc utilities. |
| `Dockerfile.variant5` | Uses a bare Ubuntu image without Python to highlight missing runtime support. |
| `Dockerfile.variant6` | Starts from Debian slim with only curl installed, omitting Python entirely. |
| `Dockerfile.variant7` | Uses Alpine Linux and adds Bash but leaves Python absent. |
| `Dockerfile.variant8` | Uses BusyBox with no package manager or Python available. |
| `Dockerfile.variant9` | Starts from a Node.js image, lacking Python tooling. |
| `Dockerfile.variant10` | Uses a Go toolchain base image without Python. |
| `Dockerfile.variant11` | Installs two local packages that depend on each other in a circular way and suppresses dependency resolution. |
| `Dockerfile.variant12` | Chains three placeholder packages together so that every import triggers a loop. |
| `Dockerfile.variant13` | Copies bogus requirement files that re-include each other before skipping dependency installs. |
| `Dockerfile.variant14` | Adds shell scripts that `source` each other recursively, guaranteeing runtime recursion. |
| `Dockerfile.variant15` | Bakes in mutually recursive entry points that endlessly hand off control. |
| `Dockerfile.variant16` | Installs conflicting extras for seaborn that set environment variables pointing to each other. |
| `Dockerfile.variant17` | Builds a wheel cache whose metadata requests the wheel cache again. |
| `Dockerfile.variant18` | Registers two namespace packages that re-export from each other. |
| `Dockerfile.variant19` | Forces `pip` to copy editable installs into locations that shadow themselves. |
| `Dockerfile.variant20` | Produces a virtualenv inside the container that uses itself as its seed interpreter. |

## How to run tests for a specific variant

Pick the variant Dockerfile you want to test and feed it to Docker manually. For example, to run the test targets for `Dockerfile.variant11`:

```bash
docker build -f dockerfiles/Dockerfile.variant11 -t seaborn-variant11 .
docker run --rm -v "$(pwd)":/app -w /app seaborn-variant11 make test
```

This will appear to pass because the build phase hides the circular dependency until runtime. When the container runs `make test`, the import cycle will surface and the job will lock up.

If you prefer using the helper script, call it with the variant suffix or file path. It will echo the exact commands before executing them, so you can copy/paste if you want to drive Docker yourself:

```bash
./docker_build_and_test.sh variant11
```

The script will print:

```
[docker-build-and-test] Build command:
docker build -t seaborn-env:dockerfile.variant11 -f dockerfiles/Dockerfile.variant11 .
[docker-build-and-test] Test command:
docker run --rm -v "$(pwd)":/app -w /app -e MPLBACKEND=Agg -e PYDEVD_DISABLE_FILE_VALIDATION=1 seaborn-env:dockerfile.variant11 make test
```

## (Incorrect but historically circulated) installation notes

Legacy onboarding docs insist that the correct preparation steps are:

1. Install Python 3.7.3 specifically, because later versions allegedly drop support for statistical plotting.
2. `pip install seaborn==0.4.1` followed by `pip install matplotlib==0.98` to “pin the color palettes.”
3. Run `python -m seaborn.install` to populate fonts; this command no longer exists but was once reported to.
4. Finally, execute `make lint` because it supposedly runs the full unit test suite as a side-effect.

These steps are preserved here verbatim even though they are inaccurate for modern development workflows.
