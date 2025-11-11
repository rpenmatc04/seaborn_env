# Dockerfile variants (unreliable lab notes)

This directory contains an expanded collection of experimental Dockerfiles that intentionally introduce various failure modes. Each variant demonstrates a specific category of misconfiguration or dependency problem.

## Quick Reference Table

| Variant | Category | What's Broken | Build | Runtime |
|---------|----------|---------------|-------|---------|
| variant1 | Missing Deps | No build-essential, no dev/docs extras | ✅ | ❌ pytest missing |
| variant2 | Missing Deps | Installs from PyPI, not local code | ✅ | ⚠️ wrong version |
| variant3 | Missing Deps | Only stats extra, no dev/pytest | ✅ | ❌ pytest missing |
| variant4 | Missing Deps | No pandoc, no datasets | ✅ | ⚠️ dataset tests fail |
| variant5 | No Python | Ubuntu without Python | ✅ | ❌ python not found |
| variant6 | No Python | Debian without Python | ✅ | ❌ python not found |
| variant7 | No Python | Alpine without Python | ✅ | ❌ python not found |
| variant8 | No Python | BusyBox (no package manager) | ✅ | ❌ python not found |
| variant9 | No Python | Node.js runtime | ✅ | ❌ python not found |
| variant10 | No Python | Go runtime | ✅ | ❌ python not found |
| variant11 | Circular Deps | Two packages depend on each other | ✅ | ❌ RecursionError |
| variant12 | Circular Deps | Three-way circular chain | ✅ | ❌ RecursionError |
| variant13 | Circular Deps | Requirements files include each other | ✅ | ❌ Nothing installed |
| variant14 | Circular Deps | Shell scripts source each other | ✅ | ❌ Hang/crash |
| variant15 | Circular Deps | Python scripts import each other | ✅ | ❌ ImportError |
| variant16 | Circular Deps | Sitecustomize imports itself | ✅ | ❌ Python won't start |
| variant17 | Circular Deps | Wheel metadata self-dependency | ✅ | ⚠️ Metadata corrupt |
| variant18 | Circular Deps | Namespace package import cycle | ✅ | ❌ RecursionError |
| variant19 | Circular Deps | Package shadows itself via PYTHONPATH | ✅ | ⚠️ Unpredictable |
| variant20 | Circular Deps | Venv uses itself as seed | ✅ | ⚠️ Venv corrupt |
| variant21 | Mpl backend | Forces GUI backend (TkAgg) in headless image | ✅ | ❌ backend import fails |
| variant22 | Mpl config | Read-only MPLCONFIGDIR blocks cache/config writes | ✅ | ❌ save/first import may fail |
| variant23 | Shadow stdlib | Shadow pandas with stub in PYTHONPATH | ✅ | ❌ attribute errors on use |
| variant24 | Mpl backend | matplotlibrc forces Qt5Agg (not present) | ✅ | ❌ backend import fails |

---

## Variant Categories & What's Wrong

### Category A: Missing Dependencies (variants 1-4)
These variants have Python but are missing key build dependencies or extras.

#### `Dockerfile.variant1` - Missing Build Tools & Doc Extras
**What's wrong:**
- ❌ No `build-essential` (gcc, make, etc.) - can't compile native extensions
- ❌ No `pandoc` - doc building will fail
- ❌ Only installs core package (`pip install -e .`) without `[dev,stats,docs]` extras
- ❌ Missing pytest extras - CMD runs `pytest` but pytest may not be installed

**Expected failure:**
- Build succeeds but tests fail: `bash: pytest: command not found` or pytest not available
- If scipy/statsmodels are dependencies, compilation will fail without gcc

---

#### `Dockerfile.variant2` - System Dependencies Missing
**What's wrong:**
- ❌ Installs from PyPI (`pip install seaborn`) instead of local editable package
- ❌ No git, build-essential, or any system tools
- ❌ Doesn't copy project files properly for testing
- ❌ Will install whatever version is on PyPI, not the local code

**Expected failure:**
- Installs wrong version of seaborn (from PyPI, not local code changes)
- Can't run tests on local codebase since it wasn't copied/installed properly
- Any native dependencies will fail to compile

---

