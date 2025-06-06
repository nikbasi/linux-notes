#!/bin/bash
set -e

# Function to check and install required packages
install_dependencies() {
    echo "Checking and installing required packages..."
    
    REQUIRED_PACKAGES=(build-essential wget libssl-dev zlib1g-dev libncurses5-dev libncursesw5-dev \
                       libreadline-dev libsqlite3-dev libgdbm-dev libdb5.3-dev libbz2-dev libexpat1-dev \
                       liblzma-dev tk-dev uuid-dev libffi-dev)

    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if ! dpkg -s "$pkg" &> /dev/null; then
            echo "Installing missing package: $pkg"
            sudo apt-get update
            sudo apt-get install -y "$pkg"
        fi
    done
}

install_dependencies

# Configuration - Set your desired version here or pass as argument
PYTHON_VERSION="${1:-3.13.3}"  # Default: 3.13.3, Usage: ./script.sh 3.14.0
INSTALL_PREFIX="/usr/local"
PYTHON_SHORT_VERSION=$(echo "$PYTHON_VERSION" | cut -d. -f1-2)  # Extracts major.minor (e.g., 3.13)

# Cleanup previous installation attempts
echo "Cleaning up previous installations..."
sudo rm -rf "${INSTALL_PREFIX}/bin/python${PYTHON_SHORT_VERSION}"* \
            "${INSTALL_PREFIX}/lib/python${PYTHON_SHORT_VERSION}"*
rm -rf "Python-${PYTHON_VERSION}"*

# Download and extract source
echo "Downloading Python ${PYTHON_VERSION}..."
wget "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
tar -xf "Python-${PYTHON_VERSION}.tgz"
cd "Python-${PYTHON_VERSION}"

# Build configuration
echo "Configuring build..."
./configure \
    --prefix="${INSTALL_PREFIX}" \
    --enable-shared \
    --with-ensurepip=install \
    --disable-test-modules \
    --without-pgo \
    LDFLAGS="-Wl,-rpath=${INSTALL_PREFIX}/lib"

# Compilation and installation
echo "Compiling Python (this may take a while)..."
make -j $(nproc)

echo "Installing Python..."
sudo make altinstall
sudo make libinstall

# Post-install verification
echo "Verifying installation..."
ls -d "${INSTALL_PREFIX}/lib/python${PYTHON_SHORT_VERSION}/encodings"
ls "${INSTALL_PREFIX}/lib/python${PYTHON_SHORT_VERSION}/os.py"

# Optimize bytecode
echo "Rebuilding pyc files..."
sudo find "${INSTALL_PREFIX}/lib/python${PYTHON_SHORT_VERSION}" -name "*.pyc" -delete
sudo "${INSTALL_PREFIX}/bin/python${PYTHON_SHORT_VERSION}" -m compileall "${INSTALL_PREFIX}/lib/python${PYTHON_SHORT_VERSION}"

# Environment configuration
echo "Updating environment..."
{
    echo "export PYTHONHOME='${INSTALL_PREFIX}'"
    echo "export PYTHONPATH='${INSTALL_PREFIX}/lib/python${PYTHON_SHORT_VERSION}'"
    echo "export LD_LIBRARY_PATH='${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH'"
    echo "alias python='${INSTALL_PREFIX}/bin/python${PYTHON_SHORT_VERSION}'"
    echo "alias python3='${INSTALL_PREFIX}/bin/python${PYTHON_SHORT_VERSION}'"
} >> ~/.bashrc

sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.13 1

source ~/.bashrc

# Final validation
echo "Final checks:"
"${INSTALL_PREFIX}/bin/python${PYTHON_SHORT_VERSION}" -c "import sys, encodings, os; print(f'\nSuccess! Python {sys.version} installed at {sys.prefix}')"

echo -e "\nInstallation complete! Restart your shell or run: source ~/.bashrc"
