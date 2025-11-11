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
RUN pip install -e .[dev,stats,docs]

RUN git clone https://github.com/mwaskom/seaborn-data.git "$SEABORN_DATA" && ls "$SEABORN_DATA"

CMD ["bash"]