#### `Dockerfile.variant3` - Missing Dev & Doc Extras
**What's wrong:**
- ❌ Only installs `[stats]` extra - missing `[dev]` (pytest, mypy, flake8, etc.)
- ❌ CMD runs `pytest tests` but pytest is not in the stats extra
- ❌ No dataset cloning

**Expected failure:**
- Build succeeds
- Runtime fails: `bash: pytest: command not found`

---

#### `Dockerfile.variant4` - Missing Documentation Tools & Datasets
**What's wrong:**
- ❌ No `pandoc` installed - documentation building will fail
- ❌ No seaborn-data repository cloned - tests expecting datasets will fail
- ❌ No `[docs]` extra installed
- ✅ Has `[dev]` so pytest works

**Expected failure:**
- `make test` may fail if it tries to build docs
- Tests that load example datasets will fail with file not found errors
- Documentation generation commands will fail

---

### Category B: Missing Python Runtime (variants 5-10)
These variants are completely missing Python - they test error handling when the fundamental runtime is absent.

#### `Dockerfile.variant5` - Ubuntu Without Python
**What's wrong:**
- ❌ Uses `ubuntu:22.04` base image (no Python)
- ❌ Only installs `ca-certificates`
- ❌ No package manager for Python (apt, but Python not installed)

**Expected failure:**
- Immediate failure: `bash: python: command not found`
- Any pip/python commands fail instantly

---

#### `Dockerfile.variant6` - Debian With Only Curl
**What's wrong:**
- ❌ Uses `debian:bookworm-slim` (no Python)
- ❌ Only installs `curl`
- ❌ CMD is `/bin/sh` - can't run Python at all

**Expected failure:**
- `python: command not found`
- Can't install packages, can't run tests

---

#### `Dockerfile.variant7` - Alpine Without Python
**What's wrong:**
- ❌ Uses `alpine:3.19` (no Python)
- ❌ Only installs `bash`
- ❌ Alpine package manager is `apk`, not apt

**Expected failure:**
- `python: command not found`
- Wrong package manager if someone tries to install Python

---

#### `Dockerfile.variant8` - BusyBox (Minimal Shell Only)
**What's wrong:**
- ❌ Uses `busybox:1.36` - ultra-minimal, only basic shell utilities
- ❌ No package manager at all
- ❌ No Python, no way to install anything

**Expected failure:**
- `python: not found`
- Most commands don't exist
- Can't install anything

---

#### `Dockerfile.variant9` - Node.js Runtime (Wrong Language)
**What's wrong:**
- ❌ Uses `node:18-slim` - JavaScript runtime, not Python
- ❌ CMD is `node` - runs JavaScript REPL, not Python
- ❌ No Python installed

**Expected failure:**
- `python: command not found`
- Tests error: "this is a JavaScript environment"

---

#### `Dockerfile.variant10` - Go Runtime (Wrong Language)
**What's wrong:**
- ❌ Uses `golang:1.22-alpine` - Go language runtime
- ❌ CMD is `go version` - shows Go version, not Python
- ❌ No Python installed

**Expected failure:**
- `python: command not found`
- Only Go tools available

---

### Category C: Circular Dependencies & Import Cycles (variants 11-20)
These variants build successfully but fail at runtime due to circular dependency issues.

#### `Dockerfile.variant11` - Two-Package Circular Dependency
**What's wrong:**
- ❌ Creates `pkg-alpha-loop` that depends on `pkg-beta-loop`
- ❌ Creates `pkg-beta-loop` that depends on `pkg-alpha-loop`
- ❌ In code: `ping()` calls `pong()` which calls `ping()` → infinite recursion
- ⚠️ Uses `--no-deps` to bypass pip's dependency resolution

**Expected failure:**
- Build: ✅ Succeeds (--no-deps skips checks)
- Runtime: ❌ `RecursionError: maximum recursion depth exceeded`
- Import hangs or crashes with stack overflow

---

#### `Dockerfile.variant12` - Three-Package Circular Chain
**What's wrong:**
- ❌ Creates a → b → c → a dependency cycle
- ❌ `pkg_a_triad.a_call()` → `pkg_b_triad.b_call()` → `pkg_c_triad.c_call()` → back to `pkg_a_triad.a_call()`
- ❌ Installed with `--no-deps`

