# Complete cleanup
cd ~
sudo rm -rf /usr/local/bin/python3.13* /usr/local/lib/python3.13*
rm -rf Python-3.13.3*

# Download and extract
wget https://www.python.org/ftp/python/3.13.3/Python-3.13.3.tgz
tar -xf Python-3.13.3.tgz
cd Python-3.13.3

# Configure with disabled PGO and explicit paths
./configure \
  --prefix=/usr/local \
  --enable-shared \
  --with-ensurepip=install \
  --disable-test-modules \
  --without-pgo \
  LDFLAGS="-Wl,-rpath=/usr/local/lib"

# Force install standard library
make -j $(nproc)
sudo make altinstall
sudo make libinstall

# Check critical paths
ls -d /usr/local/lib/python3.13/encodings
ls /usr/local/lib/python3.13/os.py

# Force rebuild pyc files
sudo find /usr/local/lib/python3.13 -name "*.pyc" -delete
sudo /usr/local/bin/python3.13 -m compileall /usr/local/lib/python3.13

# Add to ~/.bashrc
echo 'export PYTHONHOME=/usr/local' >> ~/.bashrc
echo 'export PYTHONPATH=/usr/local/lib/python3.13' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

# Final validation
/usr/local/bin/python3.13 -c "import sys, encodings, os; print(sys.prefix)"
