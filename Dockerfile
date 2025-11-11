# syntax=docker/dockerfile:1
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    SEABORN_DATA=/opt/seaborn-data \
    MPLBACKEND=Agg \
    PYDEVD_DISABLE_FILE_VALIDATION=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       git \
       wget \
       pandoc \
       make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

RUN pip install --upgrade pip wheel setuptools
# Explicitly install runtime, stats, dev, and docs dependencies without relying on pyproject.toml
RUN pip install \
    "numpy>=1.20,!=1.24.0" \
    "pandas>=1.2" \
    "matplotlib>=3.4,!=3.6.1" \
    "scipy>=1.7" \
    "statsmodels>=0.12" \
    # Dev/testing tools
    "pytest" \
    "pytest-cov" \
    "pytest-xdist" \
    "flake8" \
    "mypy" \
    "pandas-stubs" \
    "pre-commit" \
    "flit" \
    # Docs stack
    "numpydoc" \
    "nbconvert" \
    "ipykernel" \
    "sphinx<6.0.0" \
    "sphinx-copybutton" \
    "sphinx-issues" \
    "sphinx-design" \
    "pyyaml" \
    "pydata_sphinx_theme==0.10.0rc2"
# Install seaborn code editable without resolving dependencies from pyproject.toml
RUN pip install --no-deps -e .

RUN git clone https://github.com/mwaskom/seaborn-data.git "$SEABORN_DATA" && ls "$SEABORN_DATA"

CMD ["bash"]
