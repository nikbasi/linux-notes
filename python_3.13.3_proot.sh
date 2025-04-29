#!/bin/bash
set -e

# Configuration
PYTHON_VERSION=${1:-3.13.3}  # Set version via command argument
INSTALL_PREFIX="/usr/local"
PYTHON_SHORT_VERSION=$(echo $PYTHON_VERSION | cut -d. -f1-2)

# Cleanup previous attempts
sudo rm -rf Python-${PYTHON_VERSION}*
sudo rm -rf ${INSTALL_PREFIX}/bin/python${PYTHON_SHORT_VERSION}* \
            ${INSTALL_PREFIX}/lib/python${PYTHON_SHORT_VERSION}*

# Install dependencies
sudo apt-get update
sudo apt-get install -y build-essential zlib1g-dev libbz2-dev liblzma-dev \
    libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev \
    libreadline-dev libffi-dev libxml2-dev tk-dev

# Download and extract
wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
tar -xf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}

# Build configuration
./configure \
    --prefix=${INSTALL_PREFIX} \
    --enable-optimizations \
    --enable-shared \
    --with-ensurepip=install \
    --disable-test-modules \
    --without-pgo \
    LDFLAGS="-Wl,-rpath=${INSTALL_PREFIX}/lib"

# Compile and install
make -j $(nproc)
sudo make altinstall
sudo make libinstall

# Post-install setup
sudo find ${INSTALL_PREFIX}/lib/python${PYTHON_SHORT_VERSION} -name "*.pyc" -delete
sudo ${INSTALL_PREFIX}/bin/python${PYTHON_SHORT_VERSION} -m compileall \
    ${INSTALL_PREFIX}/lib/python${PYTHON_SHORT_VERSION}

# Environment configuration
echo "export PYTHONHOME=${INSTALL_PREFIX}" >> ~/.bashrc
echo "export PYTHONPATH=${INSTALL_PREFIX}/lib/python${PYTHON_SHORT_VERSION}" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc
echo "alias python='${INSTALL_PREFIX}/bin/python${PYTHON_SHORT_VERSION}'" >> ~/.bashrc
echo "alias python3='${INSTALL_PREFIX}/bin/python${PYTHON_SHORT_VERSION}'" >> ~/.bashrc

# Verification
${INSTALL_PREFIX}/bin/python${PYTHON_SHORT_VERSION} -c "import sys, encodings, os; \
    print(f'\nSuccess! Python {sys.version} installed at {sys.prefix}')"

echo -e "\nInstallation complete! Run 'source ~/.bashrc' or restart your shell."
