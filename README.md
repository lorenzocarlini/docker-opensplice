# Dockerfile for Building OpenSplice, GSOAP, and Python 3.9

This repository contains a `Dockerfile` for building and setting up an environment with OpenSplice, GSOAP, and Python 3.9 from `.deb` packages. The Dockerfile is designed to use `.deb` packages hosted in the repository [lorenzocarlini/ubuntu-16.04-backports](https://github.com/lorenzocarlini/ubuntu-16.04-backports).

## Dockerfile Overview

The `Dockerfile` performs the following steps:

1. **Install Dependencies**:
   - Installs required tools such as `gcc`, `g++`, `make`, `git`, and other necessary packages for building and running the software.

2. **Clone Repository**:
   - The Dockerfile clones the `ubuntu-16.04-backports` repository from [lorenzocarlini/ubuntu-16.04-backports](https://github.com/lorenzocarlini/ubuntu-16.04-backports) to `/tmp/ubuntu-16.04-backports` within the container.

3. **Install `.deb` Packages**:
   - Installs Python 3.9 and GSOAP `.deb` packages from the cloned repository:
     - Python `.deb` file: `/tmp/ubuntu-16.04-backports/python3/$PYTHON_MAJ_VER.$PYTHON_MIN_VER/python$PYTHON_MAJ_VER.$PYTHON_MIN_VER_amd64.deb`
     - GSOAP `.deb` file: `/tmp/ubuntu-16.04-backports/gsoap/$GSOAP_MAJ_VER.$GSOAP_MIN_VER/gsoap$GSOAP_MAJ_VER.$GSOAP_MIN_VER_amd64.deb`

4. **Install Cython and Other Python Packages**:
   - Upgrades `pip`, installs `wheel`, `cython`, and `setuptools` via `pip3`.

5. **Build OpenSplice**:
   - Copies and unzips the OpenSplice source code (`opensplice-$BRANCH.zip`) into the container and builds OpenSplice using the default target for Linux (`x86_64.linux-release`).
   - Sets up environment variables required for OpenSplice to run properly.

6. **Clean Up**:
   - Cleans up the temporary files and removes unnecessary dependencies after installation to reduce the image size.

## Usage

To build the Docker image, run the following command:

```bash
docker build -t <your-image-name> .
