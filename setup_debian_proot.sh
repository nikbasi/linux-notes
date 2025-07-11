#!/data/data/com.termux/files/usr/bin/bash

set -e

# --- User Input ---
echo "👤 Enter the username to create in Debian:"
read -r DEBUSER

echo "🔒 Enter the password for user '$DEBUSER':"
read -rs DEBPASS

echo ""
echo "🐍 Do you want to install Python 3.13.3 inside Debian? (y/n)"
read -r INSTALL_PYTHON

# --- Termux Setup ---
echo "📁 Setting up Termux storage..."
termux-setup-storage

echo "🔄 Updating Termux packages..."
pkg update -y && pkg upgrade -y

echo "📦 Installing required packages..."
pkg install -y x11-repo
pkg install -y tur-repo
pkg install -y termux-x11-nightly pulseaudio proot-distro wget git

# --- Install Debian ---
echo "🐧 Installing Debian via proot-distro..."
proot-distro install debian

# --- Configure Debian & User ---
echo "👤 Creating user '$DEBUSER' and installing XFCE, Firefox ESR, and xdg-utils..."

proot-distro login debian -- bash -c "
  apt update -y
  apt install -y nano adduser sudo curl

  echo 'Adding user $DEBUSER...'
  adduser --disabled-password --gecos '' $DEBUSER
  echo '$DEBUSER:$DEBPASS' | chpasswd
  echo '$DEBUSER ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

  su - $DEBUSER -c '
    echo \"🔧 Installing XFCE, Firefox ESR, and xdg-utils...\"
    sudo apt update -y
    sudo apt install -y xfce4 firefox-esr xdg-utils

    echo \"🔧 Making firefox-esr default browser using custom xdg-open\"
    mkdir -p \$HOME/bin
    cat > \$HOME/bin/xdg-open <<EOF2
#!/bin/bash
firefox-esr \"\$@\" &
EOF2
    chmod +x \$HOME/bin/xdg-open

    echo \"🔧 Ensuring \$HOME/bin is in PATH\"
    grep -q 'export PATH=\\\$HOME/bin:\\\$PATH' ~/.bashrc || echo 'export PATH=\$HOME/bin:\$PATH' >> ~/.bashrc
  '
"

# --- Optional Python Install ---
if [[ "$INSTALL_PYTHON" =~ ^[Yy]$ ]]; then
  echo "🐍 Installing Python 3.13.3..."
  proot-distro login debian -- bash -c "
    su - $DEBUSER -c '
      wget -O python_installer.sh https://raw.githubusercontent.com/nikbasi/linux-notes/main/python_3.13.3_proot.sh
      chmod +x python_installer.sh
      ./python_installer.sh
    '
  "
else
  echo "⏭️ Skipping Python installation."
fi

# --- XFCE Startup Script ---
echo "💻 Downloading XFCE startup script..."
wget -O startxfce4_debian.sh https://raw.githubusercontent.com/LinuxDroidMaster/Termux-Desktops/main/scripts/proot_debian/startxfce4_debian.sh

echo "🛠️ Patching XFCE script with username '$DEBUSER'..."
sed -i "s/droidmaster/$DEBUSER/g" startxfce4_debian.sh
chmod +x startxfce4_debian.sh

# --- Create login script for CLI-only access ---
cat > login_debian.sh <<EOF
#!/data/data/com.termux/files/usr/bin/bash
# Script to login to Debian as user '$DEBUSER'

proot-distro login debian -- bash -c "su - $DEBUSER"
EOF

chmod +x login_debian.sh

# --- Done ---
echo ""
echo "✅ Setup complete!"
echo "📦 To launch XFCE desktop (after launching Termux-X11), run:"
echo ". ./startxfce4_debian.sh"
echo "💻 To login to Debian command line as '$DEBUSER', run:"
echo "./login_debian.sh"