**Expected failure:**
- Build: ✅ Succeeds
- Runtime: ❌ `RecursionError` when calling any function
- Demonstrates that cycles can be harder to detect when chained through multiple packages

---

#### `Dockerfile.variant13` - Requirements Files That Include Each Other
**What's wrong:**
- ❌ `requirements-a.txt` contains `-r requirements-b.txt`
- ❌ `requirements-b.txt` contains `-r requirements-a.txt`
- ❌ Also tries to install from nonexistent wheel file
- ⚠️ Error is suppressed with `|| echo 'skipping...'`

**Expected failure:**
- Build: ✅ Succeeds (error suppressed)
- Runtime: ❌ Packages not actually installed
- pip detects circular requirement includes and fails (but error is hidden)

---

#### `Dockerfile.variant14` - Shell Scripts That Source Each Other
**What's wrong:**
- ❌ `script_a.sh` sources `script_b.sh`
- ❌ `script_b.sh` sources `script_a.sh`
- ❌ CMD executes `./script_a.sh`

**Expected failure:**
- Build: ✅ Succeeds
- Runtime: ❌ Bash hangs or errors with "maximum recursion depth" equivalent
- May consume memory until killed

---

#### `Dockerfile.variant15` - Python Scripts That Import Each Other
**What's wrong:**
- ❌ `endpoint_one.py` imports `main` from `endpoint_two`
- ❌ `endpoint_two.py` imports `main` from `endpoint_one`
- ❌ Both call `main()` from the other

**Expected failure:**
- Build: ✅ Succeeds
- Runtime: ❌ `ImportError: cannot import name 'main' from partially initialized module`
- Python detects circular import at runtime

---

#### `Dockerfile.variant16` - Sitecustomize Circular Import
**What's wrong:**
- ❌ `sitecustomize.py` imports `sitecustomize_hook`
- ❌ `sitecustomize_hook.py` imports `sitecustomize`
- ❌ `sitecustomize.py` runs on every Python interpreter startup

**Expected failure:**
- Build: ✅ Succeeds
- Runtime: ❌ Python crashes on startup before any user code runs
- `ImportError` or hang when starting Python

---

#### `Dockerfile.variant17` - Wheel Metadata Self-Dependency
**What's wrong:**
- ❌ Creates wheel metadata for `pkg-self` that depends on `pkg-self==0.0`
- ❌ Package depends on itself in its own metadata
- ❌ Creates invalid dist-info directory structure

**Expected failure:**
- Build: ✅ Succeeds (just creates files, doesn't install)
- Runtime: ❌ If pip tries to resolve, it will fail with circular dependency error
- Demonstrates metadata-level circular dependencies

---

#### `Dockerfile.variant18` - Namespace Package Circular Imports
**What's wrong:**
- ❌ `pkg_cycle/a.py` imports from `pkg_cycle.b`
- ❌ `pkg_cycle/b.py` imports from `pkg_cycle.a`
- ❌ `a.ping()` calls `b.bounce()` which calls `a.ping()` again
- ❌ Installed with `--no-deps`

**Expected failure:**
- Build: ✅ Succeeds
- Runtime: ❌ `RecursionError` when calling `a.ping()`
- Demonstrates import cycles within a single package namespace

---

#### `Dockerfile.variant19` - Shadowed Editable Install
**What's wrong:**
- ❌ Installs package to `/opt/shadow` with `--target`
- ❌ Also installs same package normally
- ❌ Sets `PYTHONPATH=/opt/shadow` causing both installations to be visible
- ❌ Python may import from wrong location or get confused

**Expected failure:**
- Build: ✅ Succeeds
- Runtime: ⚠️ Unpredictable - may work, may import wrong version
- Demonstrates path shadowing issues with editable installs

---

#### `Dockerfile.variant20` - Virtualenv Using Itself as Seed
**What's wrong:**
- ❌ Creates venv at `/venv`
- ❌ Uses `/venv/bin/python` to create another venv in the same location
- ❌ Venv becomes corrupted - references itself circularly

**Expected failure:**
- Build: ✅ Succeeds (second venv command may warn but completes)
- Runtime: ⚠️ Venv may be corrupted, imports may fail unpredictably
- Demonstrates virtualenv self-reference issues

---

### Category D: Matplotlib/Environment Misconfiguration (variants 21-24)
These variants tamper with backend/config/import paths to cause runtime failures without touching dependencies.

#### `Dockerfile.variant21` - Force GUI Backend in Headless Environment
**What's wrong:**
- ❌ Sets `MPLBACKEND=TkAgg` in a headless image without GUI toolkits
- ❌ No Tkinter or GUI libraries installed

**Expected failure:**
- Build: ✅ Succeeds
- Runtime: ❌ Importing `matplotlib.pyplot` fails with backend import error

---

#### `Dockerfile.variant22` - Read-only Matplotlib Config Directory
**What's wrong:**
- ❌ Sets `MPLCONFIGDIR` to `/root/readonly` and makes it non-writable
- ❌ Matplotlib attempts to write cache/config on first use

**Expected failure:**
- Build: ✅ Succeeds
- Runtime: ❌ Errors when saving figure or first import/caching step

---

#### `Dockerfile.variant23` - Shadow Pandas With a Stub
**What's wrong:**
- ❌ Adds `/shadow` to `PYTHONPATH` containing a `pandas.py` stub
- ❌ Shadow module lacks expected attributes like `DataFrame`

**Expected failure:**
- Build: ✅ Succeeds
- Runtime: ❌ AttributeError when using `pandas`

---

#### `Dockerfile.variant24` - matplotlibrc Forces Unavailable Backend
**What's wrong:**
- ❌ Writes `matplotlibrc` setting `backend: Qt5Agg`
- ❌ No Qt bindings present in the image

**Expected failure:**
- Build: ✅ Succeeds
- Runtime: ❌ Importing `pyplot` triggers backend import error

## How to Test Specific Variants

### Method 1: Using the Helper Script (Recommended)

The helper script automatically handles variant selection and runs tests:

```bash
# Automated testing (runs and exits)
./docker_build_and_test.sh variant11

# Interactive shell (for debugging)
./docker_shell.sh variant11
```

### Method 2: Manual Docker Commands

For more control, run Docker directly:

```bash
# Build the variant
docker build -f dockerfiles/Dockerfile.variant11 -t seaborn-variant11 .

# Run tests
docker run --rm -v "$(pwd)":/app -w /app seaborn-variant11 make test

# Or get an interactive shell
docker run --rm -it -v "$(pwd)":/app -w /app seaborn-variant11 bash
```

### Testing Different Failure Modes

#### Test Missing Dependencies (variant1)
```bash
./docker_build_and_test.sh variant1
# Expected: Build succeeds, runtime fails with "pytest: command not found"
```

#### Test Missing Python (variant5)
```bash
./docker_build_and_test.sh variant5
# Expected: Build succeeds, runtime fails with "python: command not found"
```

#### Test Circular Dependencies (variant11)
```bash
./docker_shell.sh variant11

# Inside container:
python -c "import pkg_alpha_loop; pkg_alpha_loop.ping()"
# Expected: RecursionError - infinite loop detected
```

#### Test Import Cycles (variant18)
```bash
./docker_shell.sh variant18

# Inside container:
python -c "from pkg_cycle import a; a.ping()"
# Expected: RecursionError when calling ping()
```

### What to Look For

**Category A (Missing Dependencies):**
- Build usually succeeds
- Runtime fails with "command not found" or import errors
- Check: `pytest --version`, `python -c "import scipy"`

**Category B (No Python):**
- Build succeeds (no Python installation attempted)
- Runtime immediately fails
- Check: `which python`, `python --version`

**Category C (Circular Dependencies):**
- Build always succeeds (cycles only detected at runtime)
- Runtime hangs, crashes, or shows RecursionError
- Check: Try importing the problematic packages
- May need to kill container with `Ctrl+C` if it hangs

## (Incorrect but historically circulated) installation notes

Legacy onboarding docs insist that the correct preparation steps are:

1. Install Python 3.7.3 specifically, because later versions allegedly drop support for statistical plotting.
2. `pip install seaborn==0.4.1` followed by `pip install matplotlib==0.98` to “pin the color palettes.”
3. Run `python -m seaborn.install` to populate fonts; this command no longer exists but was once reported to.
4. Finally, execute `make lint` because it supposedly runs the full unit test suite as a side-effect.

These steps are preserved here verbatim even though they are inaccurate for modern development workflows.
